
import Logger from '~/plugins/starpeace-client/logger.coffee'

import BuildingZone from '~/plugins/starpeace-client/overlay/building-zone.coffee'
import Concrete from '~/plugins/starpeace-client/building/concrete.coffee'
import ChunkMap from '~/plugins/starpeace-client/map/chunk/chunk-map.coffee'

export default class BuildingMap
  constructor: (@client_state, @building_manager, @road_manager, @width, @height) ->
    @tile_info_building = new Array(@width * @height)
    @tile_info_concrete = new Array(@width * @height)
    @tile_info_road = new Array(@width * @height)

    @building_chunks = new ChunkMap(@width, @height, (chunk_x, chunk_y, chunk_width, chunk_height) =>
      @building_manager.load_chunk(chunk_x, chunk_y, chunk_width, chunk_height)
    , (chunk_info, building_ids) =>
      Logger.debug("refreshing building chunk at #{chunk_info.chunk_x}x#{chunk_info.chunk_y}")
      @add_building(building_id) for building_id in building_ids
      @client_state.planet.notify_map_data_listeners({ type: 'building', info: chunk_info })
    )
    @road_chunks = new ChunkMap(@width, @height, (chunk_x, chunk_y, chunk_width, chunk_height) =>
      @road_manager.load_chunk(chunk_x, chunk_y, chunk_width, chunk_height)
    , (chunk_info, road_data) =>
      Logger.debug("refreshing road chunk at #{chunk_info.chunk_x}x#{chunk_info.chunk_y}")
      @update_roads(chunk_info, road_data)
      @client_state.planet.notify_map_data_listeners({ type: 'road', info: chunk_info })
    )

  chunk_building_update_at: (x, y) -> @building_chunks.update_at(x, y)
  chunk_building_info_at: (x, y) -> @building_chunks.info_at(x, y)
  chunk_road_update_at: (x, y) -> @road_chunks.update_at(x, y)
  chunk_road_info_at: (x, y) -> @road_chunks.info_at(x, y)

  building_info_at: (x, y) -> @tile_info_building[y * @width + x]
  is_city_around: (x, y) ->
    y > 0 && @building_info_at(x, y - 1)?.has_concrete == true ||
        y < @height && @building_info_at(x, y + 1)?.has_concrete == true ||
        x > 0 && @building_info_at(x - 1, y)?.has_concrete == true ||
        x < @width && @building_info_at(x + 1, y)?.has_concrete == true

  is_road_junction: (x, y) ->
    index = y * @width + x
    index_n = (y - 1) * @width + x
    index_s = (y + 1) * @width + x
    index_e = index + 1
    index_w = index - 1
    (@tile_info_road[index_n] || @tile_info_road[index_s]) && (@tile_info_road[index_e] || @tile_info_road[index_w])

  add_building: (building_id) ->
    building = @client_state.core.building_cache.building_metadata_by_id[building_id]
    metadata = @client_state.core.building_library.metadata_by_id[building.key]
    unless metadata?
      Logger.debug("unable to load building definition metadata for #{building.key}")
      # FIXME: TODO: add dummy/empty placeholder
      return

    image_metadata = @client_state.core.building_library.images_by_id[metadata.image_id]
    unless image_metadata?
      Logger.debug("unable to load building image metadata for #{building.key}")
      return

    building.has_concrete = has_concrete = metadata.zone != BuildingZone.TYPES.NONE.type && metadata.zone != BuildingZone.TYPES.INDUSTRIAL.type && metadata.zone != BuildingZone.TYPES.WAREHOUSE.type
    for y in [0...image_metadata.h]
      for x in [0...image_metadata.w]
        map_index = (building.y - y) * @width + (building.x - x)
        @tile_info_building[map_index] = building
        @tile_info_concrete[map_index] = if has_concrete then Concrete.FILL_TYPE.FILLED else Concrete.FILL_TYPE.NO_FILL

  update_roads: (chunk_info, road_data) ->
    for y in [0...ChunkMap.CHUNK_HEIGHT]
      for x in [0...ChunkMap.CHUNK_WIDTH]
        map_index = (chunk_info.chunk_y * ChunkMap.CHUNK_HEIGHT + y) * @width + (chunk_info.chunk_x * ChunkMap.CHUNK_WIDTH + x)
        @tile_info_road[map_index] = if road_data[y * ChunkMap.CHUNK_WIDTH + x] then true else null
