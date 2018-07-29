
import Logger from '~/plugins/starpeace-client/logger.coffee'

import ChunkMap from '~/plugins/starpeace-client/map/chunk/chunk-map.coffee'
import Road from '~/plugins/starpeace-client/map/types/road.coffee'

export default class RoadMap
  constructor: (event_listener, @ground_map, @building_map, @width, @height) ->
    @road_buffer = new Array(@width * @height)
    @road_info = new Array(@width * @height)

    event_listener.subscribe_map_data_listener (chunk_event) =>
      @refresh_roads(chunk_event.info.chunk_x, chunk_event.info.chunk_y) if chunk_event.type == 'building' || chunk_event.type == 'road'

  road_info_at: (x, y) -> @road_info[y * @width + x]

  refresh_roads: (chunk_x, chunk_y) ->
    source_x = (chunk_x - 0) * ChunkMap.CHUNK_WIDTH - 1
    target_x = (chunk_x + 1) * ChunkMap.CHUNK_WIDTH + 1
    source_y = (chunk_y - 0) * ChunkMap.CHUNK_HEIGHT - 1
    target_y = (chunk_y + 1) * ChunkMap.CHUNK_HEIGHT + 1

    @initialize(source_x, target_x, source_y, target_y)
    @populate_info(source_x, target_x, source_y, target_y)

  initialize: (source_x, target_x, source_y, target_y) ->
    for y in [source_y...target_y]
      for x in [source_x...target_x]
        index = y * @width + x
        @road_buffer[index] = @building_map.tile_info_road[index]

  determine_road_by_neighbors: (is_road_n, is_road_s, is_road_e, is_road_w) ->
    return Road.TYPES.CROSS if is_road_n && is_road_s && is_road_e && is_road_w

    return Road.TYPES.T_NS_E if is_road_n && is_road_s && is_road_e
    return Road.TYPES.T_NS_W if is_road_n && is_road_s && is_road_w
    return Road.TYPES.T_EW_N if is_road_n && is_road_e && is_road_w
    return Road.TYPES.T_EW_S if is_road_s && is_road_e && is_road_w

    return Road.TYPES.NE_CORNER if is_road_n && is_road_e
    return Road.TYPES.NW_CORNER if is_road_n && is_road_w
    return Road.TYPES.SE_CORNER if is_road_s && is_road_e
    return Road.TYPES.SW_CORNER if is_road_s && is_road_w

    return Road.TYPES.NS if is_road_n && is_road_s
    return Road.TYPES.EW if is_road_e && is_road_w

    null

  populate_info: (source_x, target_x, source_y, target_y) ->
    for y in [source_y...target_y]
      for x in [source_x...target_x]
        index = y * @width + x
        continue unless @road_buffer[index] == true

        has_n = y > 0
        has_s = y < @height
        has_e = x < @width
        has_w = x > 0

        index_n = (y - 1) * @width + x
        index_s = (y + 1) * @width + x
        index_e = index + 1
        index_w = index - 1

        road_type = @determine_road_by_neighbors(has_n && @road_buffer[index_n] == true, has_s && @road_buffer[index_s] == true,
            has_e && @road_buffer[index_e] == true, has_w && @road_buffer[index_w] == true)

        @road_info[index] = {
          type: road_type
          is_over_water: @ground_map.is_water_at(x, y)
          is_city: @building_map.is_city_around(x, y)
        } if road_type?