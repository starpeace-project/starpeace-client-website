
import Logger from '~/plugins/starpeace-client/logger.coffee'

import Concrete from '~/plugins/starpeace-client/building/concrete.coffee'
import ChunkMap from '~/plugins/starpeace-client/map/chunk/chunk-map.coffee'

export default class ConcreteMap
  constructor: (client_state, @ground_map, @building_map, @width, @height) ->
    @concrete_fill_types = new Array(@width * @height)
    @concrete_post_process = new Array(@width * @height)
    @concrete_info = new Array(@width * @height)

    client_state.planet.subscribe_map_data_listener (chunk_event) =>
      @refresh_concrete(chunk_event.info.chunk_x, chunk_event.info.chunk_y) if chunk_event.type == 'building' || chunk_event.type == 'road'

  concrete_info_at: (x, y) -> @concrete_info[y * @width + x]
  is_concrete_at: (x, y) -> @concrete_fill_types[y * @width + x] == Concrete.FILL_TYPE.FILLED
  is_concrete_edge_at: (x, y) -> @concrete_fill_types[y * @width + x] == Concrete.FILL_TYPE.EDGE
  is_concrete_around: (x, y) ->
    index = y * @width + x
    index_n = (y - 1) * @width + x
    index_s = (y + 1) * @width + x
    index_e = index + 1
    index_w = index - 1
    @concrete_fill_types[index_n] == Concrete.FILL_TYPE.FILLED ||
        @concrete_fill_types[index_s] == Concrete.FILL_TYPE.FILLED ||
        @concrete_fill_types[index_e] == Concrete.FILL_TYPE.FILLED ||
        @concrete_fill_types[index_w] == Concrete.FILL_TYPE.FILLED


  refresh_concrete: (chunk_x, chunk_y) ->
    source_x = (chunk_x - 0) * ChunkMap.CHUNK_WIDTH - 10
    target_x = (chunk_x + 1) * ChunkMap.CHUNK_WIDTH + 10
    source_y = (chunk_y - 0) * ChunkMap.CHUNK_HEIGHT - 10
    target_y = (chunk_y + 1) * ChunkMap.CHUNK_HEIGHT + 10

    @reset_concrete_from_raw(source_x, target_x, source_y, target_y)

    platform_iterations = 0
    changed = true
    while changed
      changed = false
      changed = true if @fill_concrete_gaps(source_x, target_x, source_y, target_y)
      changed = true if @fill_road_concrete(source_x, target_x, source_y, target_y)
      changed = true if @fill_platform_concrete(source_x, target_x, source_y, target_y)

      platform_iterations += 1
      break if platform_iterations > 3

    @add_edges(source_x, target_x, source_y, target_y)
    @populate_info(source_x, target_x, source_y, target_y)
    @fix_populated_info(source_x, target_x, source_y, target_y)

  reset_concrete_from_raw: (source_x, target_x, source_y, target_y) ->
    for y in [source_y...target_y]
      for x in [source_x...target_x]
        index = y * @width + x
        is_road = @building_map.tile_info_road[index] > 0
        @concrete_fill_types[index] = @building_map.tile_info_concrete[index]
        @concrete_fill_types[index] = Concrete.FILL_TYPE.FILL if is_road && @building_map.is_city_around(x, y)
        @concrete_fill_types[index] = Concrete.FILL_TYPE.NO_FILL if @ground_map.is_coast_at(x, y)

  fill_concrete_gaps: (source_x, target_x, source_y, target_y) ->
    did_change = false
    for y in [source_y...target_y]
      for x in [source_x...target_x]
        index = y * @width + x
        continue if @concrete_fill_types[index] == Concrete.FILL_TYPE.NO_FILL || @concrete_fill_types[index] == Concrete.FILL_TYPE.FILLED

        index_n = (y - 1) * @width + x
        index_s = (y + 1) * @width + x
        index_e = index + 1
        index_w = index - 1

        if @concrete_fill_types[index_n] == Concrete.FILL_TYPE.FILLED && @concrete_fill_types[index_s] == Concrete.FILL_TYPE.FILLED ||
            @concrete_fill_types[index_e] == Concrete.FILL_TYPE.FILLED && @concrete_fill_types[index_w] == Concrete.FILL_TYPE.FILLED
          @concrete_fill_types[index] = Concrete.FILL_TYPE.FILLED
          did_change = true
          continue
    did_change

  fill_road_concrete: (source_x, target_x, source_y, target_y) ->
    did_change = false
    for y in [source_y...target_y]
      for x in [source_x...target_x]
        index = y * @width + x
        continue if @concrete_fill_types[index] == Concrete.FILL_TYPE.NO_FILL || @concrete_fill_types[index] == Concrete.FILL_TYPE.FILLED || !@building_map.tile_info_road[index]

        index_n = (y - 1) * @width + x
        index_s = (y + 1) * @width + x
        index_e = index + 1
        index_w = index - 1

        filled_n = @concrete_fill_types[index_n] == Concrete.FILL_TYPE.FILLED
        filled_s = @concrete_fill_types[index_s] == Concrete.FILL_TYPE.FILLED
        filled_e = @concrete_fill_types[index_e] == Concrete.FILL_TYPE.FILLED
        filled_w = @concrete_fill_types[index_w] == Concrete.FILL_TYPE.FILLED

        is_junction = (@building_map.tile_info_road[index] & 0x0F) == 0x0F
        is_road_n = @building_map.tile_info_road[index_n] > 0
        is_road_s = @building_map.tile_info_road[index_s] > 0
        is_road_e = @building_map.tile_info_road[index_e] > 0
        is_road_w = @building_map.tile_info_road[index_w] > 0

        should_fill = false
        if @ground_map.is_water_at(x, y)
          should_fill = true if is_junction
        else
          should_fill = (filled_n && (is_junction || !is_road_n)) ||
              (filled_s && (is_junction || !is_road_s)) ||
              (filled_e && (is_junction || !is_road_e)) ||
              (filled_w && (is_junction || !is_road_w))

        if should_fill
          @concrete_fill_types[index] = Concrete.FILL_TYPE.FILLED
          did_change = true
          continue
    did_change

  fill_platform_concrete: (source_x, target_x, source_y, target_y) ->
    did_change = false
    for y in [source_y...target_y]
      for x in [source_x...target_x]
        index = y * @width + x
        continue if @concrete_fill_types[index] == Concrete.FILL_TYPE.NO_FILL || @concrete_fill_types[index] == Concrete.FILL_TYPE.FILLED || !@ground_map.is_water_at(x, y)

        index_n = (y - 1) * @width + x
        index_s = (y + 1) * @width + x
        index_e = index + 1
        index_w = index - 1

        if (@concrete_fill_types[index_e] == Concrete.FILL_TYPE.FILLED && @concrete_fill_types[index_s] == Concrete.FILL_TYPE.FILLED) ||
            (@concrete_fill_types[index_w] == Concrete.FILL_TYPE.FILLED && @concrete_fill_types[index_s] == Concrete.FILL_TYPE.FILLED) ||
            (@concrete_fill_types[index_e] == Concrete.FILL_TYPE.FILLED && @concrete_fill_types[index_n] == Concrete.FILL_TYPE.FILLED) ||
            (@concrete_fill_types[index_w] == Concrete.FILL_TYPE.FILLED && @concrete_fill_types[index_n] == Concrete.FILL_TYPE.FILLED)
          @concrete_fill_types[index] = Concrete.FILL_TYPE.FILLED
          did_change = true
          continue
    did_change

  add_edges: (source_x, target_x, source_y, target_y) ->
    did_change = false
    for y in [source_y...target_y]
      for x in [source_x...target_x]
        index = y * @width + x
        continue if @concrete_fill_types[index] == Concrete.FILL_TYPE.NO_FILL || @concrete_fill_types[index] == Concrete.FILL_TYPE.FILLED || @concrete_fill_types[index] == Concrete.FILL_TYPE.EDGE

        index_n = (y - 1) * @width + x
        index_s = (y + 1) * @width + x
        index_e = index + 1
        index_w = index - 1
        index_ne = (y - 1) * @width + x - 1
        index_nw = (y - 1) * @width + x + 1
        index_se = (y + 1) * @width + x - 1
        index_sw = (y + 1) * @width + x + 1

        if @concrete_fill_types[index_n] == Concrete.FILL_TYPE.FILLED || @concrete_fill_types[index_s] == Concrete.FILL_TYPE.FILLED ||
            @concrete_fill_types[index_e] == Concrete.FILL_TYPE.FILLED || @concrete_fill_types[index_w] == Concrete.FILL_TYPE.FILLED ||
            @concrete_fill_types[index_ne] == Concrete.FILL_TYPE.FILLED || @concrete_fill_types[index_nw] == Concrete.FILL_TYPE.FILLED ||
            @concrete_fill_types[index_se] == Concrete.FILL_TYPE.FILLED || @concrete_fill_types[index_sw] == Concrete.FILL_TYPE.FILLED
          @concrete_fill_types[index] = Concrete.FILL_TYPE.EDGE
          did_change = true
          continue
    did_change

  concrete_edge_type: (is_road, use_platform, x, y) ->
    index = y * @width + x
    index_n = (y - 1) * @width + x
    index_s = (y + 1) * @width + x
    index_e = index + 1
    index_w = index - 1
    index_ne = (y - 1) * @width + x - 1
    index_nw = (y - 1) * @width + x + 1
    index_se = (y + 1) * @width + x - 1
    index_sw = (y + 1) * @width + x + 1

    return Concrete.TYPES.PLATFORM_CENTER if is_road && use_platform

    return (if use_platform then Concrete.TYPES.PLATFORM_EDGE_SE else Concrete.TYPES.EDGE_SW_OUTER) if @concrete_fill_types[index_n] == Concrete.FILL_TYPE.FILLED && @concrete_fill_types[index_w] == Concrete.FILL_TYPE.FILLED
    return (if use_platform then Concrete.TYPES.PLATFORM_EDGE_NE else Concrete.TYPES.EDGE_SE_OUTER) if @concrete_fill_types[index_w] == Concrete.FILL_TYPE.FILLED && @concrete_fill_types[index_s] == Concrete.FILL_TYPE.FILLED
    return (if use_platform then Concrete.TYPES.PLATFORM_EDGE_NW else Concrete.TYPES.EDGE_NE_OUTER) if @concrete_fill_types[index_s] == Concrete.FILL_TYPE.FILLED && @concrete_fill_types[index_e] == Concrete.FILL_TYPE.FILLED
    return (if use_platform then Concrete.TYPES.PLATFORM_EDGE_SW else Concrete.TYPES.EDGE_NW_OUTER) if @concrete_fill_types[index_e] == Concrete.FILL_TYPE.FILLED && @concrete_fill_types[index_n] == Concrete.FILL_TYPE.FILLED

    return (if use_platform then Concrete.TYPES.PLATFORM_EDGE_S else (if is_road then Concrete.TYPES.EDGE_W_FLAT else Concrete.TYPES.EDGE_W)) if @concrete_fill_types[index_n] == Concrete.FILL_TYPE.FILLED
    return (if use_platform then Concrete.TYPES.PLATFORM_EDGE_W else (if is_road then Concrete.TYPES.EDGE_S_FLAT else Concrete.TYPES.EDGE_S)) if @concrete_fill_types[index_w] == Concrete.FILL_TYPE.FILLED
    return (if use_platform then Concrete.TYPES.PLATFORM_EDGE_N else (if is_road then Concrete.TYPES.EDGE_E_FLAT else Concrete.TYPES.EDGE_E)) if @concrete_fill_types[index_s] == Concrete.FILL_TYPE.FILLED
    return (if use_platform then Concrete.TYPES.PLATFORM_EDGE_E else (if is_road then Concrete.TYPES.EDGE_N_FLAT else Concrete.TYPES.EDGE_N)) if @concrete_fill_types[index_e] == Concrete.FILL_TYPE.FILLED

    return (if use_platform then Concrete.TYPES.PLATFORM_EDGE_SE else Concrete.TYPES.EDGE_SW_INNER) if @concrete_fill_types[index_ne] == Concrete.FILL_TYPE.FILLED
    return (if use_platform then Concrete.TYPES.PLATFORM_EDGE_NE else Concrete.TYPES.EDGE_SE_INNER) if @concrete_fill_types[index_se] == Concrete.FILL_TYPE.FILLED
    return (if use_platform then Concrete.TYPES.PLATFORM_EDGE_NW else Concrete.TYPES.EDGE_NE_INNER) if @concrete_fill_types[index_sw] == Concrete.FILL_TYPE.FILLED
    return (if use_platform then Concrete.TYPES.PLATFORM_EDGE_SW else Concrete.TYPES.EDGE_NW_INNER) if @concrete_fill_types[index_nw] == Concrete.FILL_TYPE.FILLED

    null

  populate_info: (source_x, target_x, source_y, target_y) ->
    for y in [source_y...target_y]
      for x in [source_x...target_x]
        index = y * @width + x

        is_road = @building_map.tile_info_road[y * @width + x] > 0
        is_water = @ground_map.is_water_at(x, y)
        is_coast = @ground_map.is_coast_at(x, y)
        if @concrete_fill_types[index] == Concrete.FILL_TYPE.FILLED
          if is_water
            @concrete_info[index] = { type: Concrete.TYPES.PLATFORM_CENTER }
          else
            unless @building_map.tile_info_building[y * @width + x]? || is_road || (x % 2 == 1) ^ (y % 2 == 1)
              @concrete_info[index] = { type: Concrete.TYPES.CENTER_TREEABLE }
            else
              @concrete_info[index] = { type: Concrete.TYPES.CENTER }
        else if @concrete_fill_types[index] == Concrete.FILL_TYPE.EDGE
          concrete_type = @concrete_edge_type(is_road, is_water, x, y)
          @concrete_info[index] = { type: concrete_type } if concrete_type?
        else
          @concrete_info[index] = null

  fix_populated_info: (source_x, target_x, source_y, target_y) ->
    for y in [source_y...target_y]
      for x in [source_x...target_x]
        index = y * @width + x
        index_n = (y - 1) * @width + x
        index_s = (y + 1) * @width + x
        index_e = index + 1
        index_w = index - 1

        # TODO: FIXME: remove any invalid platforms (single edges)

        # # TODO: probably don't need this anymore, can't connect
        # @concrete_info[index]?.type = Concrete.TYPES.EDGE_NW_OUTER_S if @concrete_info[index]?.type == Concrete.TYPES.EDGE_W && @concrete_info[index_e]?.type == Concrete.TYPES.PLATFORM_EDGE_S
        # @concrete_info[index]?.type = Concrete.TYPES.EDGE_SE_OUTER_N if @concrete_info[index]?.type == Concrete.TYPES.EDGE_E && @concrete_info[index_w]?.type == Concrete.TYPES.PLATFORM_EDGE_N
        # @concrete_info[index]?.type = Concrete.TYPES.EDGE_SE_OUTER_E if @concrete_info[index]?.type == Concrete.TYPES.EDGE_S && @concrete_info[index_s]?.type == Concrete.TYPES.PLATFORM_EDGE_W
