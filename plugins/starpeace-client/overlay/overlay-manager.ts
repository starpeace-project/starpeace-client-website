import _ from 'lodash';

import type { CityZone } from '@starpeace/starpeace-assets-types';

import MetadataOverlay from '~/plugins/starpeace-client/overlay/metadata-overlay';
import ChunkMap from '~/plugins/starpeace-client/map/chunk/chunk-map';

import type ApiClient from '~/plugins/starpeace-client/api/api-client'
import type AssetManager from '~/plugins/starpeace-client/asset/asset-manager';
import type AjaxState from '~/plugins/starpeace-client/state/ajax-state';
import type ClientState from '~/plugins/starpeace-client/state/client-state';

import Logger from '~/plugins/starpeace-client/logger'

interface OverlayTile {
  value: number;
  color: number;
}

export default class OverlayManager {
  api: ApiClient;
  assetManager: AssetManager;

  ajaxState: AjaxState;
  clientState: ClientState;

  constructor (api: ApiClient, assetManager: AssetManager, ajaxState: AjaxState, clientState: ClientState) {
    this.api = api;
    this.assetManager = assetManager;
    this.ajaxState = ajaxState;
    this.clientState = clientState;
  }

  queue_asset_load (): void {
    if (this.clientState.core.overlay_library.has_assets() || this.ajaxState.is_locked('assets.overlay_metadata', 'ALL')) {
      return;
    }

    this.ajaxState.lock('assets.overlay_metadata', 'ALL');
    this.assetManager.queue('metadata.overlay', './overlay.metadata.json', (resource) => {
      const overlay_metadata = [];
      for (const [key, json] of Object.entries(resource.overlays ?? {})) {
        // FIXME: TODO: add ID to json, change from map to array
        (json as any).id = key;
        overlay_metadata.push(MetadataOverlay.from_json(json));
      }

      this.clientState.core.overlay_library.load_overlay_metadata(overlay_metadata);
      this.clientState.core.overlay_library.load_required_atlases(resource.atlas);

      this.assetManager.queue_and_load_atlases((resource.atlas || []), (atlas_path, atlas) => {
        // mip-mapping has bigger impact without edge aliasing
        // TODO: why isn't this, or PIXI.settings.MIPMAP_TEXTURES, working?
        if (atlas.spritesheet?.baseTexture?.mipmap) {
          atlas.spritesheet.baseTexture.mipmap = false;
        }

        this.clientState.core.overlay_library.load_atlas(atlas_path, atlas);
      });
      this.ajaxState.unlock('assets.overlay_metadata', 'ALL');
    });
  }

  async load_chunk (typeId: string, chunkX: number, chunkY: number): Promise<Array<OverlayTile | CityZone | undefined>> {
    if (!this.clientState.has_session() || !typeId || !_.isNumber(chunkX) || !_.isNumber(chunkY)) {
      throw Error();
    }

    if (typeId === 'NONE') {
      return new Array(ChunkMap.CHUNK_WIDTH * ChunkMap.CHUNK_HEIGHT);
    }

    if (typeId == 'TOWNS') {
      return this.deserializeTownsChunk(chunkX, chunkY);
    }
    else {
      return await this.ajaxState.locked('planet_overlays', `${typeId}x${chunkX}x${chunkY}`, async () => {
        const overlayData = await this.api.overlay_data_for_planet(typeId, chunkX, chunkY);
        if (!overlayData) {
          return new Array(ChunkMap.CHUNK_WIDTH, ChunkMap.CHUNK_HEIGHT);
        }
        else if (typeId === 'ZONES') {
          return this.deserializeZoneChunk(ChunkMap.CHUNK_WIDTH, ChunkMap.CHUNK_HEIGHT, overlayData)
        }
        else {
          return this.deserializeOverlayChunk(typeId, ChunkMap.CHUNK_WIDTH, ChunkMap.CHUNK_HEIGHT, overlayData)
        }
      });
    }
  }

  deserializeTownsChunk (chunkX: number, chunkY: number): Array<OverlayTile> {
    const data = new Array<OverlayTile>(ChunkMap.CHUNK_WIDTH * ChunkMap.CHUNK_HEIGHT);
    const xOffset = ChunkMap.CHUNK_WIDTH * chunkX;
    const yOffset = ChunkMap.CHUNK_HEIGHT * chunkY;
    for (let y = 0; y < ChunkMap.CHUNK_HEIGHT; y++) {
      for (let x = 0; x < ChunkMap.CHUNK_WIDTH; x++) {
        const color = this.clientState.planet.game_map.town_color_at(x + xOffset, y + yOffset);
        data[y * ChunkMap.CHUNK_WIDTH + x] = {
          value: color,
          color: color
        }
      }
    }
    return data;
  }

  deserializeZoneChunk (width: number, height: number, data: any): Array<CityZone | undefined> {
    const zones = new Array(width * height)
    if (data.length !== zones.length) {
      Logger.warn(`Unable to deserialize city zone chunk (needed ${zones.length}, had ${data.length})`);
      return zones;
    }

    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        const typeValue = data[y * width + x];
        if (!_.isNumber(typeValue) || typeValue <= 0) {
          continue;
        }

        const cityZone = this.clientState.core.planet_library.zone_for_value(typeValue);
        if (cityZone) {
          zones[y * width + x] = cityZone;
        }
        else {
          Logger.warn(`Unable to find city zone for value ${typeValue}`);
        }
      }
    }
    return zones;
  }

  deserializeOverlayChunk (typeId: string, width: number, height: number, data: any): Array<OverlayTile> {
    const overlayType = this.clientState.core.planet_library.overlayTypeForId(typeId);
    if (!overlayType) {
      throw `Unknown overlay type ${typeId}`;
    }

    const overlayData = new Array(width * height);
    if (data.length !== overlayData.length) {
      Logger.warn(`Unable to deserialize overlay chunk (needed ${overlayData.length}, had ${data.length})`);
      return overlayData;
    }

    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        const overlayValue = data[y * width + x];
        overlayData[y * width + x] = {
          value: overlayValue,
          color: overlayType.colorAt(overlayValue)
        }
      }
    }

    return overlayData;
  }
}
