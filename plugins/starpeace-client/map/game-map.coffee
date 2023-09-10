import * as PIXI from 'pixi.js'

import BuildingMap from '~/plugins/starpeace-client/map/building-map.coffee'
import ConcreteMap from '~/plugins/starpeace-client/map/concrete-map.coffee'
import LandMap from '~/plugins/starpeace-client/map/land-map.coffee'
import OverlayMap from '~/plugins/starpeace-client/map/overlay-map.coffee'
import RoadMap from '~/plugins/starpeace-client/map/road-map.coffee'

import Concrete from '~/plugins/starpeace-client/building/concrete.coffee'

export default class GameMap
  constructor: (building_manager, road_manager, overlay_manager, land_metadata, texture, towns_texture, extract, client_state, @options) ->
    @width = texture.width
    @height = texture.height

    @map_rgba_pixels = extract.pixels(PIXI.Sprite.from(texture))
    @towns_rgba_pixels = extract.pixels(PIXI.Sprite.from(towns_texture))

    @ground_map = LandMap.from_pixel_data(land_metadata, @width, @height, @map_rgba_pixels)
    @building_map = new BuildingMap(client_state, building_manager, road_manager, @width, @height)
    @concrete_map = new ConcreteMap(client_state, @ground_map, @building_map, @width, @height)
    @road_map = new RoadMap(client_state, @ground_map, @building_map, @concrete_map, @width, @height)
    @overlay_map = new OverlayMap(client_state, overlay_manager, @width, @height)

  stop: () -> map.stop() for map in [@building_map, @overlay_map]

  town_color_at: (x, y) ->
    index = ((@height - x) * @width + (@width - y)) * 4
    ((@towns_rgba_pixels[index + 0] << 16) & 0xFF0000) | ((@towns_rgba_pixels[index + 1] << 8) & 0x00FF00) | ((@towns_rgba_pixels[index + 2] << 0) & 0x0000FF)

  info_for_tile: (now, x, y, render_trees, show_zones, show_overlay, current_overlay) ->
    building_chunk_info = @building_map.chunk_building_info_at(x, y)
    @building_map.chunk_building_update_at(x, y) if !building_chunk_info || building_chunk_info?.is_expired(now)

    road_chunk_info = @building_map.chunk_road_info_at(x, y)
    @building_map.chunk_road_update_at(x, y) if !road_chunk_info || road_chunk_info?.is_expired(now)

    zone_chunk_info = if show_zones then @overlay_map.chunk_info_at('ZONES', x, y) else null
    overlay_chunk_info = if !show_zones && show_overlay then @overlay_map.chunk_info_at(current_overlay.type, x, y) else null
    @overlay_map.chunk_update_at('ZONES', x, y) if show_zones && !zone_chunk_info || zone_chunk_info?.is_expired(now)
    @overlay_map.chunk_update_at(current_overlay.type, x, y) if !show_zones && show_overlay && !overlay_chunk_info || overlay_chunk_info?.is_expired(now)

    zone_info = null
    overlay_info = null
    building_info = null
    road_info = null
    concrete_info = null

    chunk_loaded = building_chunk_info?.has_data() && road_chunk_info?.has_data()
    if chunk_loaded
      zone_info = if zone_chunk_info?.has_data() then @overlay_map.overlay_at('ZONES', x, y) else null
      overlay_info = if overlay_chunk_info?.has_data() then @overlay_map.overlay_at(current_overlay.type, x, y) else null

      building_info = @building_map.building_info_at(x, y)
      road_info = @road_map.road_info_at(x, y)
      concrete_info = @concrete_map.concrete_info_at(x, y)

      road_info.is_on_platform = true if road_info? && concrete_info? && road_info.is_over_water

    is_position_within_map = x >= 0 && x < @width && y >= 0 && y < @height
    is_road_needs_land = road_info? && (!road_info.is_city || road_info.is_over_water || road_info.is_concrete_edge)
    is_concrete_needs_land = concrete_info? && (concrete_info.type != Concrete.TYPES.CENTER && concrete_info.type != Concrete.TYPES.CENTER_TREEABLE)

    tree_info = if render_trees && !road_info? && !concrete_info? && !building_info? && is_position_within_map then @ground_map.tree_at(x, y) else null
    land_info = if is_position_within_map && (is_road_needs_land || !road_info?) && (is_concrete_needs_land || !concrete_info?) then @ground_map.ground_at(x, y) else null

    {
      is_position_within_map
      is_chunk_data_loaded: chunk_loaded

      land_info
      building_info
      concrete_info
      overlay_info
      road_info
      tree_info
      zone_info
    }
