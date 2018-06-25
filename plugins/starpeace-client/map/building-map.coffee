
###
global PIXI
###

import ChunkMap from '~/plugins/starpeace-client/map/chunk/chunk-map.coffee'

class BuildingMap
  constructor: (@client, @width, @height) ->
    @buildings = new Array(@width * @height)

    @chunks = new ChunkMap(@client, @width, @height, true, (chunk_x, chunk_y, chunk_width, chunk_height) =>
      @client.building_manager.load_chunk(chunk_x, chunk_y, chunk_width, chunk_height)
    , (chunk_info, data) =>
      console.debug "[STARPEACE] refreshing building chunk at #{chunk_info.chunk_x}x#{chunk_info.chunk_y}"
    )

  chunk_update_at: (x, y) -> @chunks.update_at(x, y)
  chunk_info_at: (x, y) -> @chunks.info_at(x, y)

  building_index_for: (x, y) -> y * @width + x
  building_at: (x, y) -> @buildings[@building_index_for(x, y)]

  building_texture_for: (type) ->
    texture = PIXI.utils.TextureCache["#{season}.255.border.center.1"]
    unless x < 0 || x > @width || y < 0 || y > @height
      tile = @ground_at(x, y)
      texture_id = _.values(tile?.textures?['0deg']?[season] || {})[0]
      texture = PIXI.utils.TextureCache[texture_id] if texture_id?.length
      console.debug "[STARPEACE] unable to find building texture <#{texture_id}> for coord <#{x}>x<#{y}>, will fall back to default" unless texture?
    texture

export default BuildingMap
