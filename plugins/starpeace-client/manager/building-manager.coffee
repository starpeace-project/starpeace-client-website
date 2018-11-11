
import Logger from '~/plugins/starpeace-client/logger.coffee'
import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

import RoadManager from '~/plugins/starpeace-client/manager/road-manager.coffee'

MOCK_DATA = {}
MOCK_TYCOONS = ['tycoon-id-1', 'tycoon-id-2', 'tycoon-id-3', 'tycoon-id-4', 'tycoon-id-5']
TYCOON_ID_CORP_ID_COMPANY_IDS = {
  'tycoon-id-1': {
    corporation_id: 'corp-id-1'
    'DIS': 'company-id-1'
    'MAGNA': 'company-id-2'
    'MKO': 'company-id-3'
    'MOAB': 'company-id-4'
    'PGI': 'company-id-5'
  },
  'tycoon-id-2': {
    corporation_id: 'corp-id-4'
    'DIS': 'company-id-6'
    'MAGNA': 'company-id-7'
    'MKO': 'company-id-8'
    'MOAB': 'company-id-9'
    'PGI': 'company-id-10'
  },
  'tycoon-id-3': {
    corporation_id: 'corp-id-5'
    'DIS': 'company-id-11'
    'MAGNA': 'company-id-12'
    'MKO': 'company-id-13'
    'MOAB': 'company-id-14'
    'PGI': 'company-id-15'
  },
  'tycoon-id-4': {
    corporation_id: 'corp-id-6'
    'DIS': 'company-id-16'
    'MAGNA': 'company-id-17'
    'MKO': 'company-id-18'
    'MOAB': 'company-id-19'
    'PGI': 'company-id-20'
  },
  'tycoon-id-5': {
    corporation_id: 'corp-id-7'
    'DIS': 'company-id-21'
    'MAGNA': 'company-id-22'
    'MKO': 'company-id-23'
    'MOAB': 'company-id-24'
    'PGI': 'company-id-25'
  }
}

export default class BuildingManager
  constructor: (@api, @asset_manager, @translation_manager, @event_listener, @game_state) ->
    @chunk_promises = {}

    @requested_building_metadata = false
    @building_metadata = null
    @loaded_atlases = {}
    @building_textures = {}

    @mocks_configured = false

  setup_mocks: () ->
    mock_map_buildings = []
    can_place = (xt, yt, info) =>
      for j in [0...info.h]
        for i in [0...info.w]
          index = 1000 * (yt - j) + (xt - i)
          return false if mock_map_buildings[index]? || RoadManager.DUMMY_ROAD_DATA[index] || @game_state.game_map?.ground_map?.is_coast_at(xt - i, yt - j) || @game_state.game_map?.ground_map?.is_water_at(xt - i, yt - j) && @game_state.game_map?.ground_map?.is_coast_around(xt - i, yt - j)
      true
    place_mock = (xt, yt, info) ->
      for j in [0...info.h]
        for i in [0...info.w]
          mock_map_buildings[1000 * (yt - j) + (xt - i)] = info

    buildings_for_company = {}
    x = 195
    y = 90
    for key,info of @building_metadata.buildings
      found_position = false
      until found_position
        if can_place(x, y, info)
          found_position = true
          place_mock(x, y, info)
          chunk_key = "#{Math.floor(x/20)}x#{Math.floor(y/20)}"
          item = {
            id: Utils.uuid()
            tycoon_id: MOCK_TYCOONS[Math.floor(Math.random() * MOCK_TYCOONS.length)]
            name: "#{@translation_manager.text(info.name_key)} 1"
            key: key
            x: x
            y: y
          }
          item.corporation_id = TYCOON_ID_CORP_ID_COMPANY_IDS[item.tycoon_id].corporation_id
          item.company_id = TYCOON_ID_CORP_ID_COMPANY_IDS[item.tycoon_id][info.seal_ids[Math.floor(Math.random() * info.seal_ids.length)]]
          MOCK_DATA[chunk_key] ||= []
          MOCK_DATA[chunk_key].push item
          if item.tycoon_id == 'tycoon-id-1'
            buildings_for_company[item.company_id] ||= []
            buildings_for_company[item.company_id].push item
          x += info.w
        else
          x += 1

        if x > 235
          x = 195
          y += 1

      # return if ~key.indexOf('tennis')
    @mocks_configured = true
    console.log JSON.stringify(MOCK_DATA)
    console.log JSON.stringify(buildings_for_company)

  load_chunk: (chunk_x, chunk_y, width, height) ->
    key = "#{chunk_x}x#{chunk_y}"
    return if @chunk_promises[key]?

    @game_state.start_ajax()
    @chunk_promises[key] = new Promise (done) =>
      @api.map_buildings_data(@game_state.session_state.session_token, @game_state.session_state.planet_id, chunk_x, chunk_y)
        .then (building_data) =>
          Logger.debug("loaded building chunk at #{chunk_x}x#{chunk_y}")
          delete @chunk_promises[key]

          # @setup_mocks() unless @mocks_configured
          @game_state.finish_ajax()
          done(building_data)

        .catch (err) =>
          @game_state.finish_ajax()
          console.log err
          # FIXME: TODO: add error handling

  has_assets: () ->
    @building_metadata? && @building_metadata.atlas.length == Object.keys(@loaded_atlases).length

  queue_asset_load: () ->
    return if @requested_building_metadata || @building_metadata?
    @requested_building_metadata = true
    @asset_manager.queue('metadata.building', './building.metadata.json', (resource) =>
      @building_metadata = resource.data
      building.key = key for key,building of @building_metadata.buildings
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


  load_metadata: (company_id) ->
    new Promise (done, error) =>
      @game_state.session_state.start_buildings_metadata_request(company_id)
      @api.buildings_metadata(@game_state.session_state.session_token, company_id)
        .then (metadata) =>
          @game_state.session_state.set_buildings_metadata_for_id(company_id, metadata)
          @game_state.session_state.finish_buildings_metadata_request(company_id)
          @event_listener.notify_company_metadata_listeners()
          done()

        .catch (err) =>
          # FIXME: TODO add error handling
          @game_state.session_state.finish_buildings_metadata_request(company_id)
          error()
