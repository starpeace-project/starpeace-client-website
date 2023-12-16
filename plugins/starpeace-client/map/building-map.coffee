import Logger from '~/plugins/starpeace-client/logger'

import Concrete from '~/plugins/starpeace-client/building/concrete.coffee'
import ChunkMap from '~/plugins/starpeace-client/map/chunk/chunk-map'

export default class BuildingMap
  constructor: (@client_state, @building_manager, @road_manager, @width, @height) ->
    @building_library = @client_state.core.building_library

    @tile_info_building_id = new Array(@width * @height)
    @tile_info_concrete = new Array(@width * @height)
    @tile_info_road = new Array(@width * @height)

    @building_chunks = new ChunkMap(@width, @height, ((chunk_x, chunk_y) => @building_manager.load_chunk(chunk_x, chunk_y)), (chunk_info, building_ids) =>
      Logger.debug("refreshing building chunk at #{chunk_info.chunk_x}x#{chunk_info.chunk_y}")
      @add_building(building_id) for building_id in building_ids
      @client_state.planet.notify_map_data_listeners({ type: 'building', info: chunk_info })
    )
    @road_chunks = new ChunkMap(@width, @height, ((chunk_x, chunk_y) => @road_manager.load_chunk(chunk_x, chunk_y)), (chunk_info, road_data) =>
      Logger.debug("refreshing road chunk at #{chunk_info.chunk_x}x#{chunk_info.chunk_y}")
      @update_roads(chunk_info, road_data)
      @client_state.planet.notify_map_data_listeners({ type: 'road', info: chunk_info })
    )

  stop: () ->
    @building_chunks.stop()
    @road_chunks.stop()

  chunk_building_update_at: (x, y) -> @building_chunks.update_at(x, y)
  chunk_building_info_at: (x, y) -> @building_chunks.info_at(x, y)
  chunk_road_update_at: (x, y) -> @road_chunks.update_at(x, y)
  chunk_road_info_at: (x, y) -> @road_chunks.info_at(x, y)

  building_id_at: (x, y) -> @tile_info_building_id[y * @width + x]
  has_concrete_at: (x, y) ->
    building_id = @building_id_at(x, y)
    building = if building_id? then @client_state.core.building_cache.building_for_id(building_id) else undefined
    metadata = if building? then @building_library.definition_for_id(building.definition_id) else null
    metadata?.foundation

  is_city_around: (x, y) ->
    y > 0 && @has_concrete_at(x, y - 1) ||
        y < @height && @has_concrete_at(x, y + 1) ||
        x > 0 && @has_concrete_at(x - 1, y) ||
        x < @width && @has_concrete_at(x + 1, y)

  add_building: (building_id) ->
    building = @client_state.core.building_cache.building_for_id(building_id)
    metadata = @building_library.metadata_by_id[building.definition_id]
    unless metadata?
      Logger.warn("unable to load building definition metadata for #{building.definition_id}")
      # FIXME: TODO: add dummy/empty placeholder
      return

    image_metadata = @building_library.images_by_id[metadata.imageId]
    unless image_metadata?
      Logger.warn("unable to load building image metadata for #{building.definition_id}")
      return

    for y in [0...image_metadata.h]
      for x in [0...image_metadata.w]
        map_index = (building.map_y - y) * @width + (building.map_x - x)
        @tile_info_building_id[map_index] = building_id
        @tile_info_concrete[map_index] = if metadata.foundation then Concrete.FILL_TYPE.FILLED else Concrete.FILL_TYPE.NO_FILL

  remove_building: (building_id) ->
    building = @client_state.core.building_cache.building_for_id(building_id)
    metadata = if building? then @building_library.metadata_by_id[building.definition_id] else null
    image_metadata = if metadata? then @building_library.images_by_id[metadata.imageId] else null

    unless metadata? && image_metadata?
      Logger.debug("unable to load building metadata for #{building_id} of type #{building?.definition_id || 'UNKNOWN'}")
      return

    for y in [0...image_metadata.h]
      for x in [0...image_metadata.w]
        map_index = (building.map_y - y) * @width + (building.map_x - x)
        delete @tile_info_building_id[map_index]
        delete @tile_info_concrete[map_index]

  update_roads: (chunk_info, road_data) ->
    for y in [0...ChunkMap.CHUNK_HEIGHT]
      for x in [0...ChunkMap.CHUNK_WIDTH]
        map_index = (chunk_info.chunk_y * ChunkMap.CHUNK_HEIGHT + y) * @width + (chunk_info.chunk_x * ChunkMap.CHUNK_WIDTH + x)
        @tile_info_road[map_index] = road_data[y * ChunkMap.CHUNK_WIDTH + x]
