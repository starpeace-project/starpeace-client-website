import { SCALE_MODES } from '@pixi/constants'

import type ApiClient from '~/plugins/starpeace-client/api/api-client.js'

import BookmarkManager from '~/plugins/starpeace-client/bookmark/bookmark-manager'
import Building from '~/plugins/starpeace-client/building/building'
import BuildingDetails from '~/plugins/starpeace-client/building/building-details'
import TranslationManager from '~/plugins/starpeace-client/language/translation-manager'

import BuildingEvent from '~/plugins/starpeace-client/event/building-event.js'
import ChunkMap from '~/plugins/starpeace-client/map/chunk/chunk-map.js';

import type AjaxState from '~/plugins/starpeace-client/state/ajax-state.js';
import type ClientState from '~/plugins/starpeace-client/state/client-state.js';

import Logger from '~/plugins/starpeace-client/logger'
import Utils from '~/plugins/starpeace-client/utils/utils'
import { SimulationDefinition } from '@starpeace/starpeace-assets-types'
import BuildingConnection from './details/building-connection'


export default class BuildingManager {
  api: ApiClient;

  assetManager: any;
  bookmarkManager: BookmarkManager;
  translationManager: TranslationManager;

  ajaxState: AjaxState;
  clientState: ClientState;

  constructor (api: ApiClient, assetManager: any, bookmarkManager: BookmarkManager, translationManager: TranslationManager, ajaxState: AjaxState, clientState: ClientState) {
    this.api = api;
    this.assetManager = assetManager;
    this.bookmarkManager = bookmarkManager;
    this.translationManager = translationManager;
    this.ajaxState = ajaxState;
    this.clientState = clientState;

    this.clientState.planet.subscribeBuildingListener((event: any) => this.handleBuildingEvent(event));
    this.clientState.options.subscribe_options_listener(async () => {
      const disableAA = !this.clientState.options.option('renderer.building_anti_alias');
      for (const atlas of this.clientState.core.building_library.allAtlases()) {
        if (atlas.baseTexture) {
          atlas.baseTexture.scaleMode = disableAA ? SCALE_MODES.NEAREST : SCALE_MODES.LINEAR;
          atlas.baseTexture.update();
        }
      }
    });
  }

  initialize () {
    this.clientState.core.building_library.initialize(this.clientState.core.planet_library);
  }

  async queue_asset_load (): Promise<void> {
    if (this.clientState.core.building_library.has_assets() || this.ajaxState.is_locked('assets.building_metadata', 'ALL')) {
      return;
    }

    await this.ajaxState.locked('assets.building_metadata', 'ALL', async () => {
      await new Promise<void>((resolve, reject) => {
        this.assetManager.queue('metadata.building', './building.metadata.json', (resource: any) => {
          if (resource?.error) {
            reject(resource.error);
          }
          else {
            // FIXME: TODO: convert json to object
            this.clientState.core.building_library.load_images(resource.images);
            this.clientState.core.building_library.load_required_atlases(resource.atlas);
            this.assetManager.queue_and_load_atlases((resource.atlas || []), (atlas_path: any, atlas: any) => {
              if (atlas?.baseTexture && !this.clientState.options.option('renderer.building_anti_alias')) {
                atlas.baseTexture.scaleMode = SCALE_MODES.NEAREST;
              }
              this.clientState.core.building_library.load_atlas(atlas_path, atlas);
            });
            resolve();
          }
        });
      });
    });
  }

  cost_for_resource_type (resourceId: string): number {
    return this.clientState.core.planet_library.resource_type_for_id(resourceId)?.price ?? 0;
  }
  cost_for_building_definition_id (definitionId: string): number {
    const simulation: SimulationDefinition = this.clientState.core.building_library.simulation_definition_for_id(definitionId);
    return (simulation?.constructionInputs ?? []).reduce((sum: number, input: any) => sum + (this.cost_for_resource_type(input.resourceId) * input.quantity), 0);
  }

  async load_chunk (chunkX: number, chunkY: number): Promise<Array<string>> {
    if (!this.clientState.has_session() || chunkX === undefined || chunkY === undefined) {
      throw Error();
    }
    return await this.ajaxState.locked('building_load_chunk', `${chunkX}x${chunkY}`, async () => {
      const buildings = ((await this.api.buildings_for_planet(chunkX, chunkY)) ?? []).map(Building.fromJson);
      this.clientState.core.building_cache.load_buildings(buildings);
      Logger.debug(`loaded building chunk at ${chunkX}x${chunkY}`);
      return buildings.map((b: Building) => b.id);
    });
  }

  async load_by_company (companyId: string, _skipCache: boolean = false): Promise<void> {
    if (!this.clientState.has_session() || !companyId) {
      throw Error();
    }
    return await this.ajaxState.locked('building_metadata', companyId, async () => {
      const buildings: Building[] = ((await this.api.buildings_for_company(companyId)) ?? []).map(Building.fromJson);
      this.clientState.core.building_cache.load_buildings(buildings);
      this.clientState.corporation.set_company_building_ids(companyId, buildings.map((b: Building) => b.id));
      return buildings;
    });
  }

  async load_building_metadata (buildingId: string): Promise<Building> {
    if (!this.clientState.has_session() || !buildingId) {
      throw Error();
    }
    return await this.ajaxState.locked('building_metadata', buildingId, async () => {
      const building = await this.api.building_for_id(buildingId);
      this.clientState.core.building_cache.load_building(building);
      return building;
    });
  }

  async load_building_details (buildingId: string, skipCache: boolean = false): Promise<BuildingDetails> {
    if (!this.clientState.has_session() || !buildingId) {
      throw Error();
    }
    const details = this.clientState.core.building_cache.detailsForBuildingId(buildingId);
    if (!!details && !skipCache) {
      return details;
    }
    return await this.ajaxState.locked('building_details', buildingId, async () => {
      const details = BuildingDetails.fromJson(await this.api.building_details_for_id(buildingId));
      this.clientState.core.building_cache.loadDetails(buildingId, details);
      return details;
    });
  }

  async update_building_settings (buildingId: string, settings: any): Promise<void> {
    if (!this.clientState.has_session() || !buildingId) {
      throw Error();
    }
    return await this.ajaxState.locked('building_settings', buildingId, async () => {
      await this.api.update_building_details(buildingId, settings);
    });
  }

  async loadBuildingConnections (buildingId: string, type: string, resourceId: string, skipCache: boolean = false): Promise<BuildingConnection[]> {
    if (!this.clientState.has_session() || !buildingId) {
      throw Error();
    }
    const connections = this.clientState.core.building_cache.connectionsForBuildingIdResourceId(buildingId, type, resourceId);
    if (!!connections && !skipCache) {
      return connections;
    }
    return await this.ajaxState.locked('building_connections', buildingId, async () => {
      const connections = await this.api.buildingConnectionsForId(buildingId, type, resourceId);
      this.clientState.core.building_cache.loadConnections(buildingId, resourceId, type, connections);
      return connections;
    });
  }

  async construct_building (): Promise<void> {
    const buildingMetadata = this.clientState.core.building_library.metadata_by_id[this.clientState.interface.construction_building_id];

    if (!this.clientState.has_session() || !buildingMetadata) {
      throw Error();
    }
    await this.ajaxState.locked('building_construction', 'ALL', async () => {
      const temporaryBuilding = Building.fromJson({
        id: Utils.uuid(),
        tycoonId: this.clientState.player.tycoon_id,
        corporationId: this.clientState.player.corporation_id,
        companyId: this.clientState.player.company_id,
        definitionId: buildingMetadata.id,
        name: `${this.translationManager.text(buildingMetadata.name)} #${this.clientState.building_count_for_company(buildingMetadata.id) + 1}`,
        mapX: this.clientState.interface.construction_building_map_x,
        mapY: this.clientState.interface.construction_building_map_y
      });

      this.clientState.core.building_cache.load_building(temporaryBuilding);
      this.clientState.planet.game_map.building_map.add_building(temporaryBuilding.id);
      this.clientState.planet.notify_map_data_listeners({ type: 'building', info: {chunk_x: temporaryBuilding.map_x / ChunkMap.CHUNK_WIDTH, chunk_y: temporaryBuilding.map_y / ChunkMap.CHUNK_HEIGHT} });


      try {
        const constructedBuilding = Building.fromJson(await this.api.construct_building(temporaryBuilding.company_id, temporaryBuilding.definition_id, temporaryBuilding.name, temporaryBuilding.map_x, temporaryBuilding.map_y));
        this.clientState.core.building_cache.load_building(constructedBuilding);
        this.clientState.planet.game_map.building_map.remove_building(temporaryBuilding.id);
        this.clientState.planet.game_map.building_map.add_building(constructedBuilding.id);
        this.clientState.corporation.add_company_building_id(constructedBuilding.company_id, constructedBuilding.id);
        this.clientState.core.building_cache.remove_building(temporaryBuilding.id);
        this.clientState.planet.notify_map_data_listeners({ type: 'building', info: {chunk_x: constructedBuilding.map_x / ChunkMap.CHUNK_HEIGHT, chunk_y: constructedBuilding.map_y / ChunkMap.CHUNK_HEIGHT} });

        this.bookmarkManager.addBuildingBookmark(constructedBuilding.id, true);
        this.clientState.interface.select_building_id(constructedBuilding.id);
      }
      catch (err) {
        this.clientState.planet.game_map.building_map.remove_building(temporaryBuilding.id);
        this.clientState.add_error_message('Failure constructing building', err);
      }
    });
  }

  async demolish_building (buildingId: string): Promise<Building> {
    if (!this.clientState.has_session() || !buildingId) {
      throw Error();
    }
    return await this.ajaxState.locked('building_demolish', buildingId, async () => {
      const building = Building.fromJson(await this.api.demolish_building(buildingId));
      this.clientState.core.building_cache.load_building(building);
      return building;
    });
  }

  async clone_building (buildingId: string, cloneOptionIds: Array<string>): Promise<number> {
    if (!this.clientState.has_session() || !buildingId || !Object.keys(cloneOptionIds).length) {
      throw Error();
    }
    return await this.ajaxState.locked('building_clone', buildingId, async () => {
      const response = await this.api.clone_building(buildingId, cloneOptionIds);
      return response.clonedCount ?? 0;
    });
  }

  async handleBuildingEvent (event: BuildingEvent): Promise<void> {
    if (event.type === 'ADD' || event.type === 'UPDATE') {
      // only add or update buildings if that chunk has been loaded by client already
      const loadedChunk: boolean = !!this.clientState.planet.game_map?.building_map?.building_chunks?.info_at(event.mapX, event.mapY);
      if (loadedChunk) {
        const building = await this.load_building_metadata(event.id);
        if (event.type === 'ADD') {
          this.clientState.planet.game_map.building_map.add_building(event.id);
        }
        this.clientState.planet.notify_map_data_listeners({ type: 'building', info: { chunk_x: building.mapX / ChunkMap.CHUNK_WIDTH, chunk_y: building.mapY / ChunkMap.CHUNK_HEIGHT } });
      }
      if (event.type === 'ADD') {
        this.clientState.interface.queueBuildingEvent(event);
      }
    }
    else if (event.type === 'DELETE') {
      const building = this.clientState.core.building_cache.building_for_id(event.id);
      this.clientState.planet.game_map.building_map.remove_building(event.id);
      this.clientState.core.building_cache.remove_building(event.id);
      if (building) {
        this.clientState.planet.notify_map_data_listeners({ type: 'building', info: { chunk_x: building.map_x / ChunkMap.CHUNK_HEIGHT, chunk_y: building.map_y / ChunkMap.CHUNK_HEIGHT } });
      }
      if (this.clientState.interface.selected_building_id === event.id) {
        this.clientState.interface.unselect_building();
      }
    }
  }
}
