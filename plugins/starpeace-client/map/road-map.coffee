
import ChunkMap from '~/plugins/starpeace-client/map/chunk/chunk-map.coffee'
import Road from '~/plugins/starpeace-client/road/road.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class RoadMap
  constructor: (client_state, @ground_map, @building_map, @concrete_map, @width, @height) ->
    @road_buffer = new Array(@width * @height)
    @road_info = new Array(@width * @height)

    client_state.planet.subscribe_map_data_listener (chunk_event) =>
      @refresh_roads(chunk_event.info.chunk_x, chunk_event.info.chunk_y) if chunk_event.type == 'building' || chunk_event.type == 'road'

  road_info_at: (x, y) -> @road_info[y * @width + x]

  refresh_roads: (chunk_x, chunk_y) ->
    source_x = (chunk_x - 0) * ChunkMap.CHUNK_WIDTH - 1
    target_x = (chunk_x + 1) * ChunkMap.CHUNK_WIDTH + 1
    source_y = (chunk_y - 0) * ChunkMap.CHUNK_HEIGHT - 1
    target_y = (chunk_y + 1) * ChunkMap.CHUNK_HEIGHT + 1

    @initialize(source_x, target_x, source_y, target_y)
    @populate_info(source_x, target_x, source_y, target_y)
    @fix_populated_info(source_x, target_x, source_y, target_y)

  initialize: (source_x, target_x, source_y, target_y) ->
    for y in [source_y...target_y]
      for x in [source_x...target_x]
        index = y * @width + x
        @road_buffer[index] = @building_map.tile_info_road[index]

  determine_road_by_neighbors: (is_bridge, is_road_n, is_road_s, is_road_e, is_road_w) ->
    return Road.TYPES.CROSS if is_road_n && is_road_s && is_road_e && is_road_w

    return Road.TYPES.T_NS_E if is_road_n && is_road_s && is_road_e
    return Road.TYPES.T_NS_W if is_road_n && is_road_s && is_road_w
    return Road.TYPES.T_EW_N if is_road_n && is_road_e && is_road_w
    return Road.TYPES.T_EW_S if is_road_s && is_road_e && is_road_w

    return Road.TYPES.NE_CORNER if is_road_n && is_road_e
    return Road.TYPES.NW_CORNER if is_road_n && is_road_w
    return Road.TYPES.SE_CORNER if is_road_s && is_road_e
    return Road.TYPES.SW_CORNER if is_road_s && is_road_w

    return (if is_bridge then Road.TYPES.BRIDGE_NS else Road.TYPES.NS) if is_road_n && is_road_s
    return (if is_bridge then Road.TYPES.BRIDGE_EW else Road.TYPES.EW) if is_road_e && is_road_w

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

        is_water = @ground_map.is_water_at(x, y)

        is_concrete_edge = @concrete_map.is_concrete_edge_at(x, y)
        is_concrete_around = @concrete_map.is_concrete_around(x, y)
        is_bridge = is_water && !is_concrete_around

        road_type = @determine_road_by_neighbors(is_bridge, has_n && @road_buffer[index_n] == true, has_s && @road_buffer[index_s] == true,
            has_e && @road_buffer[index_e] == true, has_w && @road_buffer[index_w] == true)

        if road_type?
          @road_info[index] = {
            type: road_type
            is_over_water: is_water
            is_bridge: is_bridge
            is_concrete_edge: is_concrete_edge
            is_city: is_concrete_around
          }

  fix_populated_info: (source_x, target_x, source_y, target_y) ->
    for y in [source_y...target_y]
      for x in [source_x...target_x]
        index = y * @width + x
        continue unless @road_info[index]?
        index_n = (y - 1) * @width + x
        index_s = (y + 1) * @width + x
        index_e = index + 1
        index_w = index - 1

        has_n = y >= 0
        has_s = y < @height
        has_e = x < @width
        has_w = x >= 0

        if !@road_info[index].is_over_water && @road_info[index].is_concrete_edge
          @road_info[index].type = Road.TYPES.CITY_N_COUNTRY_S if @road_info[index].type == Road.TYPES.NS && has_n && @road_info[index_n]?.is_city && !@road_info[index_n].is_concrete_edge
          @road_info[index].type = Road.TYPES.CITY_S_COUNTRY_N if @road_info[index].type == Road.TYPES.NS && has_s && @road_info[index_s]?.is_city && !@road_info[index_s].is_concrete_edge
          @road_info[index].type = Road.TYPES.CITY_E_COUNTRY_W if @road_info[index].type == Road.TYPES.EW && has_e && @road_info[index_e]?.is_city && !@road_info[index_e].is_concrete_edge
          @road_info[index].type = Road.TYPES.CITY_W_COUNTRY_E if @road_info[index].type == Road.TYPES.EW && has_w && @road_info[index_w]?.is_city && !@road_info[index_w].is_concrete_edge

        if @road_info[index]?.is_over_water
          n_connects_s = has_n && Road.connects_south(@road_info[index_n]?.type)
          s_connects_n = has_s && Road.connects_north(@road_info[index_s]?.type)
          e_connects_w = has_e && Road.connects_east(@road_info[index_e]?.type)
          w_connects_e = has_w && Road.connects_west(@road_info[index_w]?.type)

          if has_n && !@road_info[index_n]?.is_over_water && n_connects_s
            if @road_info[index].type == Road.TYPES.NS || @road_info[index].type == Road.TYPES.BRIDGE_NS
              @road_info[index].type = Road.TYPES.BRIDGE_S_RAMP
            else if Road.connects_north(@road_info[index].type)
              @road_info[index_n].type = Road.TYPES.BRIDGE_S_RAMP

          if has_s && !@road_info[index_s]?.is_over_water && s_connects_n
            if @road_info[index].type == Road.TYPES.NS || @road_info[index].type == Road.TYPES.BRIDGE_NS
              @road_info[index].type = Road.TYPES.BRIDGE_N_RAMP
            else if Road.connects_north(@road_info[index].type)
              @road_info[index_s].type = Road.TYPES.BRIDGE_N_RAMP

          if has_e && !@road_info[index_e]?.is_over_water && e_connects_w
            if @road_info[index].type == Road.TYPES.EW || @road_info[index].type == Road.TYPES.BRIDGE_EW
              @road_info[index].type = Road.TYPES.BRIDGE_W_RAMP
            else if Road.connects_west(@road_info[index].type)
              @road_info[index_e].type = Road.TYPES.BRIDGE_E_RAMP

          if has_w && !@road_info[index_w]?.is_over_water && w_connects_e
            if @road_info[index].type == Road.TYPES.EW || @road_info[index].type == Road.TYPES.BRIDGE_EW
              @road_info[index].type = Road.TYPES.BRIDGE_E_RAMP
            else if Road.connects_east(@road_info[index].type)
              @road_info[index_w].type = Road.TYPES.BRIDGE_W_RAMP

        else
          @road_info[index_n].type = Road.TYPES.BRIDGE_N_RAMP if Road.connects_south(@road_info[index].type) && has_n && @road_info[index_n]?.is_over_water && (@road_info[index_n].type == Road.TYPES.NS || @road_info[index_n].type == Road.TYPES.BRIDGE_NS)
          @road_info[index_s].type = Road.TYPES.BRIDGE_S_RAMP if Road.connects_north(@road_info[index].type) && has_s && @road_info[index_s]?.is_over_water && (@road_info[index_s].type == Road.TYPES.NS || @road_info[index_s].type == Road.TYPES.BRIDGE_NS)
          @road_info[index_e].type = Road.TYPES.BRIDGE_E_RAMP if Road.connects_east(@road_info[index].type) && has_e && @road_info[index_e]?.is_over_water && (@road_info[index_e].type == Road.TYPES.EW || @road_info[index_e].type == Road.TYPES.BRIDGE_EW)
          @road_info[index_w].type = Road.TYPES.BRIDGE_W_RAMP if Road.connects_west(@road_info[index].type) && has_w && @road_info[index_w]?.is_over_water && (@road_info[index_w].type == Road.TYPES.EW || @road_info[index_w].type == Road.TYPES.BRIDGE_EW)
