import { type Texture } from 'pixi.js';

import Concrete from '~/plugins/starpeace-client/building/concrete.coffee'
import BuildingManager from '~/plugins/starpeace-client/building/building-manager.js';

import BuildingMap from '~/plugins/starpeace-client/map/building-map.coffee'
import ConcreteMap from '~/plugins/starpeace-client/map/concrete-map.coffee'
import LandMap from '~/plugins/starpeace-client/map/land-map.coffee'
import OverlayMap from '~/plugins/starpeace-client/map/overlay-map.js'
import RoadMap from '~/plugins/starpeace-client/map/road-map.coffee'
import TileInfo from '~/plugins/starpeace-client/map/tile-info'

import { RenderContext } from '~/plugins/starpeace-client/renderer/layer/layers';

import ClientState from '~/plugins/starpeace-client/state/client-state';
import Options from '~/plugins/starpeace-client/state/options/options';
import Utils from '../utils/utils';


export default class GameMap {
  clientState: ClientState;
  options: Options;

  width: number;
  height: number;

  ground_map: LandMap;
  building_map: BuildingMap;
  concrete_map: ConcreteMap;
  road_map: RoadMap;
  overlay_map: OverlayMap;

  map_rgba_pixels: Uint8ClampedArray;
  towns_rgba_pixels: Uint8ClampedArray;

  constructor (buildingManager: BuildingManager, roadManager: any, overlayManager: any, land_metadata: any, texture: Texture, townsTexture: Texture, clientState: ClientState, options: Options) {
    this.clientState = clientState;
    this.options = options;

    this.width = texture.width;
    this.height = texture.height;

    this.map_rgba_pixels = Utils.pixels_for_image(texture.source.resource);
    this.towns_rgba_pixels = Utils.pixels_for_image(townsTexture.source.resource);

    this.ground_map = LandMap.from_pixel_data(land_metadata, this.width, this.height, this.map_rgba_pixels)
    this.building_map = new BuildingMap(clientState, buildingManager, roadManager, this.width, this.height)
    this.concrete_map = new ConcreteMap(clientState, this.ground_map, this.building_map, this.width, this.height)
    this.road_map = new RoadMap(clientState, this.ground_map, this.building_map, this.concrete_map, this.width, this.height)
    this.overlay_map = new OverlayMap(clientState, overlayManager, this.width, this.height)
  }

  stop (): void {
    for (const map of [this.building_map, this.overlay_map]) {
      map.stop();
    }
  }

  town_color_at (x: number, y: number): number {
    const index = ((this.height - x) * this.width + (this.width - y)) * 4;
    return ((this.towns_rgba_pixels[index + 0] << 16) & 0xFF0000) | ((this.towns_rgba_pixels[index + 1] << 8) & 0x00FF00) | ((this.towns_rgba_pixels[index + 2] << 0) & 0x0000FF);
  }

  info_for_tile (x: number, y: number, context: RenderContext): TileInfo {
    const building_chunk_info = this.building_map.chunk_building_info_at(x, y);
    if (!building_chunk_info || building_chunk_info?.is_expired(context.now)) {
      this.building_map.chunk_building_update_at(x, y);
    }

    const road_chunk_info = this.building_map.chunk_road_info_at(x, y)
    if (!road_chunk_info || road_chunk_info?.is_expired(context.now)) {
      this.building_map.chunk_road_update_at(x, y);
    }

    const showOverlay = !context.showZones && context.showOverlay && context.selectedOverlayTypeId;
    const zone_chunk_info = context.showZones ? this.overlay_map.chunk_info_at('ZONES', x, y) : undefined;
    const overlay_chunk_info = showOverlay ? this.overlay_map.chunk_info_at(context.selectedOverlayTypeId, x, y) : undefined;
    if (context.showZones && (!zone_chunk_info || zone_chunk_info?.is_expired(context.now))) {
      this.overlay_map.chunk_update_at('ZONES', x, y);
    }
    if (showOverlay && (!overlay_chunk_info || overlay_chunk_info?.is_expired(context.now))) {
      this.overlay_map.chunk_update_at(context.selectedOverlayTypeId, x, y);
    }

    let zone_info = undefined;
    let overlay_info = undefined;
    let building_id = undefined;
    let road_info = undefined;
    let concrete_info = undefined;

    const chunk_loaded = building_chunk_info?.has_data() && road_chunk_info?.has_data()
    if (chunk_loaded) {
      zone_info = zone_chunk_info?.has_data() ? this.overlay_map.overlay_at('ZONES', x, y) : undefined;
      overlay_info = context.selectedOverlayTypeId && overlay_chunk_info?.has_data() ? this.overlay_map.overlay_at(context.selectedOverlayTypeId, x, y) : undefined;

      building_id = this.building_map.building_id_at(x, y)
      road_info = this.road_map.road_info_at(x, y)
      concrete_info = this.concrete_map.concrete_info_at(x, y)

      if (road_info && concrete_info && road_info.is_over_water) {
        road_info.is_on_platform = true;
      }
    }

    const is_position_within_map = x >= 0 && x < this.width && y >= 0 && y < this.height;
    const is_road_needs_land = road_info && (!road_info.is_city || road_info.is_over_water || road_info.is_concrete_edge);
    const is_concrete_needs_land = concrete_info && (concrete_info.type != Concrete.TYPES.CENTER && concrete_info.type != Concrete.TYPES.CENTER_TREEABLE);

    return new TileInfo(
      is_position_within_map,
      chunk_loaded,
      is_position_within_map && (is_road_needs_land || !road_info) && (is_concrete_needs_land || !concrete_info) ? this.ground_map.ground_at(x, y) : undefined,
      building_id ? this.clientState.core.building_cache.building_for_id(building_id) : undefined,
      concrete_info,
      overlay_info,
      road_info,
      context.renderTrees && !road_info && !concrete_info && !building_id && is_position_within_map ? this.ground_map.tree_at(x, y) : undefined,
      zone_info
    );
  }
}
