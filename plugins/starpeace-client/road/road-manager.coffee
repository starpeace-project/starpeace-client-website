
import Logger from '~/plugins/starpeace-client/logger'

import ChunkMap from '~/plugins/starpeace-client/map/chunk/chunk-map'
import Road from '~/plugins/starpeace-client/road/road.coffee'
import MetadataRoad from '~/plugins/starpeace-client/road/metadata-road.coffee'

export default class RoadManager
  constructor: (@api, @asset_manager, @ajax_state, @client_state) ->

  queue_asset_load: () ->
    return if @client_state.core.road_library.has_assets() || @ajax_state.is_locked('assets.road_metadata', 'ALL')

    @ajax_state.lock('assets.road_metadata', 'ALL')
    @asset_manager.queue('metadata.road', './road.metadata.json', (resource) =>
      road_metadata = []
      for key,json of (resource.road || {})
        # FIXME: TODO: add ID to json, change from map to array
        json.id = key
        road_metadata.push MetadataRoad.from_json(json)

      @client_state.core.road_library.load_road_metadata(road_metadata)
      @client_state.core.road_library.load_required_atlases(resource.atlas)

      @asset_manager.queue_and_load_atlases((resource.atlas || []), (atlas_path, atlas) => @client_state.core.road_library.load_atlas(atlas_path, atlas))
      @ajax_state.unlock('assets.road_metadata', 'ALL')
    )

  load_chunk: (chunk_x, chunk_y) ->
    throw Error() if !@client_state.has_session() || !chunk_x? || !chunk_y?

    Logger.debug("attempting to load road chunk at #{chunk_x}x#{chunk_y}")
    await @ajax_state.locked('planet_roads', "#{chunk_x}x#{chunk_y}", =>
      road_data = await @api.road_data_for_planet(chunk_x, chunk_y)
      return new Array(ChunkMap.CHUNK_WIDTH, ChunkMap.CHUNK_HEIGHT) unless road_data?

      data = new Uint8Array(road_data.length * 2)
      for index in [0...road_data.length]
        data[index * 2 + 0] = (road_data[index] & 0xF0) >> 4
        data[index * 2 + 1] = (road_data[index] & 0x0F)
      data
    )
