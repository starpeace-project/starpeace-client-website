import _ from 'lodash'

import MockAdapter from 'axios-mock-adapter'

import ChunkMap from '~/plugins/starpeace-client/map/chunk/chunk-map'
import TimeUtils from '~/plugins/starpeace-client/utils/time-utils'
import Utils from '~/plugins/starpeace-client/utils/utils'

import Sandbox from '~/plugins/starpeace-client/api/sandbox/sandbox.coffee'
import SandboxSocketEvents from '~/plugins/starpeace-client/api/sandbox/sandbox-socket-events.coffee'
import SandboxApiConfigure from '~/plugins/starpeace-client/api/sandbox/api/sandbox-api-configure'

export BASE_HOSTNAME = 'sandbox-galaxy.starpeace.io'
export BASE_PORT = 19160
BASE_URL = "http://#{BASE_HOSTNAME}:#{BASE_PORT}"

export default class SandboxConfiguration
  constructor: (axios) ->
    @mock = new MockAdapter(axios, { delayResponse: 500 })
    @sandbox = new Sandbox()

    @socketEvents = new SandboxSocketEvents(@sandbox)
    SandboxApiConfigure.configure(@mock, @sandbox)

    @get 'metadata/buildings', (config) => _.merge({ planetId: config.headers['PlanetId'] }, {
      definitions: @sandbox.sandbox_data.metadata.building.definitions.map((d) -> d.toJson()),
      simulationDefinitions: @sandbox.sandbox_data.metadata.building.simulations.map((d) -> d.toJson())
    })
    @get 'metadata/core', (config) => _.merge({ planetId: config.headers['PlanetId'] }, {
      cityZones: @sandbox.sandbox_data.metadata.core.cityZones.map((s) -> s.toJson())
      industryCategories: @sandbox.sandbox_data.metadata.core.industryCategories.map((s) -> s.toJson())
      industryTypes: @sandbox.sandbox_data.metadata.core.industryTypes.map((s) -> s.toJson())
      levels: @sandbox.sandbox_data.metadata.core.levels.map((s) -> s.toJson())
      overlayTypes: @sandbox.sandbox_data.metadata.core.overlayTypes.map((s) -> s.toJson())
      rankingTypes: @sandbox.sandbox_data.metadata.core.rankingTypes
      resourceTypes: @sandbox.sandbox_data.metadata.core.resourceTypes.map((s) -> s.toJson())
      resourceUnits: @sandbox.sandbox_data.metadata.core.resourceUnits.map((s) -> s.toJson())
      seals: @sandbox.sandbox_data.metadata.core.seals.map((s) -> s.toJson())
    })
    @get 'metadata/inventions', (config) => _.merge({ planetId: config.headers['PlanetId'] }, {
      inventions: @sandbox.sandbox_data.metadata.invention.inventions.map((i) -> i.toJson())
    })

    @get 'buildings/(.+?)/details', (config, building_id) =>
      _.cloneDeep(@sandbox.sandbox_data.building.detailsById[building_id] || {})
    @patch 'buildings/(.+?)/details', (config, building_id) =>
      # TODO: save changes to cache
      _.cloneDeep({})
    @get 'buildings/(.+)', (config, building_id) =>
      throw new Error(404) unless @sandbox.sandbox_data.building.buildingById[building_id]?
      _.cloneDeep(@sandbox.sandbox_data.building.buildingById[building_id])
    @post 'buildings/(.+)/demolish', (config, building_id) =>
      # TODO: remove from caches
      throw new Error(404) unless @sandbox.sandbox_data.building.buildingById[building_id]?
      {}
    @post 'buildings', (config, params) =>
      @sandbox.sandbox_buildings.queue_construction(config.headers['PlanetId'], params)
    @get 'buildings', (config, params) =>
      planet_id = config.headers['PlanetId']
      throw new Error(404) unless @sandbox.sandbox_data.building.buildingsByPlanetIdChunkId[planet_id]?
      _.cloneDeep(@sandbox.sandbox_data.building.buildingsByPlanetIdChunkId[planet_id]["#{params.chunkX}x#{params.chunkY}"] || [])


    @get('rankings/(.+)', (config, ranking_type_id) => _.cloneDeep(@sandbox.sandbox_data.rankings.rankingsByPlanetIdTypeId[config.headers['PlanetId']]?[ranking_type_id] || []))

    @get('search/corporations', (config, params) =>
      _.map(_.filter(_.values(@sandbox.sandbox_data.corporation.corporationById), (c) ->
        return false unless c.planetId == config.headers['PlanetId']
        if params.startsWithQuery
          return c.name.toLowerCase().startsWith(params.query.toLowerCase())
        else
          return c.name.toLowerCase().includes(params.query.toLowerCase())
      ), (c) => {
        tycoonId: c.tycoonId
        tycoonName: @sandbox.sandbox_data.corporation.tycoonById[c.tycoonId].name
        corporationId: c.id
        corporationName: c.name
      })
    )
    @get('search/tycoons', (config, params) =>
      _.map(_.filter(_.values(@sandbox.sandbox_data.corporation.corporationById), (c) =>
        return false unless c.planetId == config.headers['PlanetId']
        tycoon = @sandbox.sandbox_data.corporation.tycoonById[c.tycoonId]
        return false unless tycoon?
        if params.startsWithQuery then tycoon.name.startsWith(params.query) else tycoon.name.includes(params.query)
      ), (c) => {
        tycoonId: c.tycoonId
        tycoonName: @sandbox.sandbox_data.corporation.tycoonById[c.tycoonId].name
        corporationId: c.id
        corporationName: c.name
      })
    )


    @get('details', (config, params) =>
      _.merge(_.cloneDeep(@sandbox.sandbox_data?.government.planet), {
        id: config.headers['PlanetId']
      })
    )

    @get 'online', (config) ->
      planet_id = config.headers['PlanetId']
      tycoons = []
      tycoons.push { type: 'visitor', tycoonId: 'visitor-1' }
      tycoons.push {
        type: 'tycoon'
        tycoonId: 'tycoon-id-1'
        tycoonName: 'Tycoon Name'
        corporationId: 'corp-id-1'
        corporatioName: 'Corporation A'
      } if planet_id == 'planet-1'
      tycoons.push {
        type: 'tycoon'
        tycoonId: 'tycoon-id-2'
        tycoonName: 'Other Tycoon'
        corporationId: 'corp-id-4'
        corporatioName: 'Corporation Other'
      } if planet_id == 'planet-1'
      tycoons.push { type: 'visitor', tycoonId: 'visitor-2' }
      _.cloneDeep(tycoons)
    @get('towns/(.+?)/buildings', (config, town_id, params) =>
      throw new Error(404) unless @sandbox.sandbox_data?.planet_towns?[config.headers['PlanetId']]?
      _.cloneDeep([])
    )
    @get('towns/(.+?)/companies', (config, town_id) =>
      throw new Error(404) unless @sandbox.sandbox_data?.planet_towns?[config.headers['PlanetId']]?
      _.cloneDeep([])
    )
    @get('towns/(.+?)/details', (config, town_id, params) =>
      throw new Error(404) unless @sandbox.sandbox_data?.planet_towns?[config.headers['PlanetId']]?
      throw new Error(404) unless @sandbox.sandbox_data?.government.detailsByTownId[town_id]?
      _.merge(_.cloneDeep(@sandbox.sandbox_data?.government.detailsByTownId[town_id]), {
        id: town_id
      })
    )
    @get('towns', (config) =>
      planet_id = config.headers['PlanetId']
      throw new Error(404) unless @sandbox.sandbox_data?.planet_towns?[planet_id]?
      _.cloneDeep(@sandbox.sandbox_data.planet_towns[planet_id])
    )

    @get('overlay/(.+)', (config, type_id, params) =>
      if @sandbox.sandbox_data?.overlay.chunkInfoByKey["#{type_id}x#{params.chunkX}x#{params.chunkY}"]?
        _.cloneDeep(@sandbox.sandbox_data.overlay.chunkInfoByKey["#{type_id}x#{params.chunkX}x#{params.chunkY}"].data)
      else
        _.cloneDeep(@sandbox.sandbox_data.overlay.emptyChunKData)
    )

    @get('roads', (config, params) =>
      if @sandbox.sandbox_data?.roads.chunkDataByKey["#{params.chunkX}x#{params.chunkY}"]?
        _.cloneDeep(@sandbox.sandbox_data.roads.chunkDataByKey["#{params.chunkX}x#{params.chunkY}"].buffer)
      else
        _.cloneDeep(@sandbox.sandbox_data.roads.emptyBuffer)
    )


    @post 'companies', (config, params) => throw new Error(500)
    @get 'companies/(.+?)/buildings', (config, company_id) => _.cloneDeep(@sandbox.sandbox_data.building.buildingsByCompanyId[company_id] || [])
    @get 'companies/(.+?)/inventions', (config, company_id) => @sandbox.sandbox_inventions.company_inventions(company_id)
    @put 'companies/(.+?)/inventions/(.+)', (config, company_id, invention_id) => @sandbox.sandbox_inventions.queue_company_invention(company_id, invention_id)
    @delete 'companies/(.+?)/inventions/(.+)', (config, company_id, invention_id) => @sandbox.sandbox_inventions.sell_company_invention(company_id, invention_id)

    @get 'companies/(.+)', (config, company_id) =>
      throw new Error(404) if !@sandbox.sandbox_data.corporation.infoByCompanyId[company_id]?
      _.cloneDeep(@sandbox.sandbox_data.corporation.infoByCompanyId[company_id])


    @mock.onAny().passThrough()

  mock_request: (path, callback, mock_request) ->
    url_regex = new RegExp("#{BASE_URL}/#{path}")
    mock_request(url_regex).reply (config) ->
      match = url_regex.exec(config.url)
      params = if config.data? then JSON.parse(config.data) else if config.params? then config.params else {}
      [200, callback(config, ...(match?.slice(1) || []), params)]

  delete: (path, callback) -> @mock_request(path, callback, (url_regex) => @mock.onDelete(url_regex))
  get: (path, callback) -> @mock_request(path, callback, (url_regex) => @mock.onGet(url_regex))
  patch: (path, callback) -> @mock_request(path, callback, (url_regex) => @mock.onPatch(url_regex))
  put: (path, callback) -> @mock_request(path, callback, (url_regex) => @mock.onPut(url_regex))
  post: (path, callback) -> @mock_request(path, callback, (url_regex) => @mock.onPost(url_regex))
