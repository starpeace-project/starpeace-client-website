
import moment from 'moment'
import _ from 'lodash'

import MockAdapter from 'axios-mock-adapter'

import ChunkMap from '~/plugins/starpeace-client/map/chunk/chunk-map.coffee'
import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'
import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

import Sandbox from '~/plugins/starpeace-client/api/sandbox/sandbox.coffee'


BASE_URL = 'http://sandbox-galaxy.starpeace.io:19160'

export default class SandboxConfiguration
  constructor: (axios) ->
    @mock = new MockAdapter(axios, { delayResponse: 500 })
    @sandbox = new Sandbox()

    setInterval((=> @sandbox.tick_day()), 1000)

    @mock.onGet("#{BASE_URL}/galaxy/metadata").reply (config) =>
      [200, _.cloneDeep(@sandbox.sandbox_data.galaxy_metadata)]

    @post 'galaxy/login', (config, params) =>
      if params.username == 'test' && params.password == 'test' && @sandbox.sandbox_data.tycoon_by_id['tycoon-id-1']?
        access_token = Utils.uuid()
        @sandbox.sandbox_data.access_tokens[access_token] = {
          tycoon_id: 'tycoon-id-1'
          created_at: new Date().getTime()
        }
        return _.assign(_.cloneDeep(@sandbox.sandbox_data.tycoon_by_id['tycoon-id-1']), {
          accessToken: access_token
        })
      else
        throw new Error(401)

    @post 'galaxy/logout', (config, params) => {}

    @post 'planets/(.+?)/visa', (config, planet_id, params) =>
      if params.identityType == 'visitor' || params.identityType == 'tycoon'
        response = {
          visaId: @sandbox.register_session(params.identityType)
          identityType: params.identityType
        }
        access_token = config.headers['Authorization']?.split(' ')?[1]
        if params.identityType == 'tycoon' && access_token?
          tycoon_id = @sandbox.sandbox_data.access_tokens[access_token].tycoon_id
          corporation = _.find(_.values(@sandbox.sandbox_data.corporation_by_id), (corporation) -> corporation.planetId == planet_id && corporation.tycoonId == tycoon_id)
          response.corporationId = corporation.id if corporation?
        return _.cloneDeep response
      else
        throw new Error(400)

    @get 'planets/(.+?)/metadata/buildings', (config, planet_id) => _.cloneDeep(_.merge({ planetId: planet_id }, @sandbox.sandbox_data.metadata.buildings))
    @get 'planets/(.+?)/metadata/core', (config, planet_id) => _.cloneDeep(_.merge({ planetId: planet_id }, @sandbox.sandbox_data.metadata.core))
    @get 'planets/(.+?)/metadata/inventions', (config, planet_id) => _.cloneDeep(_.merge({ planetId: planet_id }, @sandbox.sandbox_data.metadata.inventions))

    @get 'planets/([^/]+?)/buildings', (config, planet_id, params) =>
      throw new Error(404) unless @sandbox.sandbox_data.planet_id_chunk_id_buildings[planet_id]?
      _.cloneDeep(@sandbox.sandbox_data.planet_id_chunk_id_buildings[planet_id]["#{params.chunkX}x#{params.chunkY}"] || [])
    @post 'planets/([^/]+?)/buildings', (config, planet_id, params) => @sandbox.sandbox_buildings.queue_construction(planet_id, params)

    @post 'planets/([^/]+?)/corporations', (config, planet_id, params) => throw new Error(500)
    @post 'planets/([^/]+?)/companies', (config, planet_id, params) => throw new Error(500)

    @get('planets/(.+?)/rankings/(.+)', (config, planet_id, ranking_type_id) => _.cloneDeep(@sandbox.sandbox_data.planet_rankings_by_type_id[planet_id]?[ranking_type_id] || []))

    @get('planets/(.+?)/search/corporations', (config, planet_id, params) =>
      _.map(_.filter(_.values(@sandbox.sandbox_data.corporation_by_id), (c) ->
        return false unless c.planetId == planet_id
        if params.startsWithQuery
          return c.name.toLowerCase().startsWith(params.query.toLowerCase())
        else
          return c.name.toLowerCase().includes(params.query.toLowerCase())
      ), (c) => {
        tycoonId: c.tycoonId
        tycoonName: @sandbox.sandbox_data.tycoon_by_id[c.tycoonId].name
        corporationId: c.id
        corporationName: c.name
      })
    )
    @get('planets/(.+?)/search/tycoons', (config, planet_id, params) =>
      _.map(_.filter(_.values(@sandbox.sandbox_data.corporation_by_id), (c) =>
        return false unless c.planetId == planet_id
        tycoon = @sandbox.sandbox_data.tycoon_by_id[c.tycoonId]
        return false unless tycoon?
        if params.startsWithQuery then tycoon.name.startsWith(params.query) else tycoon.name.includes(params.query)
      ), (c) => {
        tycoonId: c.tycoonId
        tycoonName: @sandbox.sandbox_data.tycoon_by_id[c.tycoonId].name
        corporationId: c.id
        corporationName: c.name
      })
    )


    @get('planets/(.+?)/details', (config, planet_id, params) =>
      _.merge(_.cloneDeep(@sandbox.sandbox_data?.planet_details), {
        id: planet_id
      })
    )

    @get 'planets/(.+?)/events', (config, planet_id, params) =>
      throw new Error(404) unless @sandbox.sandbox_data?.planet_id_dates?[planet_id]?
      _.cloneDeep({
        planetId: planet_id
        time: @sandbox.sandbox_data.planet_id_dates[planet_id].format()
        season: @sandbox.sandbox_data.season_for_planet(planet_id)
        buildingEvents: @sandbox.sandbox_events.building_events_since(params.lastUpdate)
        tycoonEvents: []
      })

    @get 'planets/(.+?)/online', (config, planet_id) ->
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
    @get('planets/(.+?)/towns/(.+?)/buildings', (config, planet_id, town_id, params) =>
      throw new Error(404) unless @sandbox.sandbox_data?.planet_towns?[planet_id]?
      _.cloneDeep([])
    )
    @get('planets/(.+?)/towns/(.+?)/companies', (config, planet_id, town_id) =>
      throw new Error(404) unless @sandbox.sandbox_data?.planet_towns?[planet_id]?
      _.cloneDeep([])
    )
    @get('planets/(.+?)/towns/(.+?)/details', (config, planet_id, town_id, params) =>
      throw new Error(404) unless @sandbox.sandbox_data?.planet_towns?[planet_id]?
      _.merge(_.cloneDeep(@sandbox.sandbox_data?.town_details[town_id] || @sandbox.sandbox_data?.empty_town_details), {
        id: town_id
      })
    )
    @get('planets/(.+?)/towns', (config, planet_id) =>
      throw new Error(404) unless @sandbox.sandbox_data?.planet_towns?[planet_id]?
      _.cloneDeep(@sandbox.sandbox_data.planet_towns[planet_id])
    )

    @get('planets/(.+?)/overlay/(.+)', (config, planet_id, type_id, params) =>
      if @sandbox.sandbox_data?.overlay_chunk_data["#{type_id}x#{params.chunkX}x#{params.chunkY}"]?
        _.cloneDeep(@sandbox.sandbox_data.overlay_chunk_data["#{type_id}x#{params.chunkX}x#{params.chunkY}"].data)
      else
        _.cloneDeep(@sandbox.sandbox_data.empty_overlay_data)
    )

    @get('planets/(.+?)/roads', (config, planet_id, params) =>
      if @sandbox.sandbox_data?.road_chunk_data["#{params.chunkX}x#{params.chunkY}"]?
        _.cloneDeep(@sandbox.sandbox_data.road_chunk_data["#{params.chunkX}x#{params.chunkY}"].buffer)
      else
        _.cloneDeep(@sandbox.sandbox_data.empty_road_buffer)
    )


    @get 'buildings/(.+?)/details', (config, building_id) =>
      _.cloneDeep(@sandbox.sandbox_data.building_id_building_details[building_id] || {})
    @get 'buildings/(.+)', (config, building_id) =>
      throw new Error(404) unless @sandbox.sandbox_data.building_id_building[building_id]?
      _.cloneDeep(@sandbox.sandbox_data.building_id_building[building_id])

    @get 'tycoons/.+?', (config, tycoon_id) =>
      throw new Error(404) unless @sandbox.sandbox_data?.tycoon_by_id?[tycoon_id]?
      _.cloneDeep(@sandbox.sandbox_data.tycoon_by_id[tycoon_id])

    @get 'corporations/(.+?)/bookmarks', (config, corporation_id) => @sandbox.sandbox_bookmarks.get_bookmarks(corporation_id)
    @post 'corporations/(.+?)/bookmarks', (config, corporation_id, parameters) => @sandbox.sandbox_bookmarks.create_bookmark(corporation_id, parameters)
    @patch 'corporations/(.+?)/bookmarks', (config, corporation_id, parameters) => @sandbox.sandbox_bookmarks.update_bookmarks(corporation_id, parameters.deltas)

    @get 'corporations/(.+?)/mail', (config, corporation_id) => @sandbox.sandbox_mail.get(corporation_id)
    @post 'corporations/(.+?)/mail', (config, corporation_id, parameters) => @sandbox.sandbox_mail.create(corporation_id, parameters)
    @put 'corporations/(.+?)/mail/(.+)/mark-read', (config, corporation_id, mail_id) => @sandbox.sandbox_mail.mark_read(corporation_id, mail_id)
    @delete 'corporations/(.+?)/mail/(.+)', (config, corporation_id, mail_id) => @sandbox.sandbox_mail.delete(corporation_id, mail_id)

    @get 'corporations/(.+?)/cashflow', (config, corporation_id) =>
      corp_metadata = {
        id: corporation_id
        lastMailAt: @sandbox.sandbox_data.corporation_id_cashflow[corporation_id]?.lastMailAt?.format()
        cash: (@sandbox.sandbox_data.corporation_id_cashflow[corporation_id]?.cash || 0)
        cashflow: (@sandbox.sandbox_data.corporation_id_cashflow[corporation_id]?.cashflow() || 0)
        companies: _.map(_.values(@sandbox.sandbox_data.corporation_id_cashflow[corporation_id]?.companies_by_id), (company) -> {
          id: company.id
          cashflow: company.cashflow
        })
      }
      return _.cloneDeep(corp_metadata)

    @get 'corporations/(.+)', (config, corporation_id) =>
      throw new Error(404) unless @sandbox.sandbox_data?.corporation_by_id?[corporation_id]?
      _.cloneDeep(@sandbox.sandbox_data.corporation_by_id[corporation_id])

    @get 'companies/(.+?)/buildings', (config, company_id) => _.cloneDeep(@sandbox.sandbox_data.company_id_buildings[company_id] || [])
    @get 'companies/(.+?)/inventions', (config, company_id) => @sandbox.sandbox_inventions.company_inventions(company_id)
    @put 'companies/(.+?)/inventions/(.+)', (config, company_id, invention_id) => @sandbox.sandbox_inventions.queue_company_invention(company_id, invention_id)
    @delete 'companies/(.+?)/inventions/(.+)', (config, company_id, invention_id) => @sandbox.sandbox_inventions.sell_company_invention(company_id, invention_id)

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
