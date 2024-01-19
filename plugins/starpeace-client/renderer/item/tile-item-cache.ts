import _ from 'lodash'

import { type RenderContext } from '~/plugins/starpeace-client/renderer/layer/layers';
import TileItem from '~/plugins/starpeace-client/renderer/item/tile-item.js'
import TileItemFactory from '~/plugins/starpeace-client/renderer/item/tile-item-factory.js';
import type TileInfo from '~/plugins/starpeace-client/map/tile-info.js'

import type ClientState from '~/plugins/starpeace-client/state/client-state.js'
import type Options from '~/plugins/starpeace-client/state/options/options.js'

const RENDER_OPTIONS = [
  'renderer.trees',
  'renderer.buildings',
  'renderer.building_animations',
  'renderer.building_effects',
  'renderer.planes'
];

class RenderState {
  viewOffsetX: number = 0;
  viewOffsetY: number = 0;

  scaleRendered: number = 0;
  seasonRendered: string | undefined = undefined;

  zones: boolean = false;
  overlay: boolean = false;
  overlayType: string | undefined = undefined;
}

class RenderSelection {
  constructionBuildingId: string | undefined =  undefined;
  constructionBuildingX: number = 0;
  constructionBuildingY: number = 0;
  buildingId: string | undefined = undefined;
}

class RenderOptions {
  options: Record<string, boolean> = {};
}

export default class TileItemCache {
  clientState: ClientState;
  options: Options;

  isDirty: boolean = true;
  lastRendered: RenderState = new RenderState();
  lastSelection: RenderSelection = new RenderSelection();
  lastOptions: RenderOptions = new RenderOptions();

  tileItemsFactory: TileItemFactory;
  tileItems: Record<string, any> = {};

  constructor (clientState: ClientState, options: Options) {
    this.clientState = clientState;
    this.options = options;
    this.tileItemsFactory = new TileItemFactory(clientState);
  }

  get hasDirtyView (): boolean {
    if (this.clientState.camera.view_offset_x != this.lastRendered.viewOffsetX || this.clientState.camera.view_offset_y != this.lastRendered.viewOffsetY) {
      return true;
    }
    if (this.clientState.interface.selected_building_id != this.lastSelection.buildingId) {
      return true;
    }
    return false;
  }

  get isRenderStale (): boolean {
    return this.clientState.camera.game_scale != this.lastRendered.scaleRendered
        || this.clientState.planet.current_season != this.lastRendered.seasonRendered
        || this.clientState.interface.show_zones != this.lastRendered.zones
        || this.clientState.interface.show_overlay != this.lastRendered.overlay
        || this.clientState.interface.current_overlay != this.lastRendered.overlayType;
  }

  get isSelectionStale (): boolean {
    return this.clientState.interface.construction_building_id != this.lastSelection.constructionBuildingId
        || this.clientState.interface.construction_building_map_x != this.lastSelection.constructionBuildingX
        || this.clientState.interface.construction_building_map_y != this.lastSelection.constructionBuildingY;
  }

  get shouldClearCache (): boolean {
    if (this.hasDirtyView || this.isRenderStale || this.isSelectionStale) {
      return true;
    }

    for (const option of RENDER_OPTIONS) {
      if (this.options.option(option) !== this.lastOptions.options[option]) {
        return true;
      }
    }
    return false;
  }

  resetCache (): void {
    this.lastRendered.viewOffsetX = this.clientState.camera.view_offset_x;
    this.lastRendered.viewOffsetY = this.clientState.camera.view_offset_y
    this.lastRendered.scaleRendered = this.clientState.camera.game_scale;
    this.lastRendered.seasonRendered = this.clientState.planet.current_season;
    this.lastRendered.zones = this.clientState.interface.show_zones;
    this.lastRendered.overlay = this.clientState.interface.show_overlay;
    this.lastRendered.overlayType = this.clientState.interface.current_overlay;

    this.lastSelection.buildingId = this.clientState.interface.selected_building_id ?? undefined;
    this.lastSelection.constructionBuildingId = this.clientState.interface.construction_building_id ?? undefined;
    this.lastSelection.constructionBuildingX = this.clientState.interface.construction_building_map_x;
    this.lastSelection.constructionBuildingY = this.clientState.interface.construction_building_map_y;

    for (const option of RENDER_OPTIONS) {
      this.lastOptions.options[option] = this.options.option(option);
    }

    this.isDirty = false;
  }

  clearFullCache (): void {
    this.tileItems = {};
    this.isDirty = true;
  }

  clearCache (sourceX: number, targetX: number, sourceY: number, targetY: number): void {
    if (!!this.clientState.planet.game_map && sourceX !== undefined && targetX !== undefined && sourceY !== undefined && targetY !== undefined) {
      const gameMapWidth = this.clientState.planet.game_map.width;
      for (let y = sourceY; y < targetY; y++) {
        for (let x = sourceX; x < targetX; x++) {
          const index = (y * gameMapWidth + x).toString();
          if (this.tileItems[index]) {
            delete this.tileItems[index]
          }
        }
      }
    }
    else {
      this.tileItems = {};
    }

    this.isDirty = true;
  }

  cacheItem (tileInfo: TileInfo, tileCacheIndex: string, x: number, y: number, context: RenderContext): TileItem {
    const isBuildingRootTile = !!tileInfo.building && tileInfo.building.map_x == x && tileInfo.building.map_y == y;
    this.tileItems[tileCacheIndex] = new TileItem(tileInfo, x, y, {
      land: this.tileItemsFactory.land(tileInfo, context),
      concrete: this.tileItemsFactory.concrete(tileInfo),
      road: this.tileItemsFactory.road(tileInfo),
      tree: this.tileItemsFactory.tree(tileInfo, context),
      foundation: !context.renderBuildings && isBuildingRootTile ? this.tileItemsFactory.foundation(tileInfo) : undefined,
      building: context.renderBuildings && isBuildingRootTile ? this.tileItemsFactory.building(tileInfo, context) : undefined,
      overlay: this.tileItemsFactory.overlay(tileInfo)
    });
    return this.tileItems[tileCacheIndex];
  }
}
