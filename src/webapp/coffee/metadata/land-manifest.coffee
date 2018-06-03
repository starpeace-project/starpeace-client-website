

window.starpeace ||= {}
window.starpeace.metadata ||= {}
window.starpeace.metadata.LandManifest = class LandManifest
  @DEFAULT_TILE_WIDTH: 64
  @DEFAULT_TILE_HEIGHT: 32

  constructor: (@planet_type, @definitions_by_id) ->
    @definitions_by_color = {}
    @definitions_by_color[tile_data.map_color] = tile_data for tile_key,tile_data of @definitions_by_id

