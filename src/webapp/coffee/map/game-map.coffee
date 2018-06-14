

window.starpeace ||= {}
window.starpeace.map ||= {}
window.starpeace.map.GameMap = class GameMap

  constructor: (@client, @width, @height, @ground_map) ->
    @building_map = new starpeace.map.BuildingMap(@client, @width, @height)

  update_building_chunk_at: (x, y) -> @building_map.update_chunk_at(x, y)

  building_chunk_info_at: (x, y) -> @building_map.chunk_info_at(x, y)
  building_at: (x, y) -> @building_map.building_at(x, y)

  @from_texture: (client, manifest, texture) ->
    map_width = texture.texture.width
    map_height = texture.texture.height
    new starpeace.map.GameMap(client, map_width, map_height, starpeace.map.GroundMap.from_texture(manifest, texture))
