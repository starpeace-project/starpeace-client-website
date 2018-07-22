
###
global PIXI
###

import Logger from '~/plugins/starpeace-client/logger.coffee'

import ConcreteMap from '~/plugins/starpeace-client/map/concrete-map.coffee'
import ChunkMap from '~/plugins/starpeace-client/map/chunk/chunk-map.coffee'
import BuildingZone from '~/plugins/starpeace-client/map/types/building-zone.coffee'
import Concrete from '~/plugins/starpeace-client/map/types/concrete.coffee'

export default class BuildingMap
  constructor: (ground_map, @building_manager, @renderer, @width, @height) ->
    @buildings = new Array(@width * @height)
    @roads = new Array(@width * @height)

    @concrete = new ConcreteMap(ground_map, @building_manager, @renderer, @width, @height)

    @chunks = new ChunkMap(@renderer, @width, @height, true, (chunk_x, chunk_y, chunk_width, chunk_height) =>
      @building_manager.load_chunk(chunk_x, chunk_y, chunk_width, chunk_height)
    , (chunk_info, buildings) =>
      Logger.debug("refreshing building chunk at #{chunk_info.chunk_x}x#{chunk_info.chunk_y}")
      @add_building(building) for building in buildings
      @concrete.refresh_concrete(chunk_info.chunk_x, chunk_info.chunk_y)
    )

  chunk_update_at: (x, y) -> @chunks.update_at(x, y)
  chunk_info_at: (x, y) -> @chunks.info_at(x, y)

  building_at: (x, y) -> @buildings[y * @width + x]

  add_building: (building) ->
    metadata = @building_manager.building_metadata.buildings[building.key]

    has_concrete = metadata.zone != BuildingZone.TYPES.NONE.type && metadata.zone != BuildingZone.TYPES.INDUSTRIAL.type && metadata.zone != BuildingZone.TYPES.WAREHOUSE.type
    for y in [0...metadata.h]
      for x in [0...metadata.w]
        map_index = (building.y - y) * @width + (building.x - x)
        @buildings[map_index] = building
        @concrete.concrete_pre_process[map_index] = if has_concrete then Concrete.TYPES.CENTER else Concrete.TYPES.BUFFER
