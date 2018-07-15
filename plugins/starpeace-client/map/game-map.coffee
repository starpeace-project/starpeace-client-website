
import BuildingMap from '~/plugins/starpeace-client/map/building-map.coffee'
import GroundMap from '~/plugins/starpeace-client/map/ground-map.coffee'
import OverlayMap from '~/plugins/starpeace-client/map/overlay-map.coffee'

class GameMap
  constructor: (building_manager, overlay_manager, renderer, @width, @height, @ground_map) ->
    @building_map = new BuildingMap(building_manager, renderer, @width, @height)
    @overlay_map = new OverlayMap(overlay_manager, renderer, @width, @height)

  update_building_chunk_at: (x, y) -> @building_map.chunk_update_at(x, y)
  building_chunk_info_at: (x, y) -> @building_map.chunk_info_at(x, y)
  building_at: (x, y) -> @building_map.building_at(x, y)

  update_zone_chunk_at: (x, y) -> @overlay_map.chunk_update_at('ZONES', x, y)
  zone_chunk_info_at: (x, y) -> @overlay_map.chunk_info_at('ZONES', x, y)
  zone_at: (x, y) -> @overlay_map.overlay_at('ZONES', x, y)

  update_overlay_chunk_at: (overlay_type, x, y) -> @overlay_map.chunk_update_at(overlay_type, x, y)
  overlay_chunk_info_at: (overlay_type, x, y) -> @overlay_map.chunk_info_at(overlay_type, x, y)
  overlay_at: (overlay_type, x, y) -> @overlay_map.overlay_at(overlay_type, x, y)

  @from_texture: (renderer, building_manager, overlay_manager, manifest, texture) ->
    map_width = texture.texture.width
    map_height = texture.texture.height
    new GameMap(building_manager, overlay_manager, renderer, map_width, map_height, GroundMap.from_texture(manifest, texture))

export default GameMap
