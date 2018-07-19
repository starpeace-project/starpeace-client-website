
import BuildingMap from '~/plugins/starpeace-client/map/building-map.coffee'
import GroundMap from '~/plugins/starpeace-client/map/ground-map.coffee'
import OverlayMap from '~/plugins/starpeace-client/map/overlay-map.coffee'
import Concrete from '~/plugins/starpeace-client/map/types/concrete.coffee'

export default class GameMap
  constructor: (renderer, building_manager, overlay_manager, manifest, texture, @ui_state) ->
    @width = texture.texture.width
    @height = texture.texture.height
    @ground_map = GroundMap.from_texture(manifest, texture)
    @building_map = new BuildingMap(building_manager, renderer, @width, @height)
    @overlay_map = new OverlayMap(overlay_manager, renderer, @width, @height)

  info_for_tile: (x, y) ->
    building_chunk_info = @building_map.chunk_info_at(x, y)
    @building_map.chunk_update_at(x, y) unless building_chunk_info?.is_current()

    zone_info = null
    overlay_info = null
    building_info = null

    concrete_info = null
    is_concrete_or_buffer = false

    if building_chunk_info?
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

      building_info = @building_map.building_at(x, y)
      concrete_info = @building_map.concrete_at(x, y)
      concrete_type = @building_map.concrete_type_at(x, y)
      is_concrete_or_buffer = concrete_info? || concrete_type == Concrete.TYPES.BUFFER || concrete_type == Concrete.TYPES.EDGE || concrete_type == Concrete.TYPES.CENTER || concrete_type == Concrete.TYPES.CENTER_PLANT

    position_within_map = x >= 0 && x < @width && y >= 0 && y < @height
    tree_info = if @ui_state.render_trees && !is_concrete_or_buffer && position_within_map then @ground_map.tree_at(x, y) else null
    land_info = if !concrete_info? && !tree_info? && position_within_map then @ground_map.ground_at(x, y) else null

    {
      position_within_map
      has_building_chunk_info: building_chunk_info?
      land_info
      concrete_info
      tree_info
      zone_info
      building_info
      overlay_info
    }
