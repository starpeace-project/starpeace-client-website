
import BuildingMap from '~/plugins/starpeace-client/map/building-map.coffee'
import ConcreteMap from '~/plugins/starpeace-client/map/concrete-map.coffee'
import LandMap from '~/plugins/starpeace-client/map/land-map.coffee'
import OverlayMap from '~/plugins/starpeace-client/map/overlay-map.coffee'
import RoadMap from '~/plugins/starpeace-client/map/road-map.coffee'

import Concrete from '~/plugins/starpeace-client/building/concrete.coffee'

import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

export default class GameMap
  constructor: (building_manager, road_manager, overlay_manager, land_metadata, texture, @client_state, @options) ->
    @width = texture.texture.width
    @height = texture.texture.height

    map_width = texture.texture.width
    map_height = texture.texture.height

    @raw_map_rgba_pixels = Utils.pixels_for_image(texture.data)
    @ground_map = LandMap.from_pixel_data(land_metadata, @width, @height, @raw_map_rgba_pixels)
    @building_map = new BuildingMap(@client_state, building_manager, road_manager, @width, @height)
    @concrete_map = new ConcreteMap(@client_state, @ground_map, @building_map, @width, @height)
    @road_map = new RoadMap(@client_state, @ground_map, @building_map, @concrete_map, @width, @height)
    @overlay_map = new OverlayMap(@client_state, overlay_manager, @width, @height)

  info_for_tile: (x, y) ->
    building_chunk_info = @building_map.chunk_building_info_at(x, y)
    @building_map.chunk_building_update_at(x, y) unless building_chunk_info?.is_current()

    road_chunk_info = @building_map.chunk_road_info_at(x, y)
    @building_map.chunk_road_update_at(x, y) unless road_chunk_info?.is_current()

    zone_info = null
    overlay_info = null
    building_info = null
    road_info = null
    concrete_info = null

    if building_chunk_info? && road_chunk_info?
      if @client_state.interface.show_zones
        zone_chunk_info = @overlay_map.chunk_info_at('ZONES', x, y)
        if zone_chunk_info?.is_current()
          zone_info = @overlay_map.overlay_at('ZONES', x, y)
        else
          @overlay_map.chunk_update_at('ZONES', x, y)

      else if @client_state.interface.show_overlay
        overlay_chunk_info = @overlay_map.chunk_info_at(@client_state.interface.current_overlay.type, x, y)
        if overlay_chunk_info?.is_current()
          overlay_info = @overlay_map.overlay_at(@client_state.interface.current_overlay.type, x, y)
        else
          @overlay_map.chunk_update_at(@client_state.interface.current_overlay.type, x, y)

      building_info = @building_map.building_info_at(x, y)
      road_info = @road_map.road_info_at(x, y)
      concrete_info = @concrete_map.concrete_info_at(x, y)

      road_info.is_on_platform = true if road_info? && concrete_info? && road_info.is_over_water

    is_position_within_map = x >= 0 && x < @width && y >= 0 && y < @height
    is_road_needs_land = road_info? && (!road_info.is_city || road_info.is_over_water || road_info.is_concrete_edge)
    is_concrete_needs_land = concrete_info? && (concrete_info.type != Concrete.TYPES.CENTER && concrete_info.type != Concrete.TYPES.CENTER_TREEABLE)

    tree_info = if @options.option('renderer.trees') && !road_info? && !concrete_info? && !building_info? && is_position_within_map then @ground_map.tree_at(x, y) else null
    land_info = if is_position_within_map && (is_road_needs_land || !road_info?) && (is_concrete_needs_land || !concrete_info?) then @ground_map.ground_at(x, y) else null

    {
      is_position_within_map
      is_chunk_data_loaded: building_chunk_info? && road_chunk_info?

      land_info
      building_info
      concrete_info
      overlay_info
      road_info
      tree_info
      zone_info
    }
