
import ChunkInfo from '~/plugins/starpeace-client/map/chunk/chunk-info.coffee'

CHUNK_WIDTH = 20
CHUNK_HEIGHT = 20

class ChunkMap
  @CHUNK_WIDTH = CHUNK_WIDTH
  @CHUNK_HEIGHT = CHUNK_HEIGHT

  constructor: (@renderer, @width, @height, @refresh_on_load, @refresh_callback, @handle_refresh_callback) ->
    chunk_width = Math.ceil(@width / CHUNK_WIDTH)
    chunk_height = Math.ceil(@height / CHUNK_HEIGHT)
    @chunk_info = new Array(chunk_width * chunk_height)

  update_at: (x, y) ->
    return if x < 0 || y < 0 || x > @width || y > @height
    chunk_x = Math.floor(x / CHUNK_WIDTH)
    chunk_y = Math.floor(y / CHUNK_HEIGHT)
    chunk_index = chunk_y * @width + chunk_x
    load_promise = @refresh_callback(chunk_x, chunk_y, CHUNK_WIDTH, CHUNK_HEIGHT)

    if load_promise
      load_promise.then (data) =>
        if @chunk_info[chunk_index]?
          @chunk_info[chunk_index].update()
        else
          @chunk_info[chunk_index] = new ChunkInfo(chunk_x, chunk_y, CHUNK_WIDTH, CHUNK_HEIGHT, 5)

        @handle_refresh_callback(@chunk_info[chunk_index], data)

        @renderer?.trigger_refresh() if @refresh_on_load


  info_at: (x, y) ->
    chunk_x = Math.floor(x / CHUNK_WIDTH)
    chunk_y = Math.floor(y / CHUNK_HEIGHT)
    @chunk_info[chunk_y * @width + chunk_x]

export default ChunkMap
