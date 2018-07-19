
###
global PIXI
###

import Logger from '~/plugins/starpeace-client/logger.coffee'

import ChunkMap from '~/plugins/starpeace-client/map/chunk/chunk-map.coffee'
import BuildingZone from '~/plugins/starpeace-client/map/types/building-zone.coffee'
import Concrete from '~/plugins/starpeace-client/map/types/concrete.coffee'

export default class BuildingMap
  constructor: (@building_manager, @renderer, @width, @height) ->
    @buildings = new Array(@width * @height)
    @concrete = new Array(@width * @height)
    @concrete_types = new Array(@width * @height)
    @roads = new Array(@width * @height)

    @chunks = new ChunkMap(@renderer, @width, @height, true, (chunk_x, chunk_y, chunk_width, chunk_height) =>
      @building_manager.load_chunk(chunk_x, chunk_y, chunk_width, chunk_height)
    , (chunk_info, buildings) =>
      Logger.debug("refreshing building chunk at #{chunk_info.chunk_x}x#{chunk_info.chunk_y}")
      @add_building(building) for building in buildings
      @refresh_concrete(chunk_info.chunk_x, chunk_info.chunk_y)
    )

  chunk_update_at: (x, y) -> @chunks.update_at(x, y)
  chunk_info_at: (x, y) -> @chunks.info_at(x, y)

  building_at: (x, y) -> @buildings[y * @width + x]
  concrete_at: (x, y) -> @concrete[y * @width + x]
  concrete_type_at: (x, y) -> @concrete_types[y * @width + x]

  neighbors_concrete_center: (x, y, dx, dy, log) ->
    type_a = @concrete_type_at(x - dx, y - dy)
    type_b = @concrete_type_at(x + dx, y + dy)
    n = (type_a == Concrete.TYPES.CENTER || type_a == Concrete.TYPES.CENTER_PLANT) && (type_b == Concrete.TYPES.CENTER || type_b == Concrete.TYPES.CENTER_PLANT)
    console.log "center" if n && log
    n

  fill_concrete: (chunk_x, chunk_y) ->
    did_change_concrete = true
    while did_change_concrete
      did_change_concrete = false
      for y in [(chunk_y - 1) * ChunkMap.CHUNK_HEIGHT...(chunk_y + 2) * ChunkMap.CHUNK_HEIGHT]
        for x in [(chunk_x - 1) * ChunkMap.CHUNK_WIDTH...(chunk_x + 2) * ChunkMap.CHUNK_WIDTH]
          index = y * @width + x
          continue if @concrete_types[index] == Concrete.TYPES.CENTER || @concrete_types[index] == Concrete.TYPES.CENTER_PLANT
          if @neighbors_concrete_center(x, y, 1, 0) || @neighbors_concrete_center(x, y, 0, 1)# || @neighbors_concrete_center(x, y, 1, 1) || @neighbors_concrete_center(x, y, -1, 1, true)
            @concrete_types[index] = Concrete.TYPES.CENTER_PLANT
            @concrete_outline(Concrete.TYPES.EDGE, x + 1, y + 1, 3, 3)
            did_change_concrete = true

  refresh_concrete: (chunk_x, chunk_y) ->
    @fill_concrete(chunk_x, chunk_y)

    for y in [(chunk_y - 1) * ChunkMap.CHUNK_HEIGHT...(chunk_y + 2) * ChunkMap.CHUNK_HEIGHT]
      for x in [(chunk_x - 1) * ChunkMap.CHUNK_WIDTH...(chunk_x + 2) * ChunkMap.CHUNK_WIDTH]
        concrete_type = @concrete_types[y * @width + x]
        if concrete_type == Concrete.TYPES.CENTER
          @concrete[y * @width + x] = { key: 'concrete.c.solid', is_plant:false }
        else if concrete_type == Concrete.TYPES.CENTER_PLANT
          @concrete[y * @width + x] = if (x % 2 == 1) ^ (y % 2 == 1) then { key: 'concrete.c.plant', is_plant:true } else { key: 'concrete.c.solid', is_plant:false }
        else if concrete_type == Concrete.TYPES.EDGE
          @concrete[y * @width + x] = null
        else
          @concrete[y * @width + x] = null

  concrete_outline: (type, sw_x, sw_y, width, height) ->
    for y in [0...height]
      @concrete_types[(sw_y - y) * @width + (sw_x - 0)] = type if (@concrete_types[(sw_y - y) * @width + (sw_x - 0)]?.priority || 10) >= type.priority
      @concrete_types[(sw_y - y) * @width + (sw_x - width + 1)] = type if (@concrete_types[(sw_y - y) * @width + (sw_x - width + 1)]?.priority || 10) >= type.priority

    for x in [0...width]
      @concrete_types[(sw_y - 0) * @width + (sw_x - x)] = type if (@concrete_types[(sw_y - 0) * @width + (sw_x - x)]?.priority || 10) >= type.priority
      @concrete_types[(sw_y - height + 1) * @width + (sw_x - x)] = type if (@concrete_types[(sw_y - height + 1) * @width + (sw_x - x)]?.priority || 10) >= type.priority

  add_building: (building) ->
    metadata = @building_manager.building_metadata.buildings[building.key]

    has_concrete = metadata.zone != BuildingZone.TYPES.NONE.type && metadata.zone != BuildingZone.TYPES.INDUSTRIAL.type && metadata.zone != BuildingZone.TYPES.WAREHOUSE.type
    for y in [0...metadata.h]
      for x in [0...metadata.w]
        map_index = (building.y - y) * @width + (building.x - x)
        @buildings[map_index] = building
        @concrete_types[map_index] = if has_concrete then Concrete.TYPES.CENTER else Concrete.TYPES.BUFFER

    @concrete_outline((if has_concrete then Concrete.TYPES.EDGE else Concrete.TYPES.BUFFER), building.x + 1, building.y + 1, metadata.w + 2, metadata.h + 2)
    @concrete_outline(Concrete.TYPES.BUFFER, building.x + 2, building.y + 2, metadata.w + 4, metadata.h + 4)
