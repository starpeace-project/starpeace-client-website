
import Logger from '~/plugins/starpeace-client/logger.coffee'

MOCK_DATA = {}

export default class BuildingManager
  constructor: (@asset_manager, @event_listener, @game_state) ->
    @chunk_promises = {}

    @requested_building_metadata = false
    @building_metadata = null
    @loaded_atlases = {}
    @building_textures = {}

  setup_mocks: () ->
    mock_map_buildings = []
    can_place = (xt, yt, info) ->
      for j in [0...info.h]
        for i in [0...info.w]
          return false if mock_map_buildings[1000 * (yt - j) + (xt - i)]?
      true
    place_mock = (xt, yt, info) ->
      for j in [0...info.h]
        for i in [0...info.w]
          mock_map_buildings[1000 * (yt - j) + (xt - i)] = info

    x = 195
    y = 90
    for key,info of @building_metadata.buildings
      found_position = false
      until found_position
        if can_place(x, y, info)
          found_position = true
          place_mock(x, y, info)
          chunk_key = "#{Math.floor(x/20)}x#{Math.floor(y/20)}"
          MOCK_DATA[chunk_key] ||= []
          MOCK_DATA[chunk_key].push {
            key: key
            x: x
            y: y
          }
          x += info.w
        else
          x += 1

        if x > 235
          x = 195
          y += 1

      # return if ~key.indexOf('tennis')

  load_chunk: (chunk_x, chunk_y, width, height) ->
    key = "#{chunk_x}x#{chunk_y}"
    return if @chunk_promises[key]?

    Logger.debug("attempting to load building chunk at #{chunk_x}x#{chunk_y}")
    @game_state.start_ajax()
    @chunk_promises[key] = new Promise (done) =>
      setTimeout(=>
        delete @chunk_promises[key]

        data = []
        data = MOCK_DATA[key] if MOCK_DATA[key]?

        done(data)
        @game_state.finish_ajax()
      , 500)

  has_assets: () ->
    @building_metadata? && @building_metadata.atlas.length == Object.keys(@loaded_atlases).length

  queue_asset_load: () ->
    return if @requested_building_metadata
    @requested_building_metadata = true
    @asset_manager.queue('metadata.building', './building.metadata.json', (resource) =>
      @building_metadata = resource.data
      building.key = key for key,building of @building_metadata.buildings
      @setup_mocks()
      @load_building_atlas(resource.data.atlas)
    )

  load_building_atlas: (atlas_paths) ->
    for path in atlas_paths
      do (path) =>
        @asset_manager.queue(path, path, (resource) =>
          @loaded_atlases[path] = resource
          @building_textures[building.key] = _.map(building.frames, (frame) -> PIXI.utils.TextureCache[frame]) for building in @buildings_for_atlas(path)
          @event_listener.notify_asset_listeners()
        )
    @asset_manager.load_queued()

  buildings_for_atlas: (atlas_key) ->
    atlas_key = atlas_key.substring(2) if atlas_key.startsWith('./')
    buildings = []
    for key,building of @building_metadata.buildings
      buildings.push(building) if building.atlas == atlas_key
    buildings

  atlas_for: (key) ->
    @building_metadata.buildings[key].atlas
