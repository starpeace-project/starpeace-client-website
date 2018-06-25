
import ChunkMap from '~/plugins/starpeace-client/map/chunk/chunk-map.coffee'
import Overlay from '~/plugins/starpeace-client/map/overlay.coffee'

class OverlayMap
  constructor: (@client, @width, @height) ->
    @overlay_data = {}
    @overlay_chunks = {}

    for type in Object.keys(Overlay.TYPES)
      continue if type == 'NONE'
      do (type) =>
        @overlay_data[type] = new Array(@width * @height)
        @overlay_chunks[type] = new ChunkMap(@client, @width, @height, true, (chunk_x, chunk_y, chunk_width, chunk_height) =>
          @client.overlay_manager.load_chunk(type, chunk_x, chunk_y, chunk_width, chunk_height)
        , (chunk_info, data) =>
          console.debug "[STARPEACE] refreshing overlay chunk for #{type} at #{chunk_info.chunk_x}x#{chunk_info.chunk_y}"

          chunk_x_offset = chunk_info.x_offset()
          chunk_y_offset = chunk_info.y_offset()
          for y in [0...ChunkMap.CHUNK_HEIGHT]
            for x in [0...ChunkMap.CHUNK_WIDTH]
              chunk_index = y * ChunkMap.CHUNK_WIDTH + x
              @overlay_data[type][(y + chunk_y_offset) * @width + (x + chunk_x_offset)] = data[chunk_index] unless data[chunk_index]?.type == 'NONE'
        )
      true

  chunk_update_at: (type, x, y) -> @overlay_chunks[type]?.update_at(x, y)
  chunk_info_at: (type, x, y) -> @overlay_chunks[type]?.info_at(x, y)

  overlay_at: (type, x, y) -> @overlay_data[type]?[y * @width + x]

export default OverlayMap
