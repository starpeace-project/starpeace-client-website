
import ChunkInfo from '~/plugins/starpeace-client/map/chunk/chunk-info'

CHUNK_WIDTH = 20
CHUNK_HEIGHT = 20

CHUNK_STALE_MINUTES = 30

export default class ChunkMap
  @CHUNK_WIDTH = CHUNK_WIDTH
  @CHUNK_HEIGHT = CHUNK_HEIGHT

  constructor: (@width, @height, @refresh_callback, @handle_refresh_callback) ->
    chunk_width = Math.ceil(@width / CHUNK_WIDTH)
    chunk_height = Math.ceil(@height / CHUNK_HEIGHT)
    @chunk_info = new Array(chunk_width * chunk_height)

  stop: () -> @disabled = true

  update_at: (x, y) ->
    return if @disabled
    return if x < 0 || y < 0 || x > @width || y > @height
    chunk_x = Math.floor(x / CHUNK_WIDTH)
    chunk_y = Math.floor(y / CHUNK_HEIGHT)
    chunk_index = chunk_y * @width + chunk_x

    @chunk_info[chunk_index] = new ChunkInfo(chunk_x, chunk_y, CHUNK_WIDTH, CHUNK_HEIGHT, CHUNK_STALE_MINUTES) unless @chunk_info[chunk_index]?
    return if @chunk_info[chunk_index].refresh_promise?

    @chunk_info[chunk_index].refresh_promise = @refresh_callback(chunk_x, chunk_y, CHUNK_WIDTH, CHUNK_HEIGHT) # TODO: remove width & height
    @chunk_info[chunk_index].refresh_promise.then (data) =>
      return if @disabled
      @chunk_info[chunk_index].update()
      @handle_refresh_callback(@chunk_info[chunk_index], data)
      @chunk_info[chunk_index].refresh_promise = null

  info_at: (x, y) ->
    chunk_x = Math.floor(x / CHUNK_WIDTH)
    chunk_y = Math.floor(y / CHUNK_HEIGHT)
    @chunk_info[chunk_y * @width + chunk_x]
