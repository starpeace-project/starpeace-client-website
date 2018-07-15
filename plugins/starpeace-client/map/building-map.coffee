
###
global PIXI
###

import Logger from '~/plugins/starpeace-client/logger.coffee'

import ChunkMap from '~/plugins/starpeace-client/map/chunk/chunk-map.coffee'

export default class BuildingMap
  constructor: (@building_manager, @renderer, @width, @height) ->
    @buildings = new Array(@width * @height)

    @chunks = new ChunkMap(@renderer, @width, @height, true, (chunk_x, chunk_y, chunk_width, chunk_height) =>
      @building_manager.load_chunk(chunk_x, chunk_y, chunk_width, chunk_height)
    , (chunk_info, buildings) =>
      Logger.debug("refreshing building chunk at #{chunk_info.chunk_x}x#{chunk_info.chunk_y}")
      for building in buildings
        metadata = @building_manager.building_metadata.buildings[building.key]

        for y in [0...metadata.h]
          for x in [0...metadata.w]
            @buildings[(building.y - y) * @width + (building.x - x)] = building
    )

  chunk_update_at: (x, y) -> @chunks.update_at(x, y)
  chunk_info_at: (x, y) -> @chunks.info_at(x, y)

  building_index_for: (x, y) -> y * @width + x
  building_at: (x, y) -> @buildings[@building_index_for(x, y)]

  building_textures_for: (key) ->
    @building_manager.building_textures[key]
