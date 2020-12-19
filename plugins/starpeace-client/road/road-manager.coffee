
import Logger from '~/plugins/starpeace-client/logger.coffee'

import Road from '~/plugins/starpeace-client/road/road.coffee'
import MetadataRoad from '~/plugins/starpeace-client/road/metadata-road.coffee'

X_START = 190
X_END = 250
Y_START = 50
Y_END = 400
X_WITH_ROAD = new Set([X_START, 210, 230, X_END])

DUMMY_CHUNK_DATA = {}
DUMMY_ROAD_DATA = []

for y in [Y_START..Y_END] by 1
  for x in [X_START..X_END] by 1
    continue unless (y % 10 == 0 || X_WITH_ROAD.has(x))
    chunk_x = Math.floor(x/20)
    chunk_y = Math.floor(y/20)
    chunk_key = "#{chunk_x}x#{chunk_y}"
    DUMMY_CHUNK_DATA[chunk_key] = {
      chunk_x: chunk_x
      chunk_y: chunk_y
      width: 20
      height: 20
      data: new Array(20 * 20).fill(false)
    } unless DUMMY_CHUNK_DATA[chunk_key]?

    index = 20 * (y - chunk_y * 20) + (x - chunk_x * 20)
    DUMMY_CHUNK_DATA[chunk_key].data[index] = true
    DUMMY_ROAD_DATA[1000 * y + x] = true

  # y += (Math.round(15 * Math.random()) - 5)


export default class RoadManager
  @DUMMY_ROAD_DATA: DUMMY_ROAD_DATA

  constructor: (@asset_manager, @ajax_state, @client_state) ->
    @chunk_promises = {}

  queue_asset_load: () ->
    return if @client_state.core.road_library.has_assets() || @ajax_state.is_locked('assets.road_metadata', 'ALL')

    @ajax_state.lock('assets.road_metadata', 'ALL')
    @asset_manager.queue('metadata.road', './road.metadata.json', (resource) =>
      road_metadata = []
      for key,json of (resource.data?.road || {})
        # FIXME: TODO: add ID to json, change from map to array
        json.id = key
        road_metadata.push MetadataRoad.from_json(json)

      @client_state.core.road_library.load_road_metadata(road_metadata)
      @client_state.core.road_library.load_required_atlases(resource.data?.atlas)

      @asset_manager.queue_and_load_atlases((resource.data?.atlas || []), (atlas_path, atlas) => @client_state.core.road_library.load_atlas(atlas_path, atlas))
      @ajax_state.unlock('assets.road_metadata', 'ALL')
    )

  load_chunk: (chunk_x, chunk_y, width, height) ->
    key = "#{chunk_x}x#{chunk_y}"
    return if @chunk_promises[key]?

    Logger.debug("attempting to load road chunk at #{chunk_x}x#{chunk_y}")
    @ajax_state.start_ajax()
    @chunk_promises[key] = new Promise (done) =>
      data = new Array(width, height).fill(false)

      chunk = DUMMY_CHUNK_DATA[key]
      data = chunk.data if chunk?

      setTimeout(=>
        delete @chunk_promises[key]
        @ajax_state.finish_ajax()
        done(data)
      , 500)
