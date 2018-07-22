
###
global PIXI
###

import Logger from '~/plugins/starpeace-client/logger.coffee'

import ChunkMap from '~/plugins/starpeace-client/map/chunk/chunk-map.coffee'
import BuildingZone from '~/plugins/starpeace-client/map/types/building-zone.coffee'
import Concrete from '~/plugins/starpeace-client/map/types/concrete.coffee'

export default class ConcreteMap
  constructor: (@ground_map, @building_manager, @renderer, @width, @height) ->
    @concrete_pre_process = new Array(@width * @height)
    @concrete_post_process = new Array(@width * @height)
    @concrete_info = new Array(@width * @height)

  concrete_pre_process_at: (x, y) -> @concrete_pre_process[y * @width + x]
  concrete_post_process_at: (x, y) -> @concrete_post_process[y * @width + x]
  concrete_info_at: (x, y) -> @concrete_info[y * @width + x]

  concrete_outline: (type, sw_x, sw_y, width, height) ->
    for y in [0...height]
      @concrete_types[(sw_y - y) * @width + (sw_x - 0)] = type if (@concrete_types[(sw_y - y) * @width + (sw_x - 0)]?.priority || 10) >= type.priority
      @concrete_types[(sw_y - y) * @width + (sw_x - width + 1)] = type if (@concrete_types[(sw_y - y) * @width + (sw_x - width + 1)]?.priority || 10) >= type.priority

    for x in [0...width]
      @concrete_types[(sw_y - 0) * @width + (sw_x - x)] = type if (@concrete_types[(sw_y - 0) * @width + (sw_x - x)]?.priority || 10) >= type.priority
      @concrete_types[(sw_y - height + 1) * @width + (sw_x - x)] = type if (@concrete_types[(sw_y - height + 1) * @width + (sw_x - x)]?.priority || 10) >= type.priority

  refresh_concrete: (chunk_x, chunk_y) ->
    source_x = (chunk_x - 0) * ChunkMap.CHUNK_WIDTH - 10
    target_x = (chunk_x + 1) * ChunkMap.CHUNK_WIDTH + 10
    source_y = (chunk_y - 0) * ChunkMap.CHUNK_HEIGHT - 10
    target_y = (chunk_y + 1) * ChunkMap.CHUNK_HEIGHT + 10

    @reset_concrete(source_x, target_x, source_y, target_y)
    @fill_concrete(source_x, target_x, source_y, target_y)

    @merge_platforms(source_x, target_x, source_y, target_y)
    #merge_platforms
    #fix_edges
    #add_buffer

    @populate_info(source_x, target_x, source_y, target_y)


  concrete_for_neighbors: (use_platform, neighbor_n, neighbor_ne, neighbor_e, neighbor_se, neighbor_s, neighbor_sw, neighbor_w, neighbor_nw) ->
    return (if use_platform then Concrete.TYPES.PLATFORM_CENTER else Concrete.TYPES.CENTER_TREEABLE) if neighbor_n && neighbor_s || neighbor_e && neighbor_w

    return (if use_platform then Concrete.TYPES.PLATFORM_EDGE_SE else Concrete.TYPES.EDGE_SW_OUTER) if neighbor_n && neighbor_e
    return (if use_platform then Concrete.TYPES.PLATFORM_EDGE_NE else Concrete.TYPES.EDGE_SE_OUTER) if neighbor_e && neighbor_s
    return (if use_platform then Concrete.TYPES.PLATFORM_EDGE_NW else Concrete.TYPES.EDGE_NE_OUTER) if neighbor_s && neighbor_w
    return (if use_platform then Concrete.TYPES.PLATFORM_EDGE_SW else Concrete.TYPES.EDGE_NW_OUTER) if neighbor_w && neighbor_n

    return (if use_platform then Concrete.TYPES.PLATFORM_CENTER else Concrete.TYPES.CENTER_TREEABLE) if neighbor_w && neighbor_se || neighbor_n && neighbor_sw || neighbor_e && neighbor_nw || neighbor_s && neighbor_ne

    return (if use_platform then Concrete.TYPES.PLATFORM_EDGE_S else Concrete.TYPES.EDGE_W) if neighbor_n
    return (if use_platform then Concrete.TYPES.PLATFORM_EDGE_W else Concrete.TYPES.EDGE_S) if neighbor_e
    return (if use_platform then Concrete.TYPES.PLATFORM_EDGE_N else Concrete.TYPES.EDGE_E) if neighbor_s
    return (if use_platform then Concrete.TYPES.PLATFORM_EDGE_E else Concrete.TYPES.EDGE_N) if neighbor_w

    return (if use_platform then Concrete.TYPES.PLATFORM_EDGE_SE else Concrete.TYPES.EDGE_SW_INNER) if neighbor_ne
    return (if use_platform then Concrete.TYPES.PLATFORM_EDGE_NE else Concrete.TYPES.EDGE_SE_INNER) if neighbor_se
    return (if use_platform then Concrete.TYPES.PLATFORM_EDGE_SW else Concrete.TYPES.EDGE_NE_INNER) if neighbor_sw
    return (if use_platform then Concrete.TYPES.PLATFORM_EDGE_NW else Concrete.TYPES.EDGE_NW_INNER) if neighbor_nw

    null

  neighbor_concrete: (x, y) ->
    type = @concrete_post_process[y * @width + x]
    type == Concrete.TYPES.CENTER || type == Concrete.TYPES.CENTER_TREEABLE || type == Concrete.TYPES.PLATFORM_CENTER

  reset_concrete: (source_x, target_x, source_y, target_y) ->
    for y in [source_y...target_y]
      for x in [source_x...target_x]
        index = y * @width + x
        @concrete_post_process[index] = @concrete_pre_process[index]
        true

  fill_concrete: (source_x, target_x, source_y, target_y) ->
    did_change_concrete = true
    while did_change_concrete
      did_change_concrete = false
      for y in [source_y...target_y]
        for x in [source_x...target_x]
          index = y * @width + x
          continue if @concrete_post_process[index] == Concrete.TYPES.CENTER || @concrete_post_process[index] == Concrete.TYPES.CENTER_TREEABLE ||
              @concrete_post_process[index] == Concrete.TYPES.PLATFORM_CENTER || @concrete_post_process[index] == Concrete.TYPES.BUFFER

          is_water = @ground_map.ground_at(x, y).zone == 'water' || @ground_map.ground_at(x - 1, y).zone == 'water' || @ground_map.ground_at(x + 1, y).zone == 'water' ||
              @ground_map.ground_at(x, y - 1).zone == 'water' || @ground_map.ground_at(x, y + 1).zone == 'water' ||
              @ground_map.ground_at(x - 1, y - 1).zone == 'water' || @ground_map.ground_at(x - 1, y + 1).zone == 'water' ||
              @ground_map.ground_at(x + 1, y - 1).zone == 'water' || @ground_map.ground_at(x + 1, y + 1).zone == 'water'

          neighbor_n = @neighbor_concrete(x - 0, y - 1)
          neighbor_ne = @neighbor_concrete(x - 1, y - 1)
          neighbor_e = @neighbor_concrete(x - 1, y - 0)
          neighbor_se = @neighbor_concrete(x - 1, y + 1)
          neighbor_s = @neighbor_concrete(x - 0, y + 1)
          neighbor_sw = @neighbor_concrete(x + 1, y + 1)
          neighbor_w = @neighbor_concrete(x + 1, y - 0)
          neighbor_nw = @neighbor_concrete(x + 1, y - 1)

          @concrete_post_process[index] = @concrete_for_neighbors(is_water, neighbor_n, neighbor_ne, neighbor_e, neighbor_se, neighbor_s, neighbor_sw, neighbor_w, neighbor_nw)
          did_change_concrete = did_change_concrete || @concrete_post_process[index] == Concrete.TYPES.CENTER || @concrete_post_process[index] == Concrete.TYPES.CENTER_TREEABLE || @concrete_post_process[index] == Concrete.TYPES.PLATFORM_CENTER

  populate_info: (source_x, target_x, source_y, target_y) ->
    for y in [source_y...target_y]
      for x in [source_x...target_x]
        index = y * @width + x
        concrete_type = @concrete_post_process[index]
        if concrete_type == Concrete.TYPES.CENTER_TREEABLE
          @concrete_info[index] = if (x % 2 == 1) ^ (y % 2 == 1) then { type: Concrete.TYPES.CENTER_TREEABLE } else { type: Concrete.TYPES.CENTER }
        else if concrete_type?
          @concrete_info[index] = { type: concrete_type }
        else
          @concrete_info[index] = null

  merge_platforms: (source_x, target_x, source_y, target_y) ->
    did_change_concrete = true
    while did_change_concrete
      did_change_concrete = false
      for y in [source_y...target_y]
        for x in [source_x...target_x]
          index = y * @width + x
          original_type = @concrete_post_process[index]
          continue unless original_type?.is_platform

          changed = false
          index_n = (y - 1) * @width + x
          index_s = (y + 1) * @width + x
          index_e = index + 1
          index_w = index - 1

          @concrete_post_process[index] = Concrete.TYPES.PLATFORM_EDGE_N if @concrete_post_process[index] == Concrete.TYPES.PLATFORM_EDGE_NE && @concrete_post_process[index_e]?.is_platform
          @concrete_post_process[index] = Concrete.TYPES.PLATFORM_EDGE_W if @concrete_post_process[index] == Concrete.TYPES.PLATFORM_EDGE_NE && @concrete_post_process[index_n]?.is_platform

          @concrete_post_process[index] = Concrete.TYPES.PLATFORM_EDGE_N if @concrete_post_process[index] == Concrete.TYPES.PLATFORM_EDGE_NW && @concrete_post_process[index_w]?.is_platform
          @concrete_post_process[index] = Concrete.TYPES.PLATFORM_EDGE_E if @concrete_post_process[index] == Concrete.TYPES.PLATFORM_EDGE_NW && @concrete_post_process[index_n]?.is_platform

          @concrete_post_process[index] = Concrete.TYPES.PLATFORM_EDGE_S if @concrete_post_process[index] == Concrete.TYPES.PLATFORM_EDGE_SW && @concrete_post_process[index_w]?.is_platform
          @concrete_post_process[index] = Concrete.TYPES.PLATFORM_EDGE_E if @concrete_post_process[index] == Concrete.TYPES.PLATFORM_EDGE_SW && @concrete_post_process[index_s]?.is_platform

          @concrete_post_process[index] = Concrete.TYPES.PLATFORM_EDGE_S if @concrete_post_process[index] == Concrete.TYPES.PLATFORM_EDGE_SE && @concrete_post_process[index_e]?.is_platform
          @concrete_post_process[index] = Concrete.TYPES.PLATFORM_EDGE_W if @concrete_post_process[index] == Concrete.TYPES.PLATFORM_EDGE_SE && @concrete_post_process[index_s]?.is_platform

          @concrete_post_process[index] = Concrete.TYPES.PLATFORM_CENTER if @concrete_post_process[index] == Concrete.TYPES.PLATFORM_EDGE_N && @concrete_post_process[index_n]?.is_platform ||
              @concrete_post_process[index] == Concrete.TYPES.PLATFORM_EDGE_S && @concrete_post_process[index_s]?.is_platform ||
              @concrete_post_process[index] == Concrete.TYPES.PLATFORM_EDGE_W && @concrete_post_process[index_e]?.is_platform ||
              @concrete_post_process[index] == Concrete.TYPES.PLATFORM_EDGE_E && @concrete_post_process[index_w]?.is_platform

          did_change_concrete = did_change_concrete || (@concrete_post_process[index] != original_type)
