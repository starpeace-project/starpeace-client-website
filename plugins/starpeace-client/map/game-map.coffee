
import BuildingMap from '~/plugins/starpeace-client/map/building-map.coffee'
import ConcreteMap from '~/plugins/starpeace-client/map/concrete-map.coffee'
import GroundMap from '~/plugins/starpeace-client/map/ground-map.coffee'
import OverlayMap from '~/plugins/starpeace-client/map/overlay-map.coffee'
import RoadMap from '~/plugins/starpeace-client/map/road-map.coffee'

import Concrete from '~/plugins/starpeace-client/map/types/concrete.coffee'

export default class GameMap
  constructor: (event_listener, building_manager, road_manager, overlay_manager, manifest, texture, @ui_state) ->
    @width = texture.texture.width
    @height = texture.texture.height
    @ground_map = GroundMap.from_texture(manifest, texture)
    @building_map = new BuildingMap(event_listener, @ground_map, building_manager, road_manager, @width, @height)
    @concrete_map = new ConcreteMap(event_listener, @ground_map, @building_map, @width, @height)
    @road_map = new RoadMap(event_listener, @ground_map, @building_map, @width, @height)
    @overlay_map = new OverlayMap(event_listener, overlay_manager, @width, @height)

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
      if @ui_state.show_zones
        zone_chunk_info = @overlay_map.chunk_info_at('ZONES', x, y)
        if zone_chunk_info?.is_current()
          zone_info = @overlay_map.overlay_at('ZONES', x, y)
        else
          @overlay_map.chunk_update_at('ZONES', x, y)

      else if @ui_state.show_overlay
        overlay_chunk_info = @overlay_map.chunk_info_at(@ui_state.current_overlay.type, x, y)
        if overlay_chunk_info?.is_current()
          overlay_info = @overlay_map.overlay_at(@ui_state.current_overlay.type, x, y)
        else
          @overlay_map.chunk_update_at(@ui_state.current_overlay.type, x, y)

      building_info = @building_map.building_info_at(x, y)
      road_info = @road_map.road_info_at(x, y)
      concrete_info = @concrete_map.concrete_info_at(x, y)

      # TODO: FIXME: try to move logic somewhere better (road_info should be immutable)
      # road_info.is_city = true if road_info?.is_city == false && concrete_info?.type == Concrete.TYPES.CENTER_ROAD

    is_position_within_map = x >= 0 && x < @width && y >= 0 && y < @height
    is_road_needs_land = road_info? && (!road_info.is_city || road_info.type.is_bridge)
    is_concrete_needs_land = concrete_info? && concrete_info.type != Concrete.TYPES.CENTER && concrete_info.type != Concrete.TYPES.CENTER_ROAD && concrete_info.type != Concrete.TYPES.CENTER_TREEABLE

    tree_info = if @ui_state.render_trees && !road_info? && !concrete_info? && is_position_within_map then @ground_map.tree_at(x, y) else null
    land_info = if is_position_within_map && (is_road_needs_land || !road_info?) && (is_concrete_needs_land || !concrete_info?) && !tree_info? then @ground_map.ground_at(x, y) else null

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
