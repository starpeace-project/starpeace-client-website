
CHUNK_X = 20
CHUNK_Y = 20

window.starpeace ||= {}
window.starpeace.map ||= {}
window.starpeace.map.BuildingMap = class BuildingMap

  constructor: (@client, @width, @height) ->

    @buildings = new Array(@width * @height)

    @building_chunk_info = new Array(Math.ceil(@width / CHUNK_X), Math.ceil(@height / CHUNK_Y))

  load_chunk: (chunk_x, chunk_y, data) ->
    chunk_index = chunk_y * @width + chunk_x
    if @building_chunk_info[chunk_index]?
      @building_chunk_info[chunk_index].update()
    else
      @building_chunk_info[chunk_index] = new starpeace.map.ChunkInfo(chunk_x * CHUNK_X, chunk_y * CHUNK_Y, CHUNK_X, CHUNK_Y, 5)
    @client.renderer.map_layers.needs_refresh = true if @client.renderer.map_layers?

  update_chunk_at: (x, y) ->
    return if x < 0 || y < 0 || x > @width || y > @height
    chunk_x = Math.floor(x / CHUNK_X)
    chunk_y = Math.floor(y / CHUNK_Y)
    @client.building_manager.load_building_chunk(chunk_x, chunk_y, CHUNK_X, CHUNK_Y)


  chunk_info_at: (x, y) ->
    chunk_x = Math.floor(x / CHUNK_X)
    chunk_y = Math.floor(y / CHUNK_Y)
    @building_chunk_info[chunk_y * @width + chunk_x]


  building_index_for: (x, y) -> y * @width + x
  building_at: (x, y) -> @buildings[@building_index_for(x, y)]


  building_texture_for: (type) ->
    texture = PIXI.utils.TextureCache["#{season}.255.border.center.1"]
    unless x < 0 || x > @width || y < 0 || y > @height
      tile = @ground_at(x, y)
      texture_id = _.values(tile?.textures?['0deg']?[season] || {})[0]
      texture = PIXI.utils.TextureCache[texture_id] if texture_id?.length
      console.debug "[STARPEACE] unable to find ground texture <#{texture_id}> for coord <#{x}>x<#{y}>, will fall back to default" unless texture?
    texture


