
import moment from 'moment'
import _ from 'lodash'

import ChunkMap from '~/plugins/starpeace-client/map/chunk/chunk-map.coffee'
import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'
import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

import BOOKMARKS_METADATA from '~/plugins/starpeace-client/api/mock-bookmarks-metadata.json'
import PLANETS_DETAILS from '~/plugins/starpeace-client/api/mock-planet-details.json'
import SYSTEMS_METADATA from '~/plugins/starpeace-client/api/mock-systems-metadata.json'
import TYCOON_METADATA from '~/plugins/starpeace-client/api/mock-tycoon-metadata.json'

import PLANET_1_MAP_BUILDINGS from '~/plugins/starpeace-client/api/mock-planet-1-map-buildings.json'
import PLANET_1_TYCOON_1_INVENTIONS from '~/plugins/starpeace-client/api/mock-planet-1-tycoon-1-inventions.json'
import PLANET_2_MAP_BUILDINGS from '~/plugins/starpeace-client/api/mock-planet-2-map-buildings.json'

PLANET_MAP_BUILDINGS = {
  'planet-1': PLANET_1_MAP_BUILDINGS
  'planet-2': PLANET_2_MAP_BUILDINGS
}

API_DELAY = 500

MAIL_METADATA = {}

MONTH_SEASONS = {
  0: 'winter'
  1: 'winter'
  2: 'spring'
  3: 'spring'
  4: 'spring'
  5: 'summer'
  6: 'summer'
  7: 'summer'
  8: 'fall'
  9: 'fall'
  10: 'fall'
  11: 'winter'
}

PLANET_ID_DATES = {}
for system in SYSTEMS_METADATA
  if system.enabled
    for planet in system.planets_metadata
      if planet.enabled
        PLANET_ID_DATES[planet.id] = moment('2235-01-01')


CORPORATION_ID_EVENTS = {}
COMPANY_ID_INFO = {}
COMPANY_ID_INVENTIONS = {}

for tycoon_id,tycoon of TYCOON_METADATA
  for corporation in tycoon.corporations
    system = _.find(SYSTEMS_METADATA, (system) -> system.id == corporation.system_id)
    planet = _.find(system?.planets_metadata || [], (planet) -> planet.id == corporation.planet_id)
    if system?.enabled && planet?.enabled
      CORPORATION_ID_EVENTS[corporation.id] = {
        cash: corporation.cash
        companies_by_id: {}
        cashflow: () -> _.reduce(_.values(@companies_by_id), ((sum, company) -> sum + company.cashflow), 0)
        increment_cash: () -> @cash = @cash + 24 * @cashflow()
      }
      for company in corporation.companies
        COMPANY_ID_INFO[company.id] = {
          tycoon_id: tycoon_id
          corporation_id: corporation.id
          planet_id: corporation.planet_id
        }

        CORPORATION_ID_EVENTS[corporation.id].companies_by_id[company.id] = {
          id: company.id
          cashflow: company.cashflow
          original_cashflow: company.cashflow
          adjust_cashflow: (temporary_delta) -> @cashflow = @original_cashflow + (Math.floor(Math.random() * 500) - 250) + temporary_delta
        }

        for company_inventions in [PLANET_1_TYCOON_1_INVENTIONS]
          if company_inventions[company.id]?
            COMPANY_ID_INVENTIONS[company.id] = company_inventions[company.id]
            COMPANY_ID_INVENTIONS[company.id].corporation_id = corporation.id
            COMPANY_ID_INVENTIONS[company.id].tycoon_id = tycoon_id


COMPANY_ID_BUILDINGS = {}
BUILDING_ID_BUILDING = {}
for planet_id,planet_buildings of PLANET_MAP_BUILDINGS
  for chunk_id,chunk_buildings of planet_buildings
    for building in chunk_buildings
      COMPANY_ID_BUILDINGS[building.company_id] = [] unless COMPANY_ID_BUILDINGS[building.company_id]?
      COMPANY_ID_BUILDINGS[building.company_id].push building
      BUILDING_ID_BUILDING[building.id] = building


SESSION_TOKENS = {}
valid_session = (token) -> SESSION_TOKENS[token]? && TimeUtils.within_minutes(SESSION_TOKENS[token], 60)
register_session = () ->
  token = Utils.uuid()
  SESSION_TOKENS[token] = moment()
  token

cost_for_invention_id = (invention_id) ->
  if window?.starpeace_client?.client_state?.core?.invention_library?
    window.starpeace_client.client_state.core.invention_library.metadata_by_id[invention_id]?.properties?.price || 0
  else
    0

QUEUED_EVENTS = []
COMPANY_CONSTRUCTION_BUIDLINGS = {}

BUILDING_EVENTS = []

setInterval(=>
  PLANET_ID_DATES[id].add(1, 'day') for id,date of PLANET_ID_DATES

  for corp_id,corp_events of CORPORATION_ID_EVENTS
    for company_id,company of corp_events.companies_by_id
      cashflow_adjustment = 0

      to_remove = []
      for event,index in QUEUED_EVENTS
        if event.company_id == company_id
          to_remove.push index
          if event.type == 'SELL_RESEARCH'
            cashflow_adjustment += (cost_for_invention_id(event.invention_id) / 24)
          else if event.type == 'CANCEL_RESEARCH'
            cashflow_adjustment += (event.refund / 24)
      QUEUED_EVENTS.splice(index, 1) for index in to_remove.sort((lhs, rhs) -> rhs - lhs)

      inventions = COMPANY_ID_INVENTIONS[company_id]
      if inventions?.pending_inventions?.length
        to_remove = []
        for pending,index in inventions.pending_inventions
          continue unless index == 0

          unless pending.step_increment?
            pending.cost = cost_for_invention_id(pending.id)
            pending.step_increment = Math.max(50000, Math.round(pending.cost / 30))
          pending.spent += pending.step_increment
          cashflow_adjustment -= (pending.step_increment / 24)

          pending.progress = Math.min(100, Math.round(pending.spent / pending.cost * 100))
          if pending.spent >= pending.cost
            to_remove.push index
            inventions.completed_ids.push pending.id

        for index in to_remove.sort((lhs, rhs) -> rhs - lhs)
          inventions.pending_inventions.splice(index, 1)
        inventions.pending_inventions[index].order = index for index in [0...inventions.pending_inventions.length]

      if COMPANY_CONSTRUCTION_BUIDLINGS[company_id]?.length
        to_remove = []
        for building,index in COMPANY_CONSTRUCTION_BUIDLINGS[company_id]
          if building.stage == -1
            building.progress = 22 + (building.progress || 0)
            building.progress = 100 if building.progress > 100

            cashflow_adjustment -= (5000 + Math.random() * 5000)

            if building.progress == 100
              building.stage = 0
              BUILDING_EVENTS.push {'type':'stage', 'id':building.id, 'definition_id':building.key, 'x':building.x, 'y':building.y}
              to_remove.push index
          else
            to_remove.push index
        COMPANY_CONSTRUCTION_BUIDLINGS[company_id].splice(index, 1) for index in to_remove.sort((lhs, rhs) -> rhs - lhs)

      company.adjust_cashflow(cashflow_adjustment)

    corp_events.increment_cash()

, 1000)

export default [
  {
    pattern: 'https://api.starpeace.io(.*)'

    fixtures: (match, params, headers, context) ->
      throw new Error(404) if match[1] == '/404'

      [root_path, query_string] = if match[1].indexOf('?') >= 0 then match[1].split('?') else [match[1], '']
      query_parameters = Utils.parse_query(query_string)

      context.delay = API_DELAY

      if root_path == '/session/register'
        throw new Error(404) unless context.method == 'post'
        if params.type == 'visitor'
          return _.cloneDeep {
            session_token: register_session()
          }
        else if params.type == 'tycoon'
          return _.cloneDeep {
            session_token: register_session()
            tycoon_id: 'tycoon-id-1'
          }
        else
          throw new Error(400)

      if root_path == '/systems/metadata'
        throw new Error(404) unless context.method == 'get'
        throw new Error(401) unless valid_session(query_parameters.session_token)
        return _.cloneDeep {
          systems: SYSTEMS_METADATA
        }

      if root_path == '/planet/details'
        throw new Error(404) unless context.method == 'get'
        throw new Error(401) unless valid_session(query_parameters.session_token)
        throw new Error(400) unless query_parameters.planet_id?.length
        throw new Error(404) unless PLANETS_DETAILS[query_parameters.planet_id]?
        details = PLANETS_DETAILS[query_parameters.planet_id]
        details.date = PLANET_ID_DATES[query_parameters.planet_id].format('YYYY-MM-DD')
        details.season = MONTH_SEASONS[PLANET_ID_DATES[query_parameters.planet_id].month()]
        return _.cloneDeep {
          planet: details
        }
      if root_path == '/planet/events'
        throw new Error(404) unless context.method == 'get'
        throw new Error(401) unless valid_session(query_parameters.session_token)
        throw new Error(400) unless query_parameters.planet_id?.length
        throw new Error(400) unless query_parameters.last_update?.length
        throw new Error(404) unless PLANET_ID_DATES[query_parameters.planet_id]?

        events = if BUILDING_EVENTS.length then BUILDING_EVENTS else []
        BUILDING_EVENTS = [] if events.length
        return _.cloneDeep {
          planet: {
            date: PLANET_ID_DATES[query_parameters.planet_id].format('YYYY-MM-DD')
            season: MONTH_SEASONS[PLANET_ID_DATES[query_parameters.planet_id].month()]
            building_events: events
          }
        }

      if root_path == '/tycoon/metadata'
        throw new Error(404) unless context.method == 'get'
        throw new Error(401) unless valid_session(query_parameters.session_token)
        throw new Error(400) unless query_parameters.tycoon_id?.length
        throw new Error(404) unless TYCOON_METADATA[query_parameters.tycoon_id]?
        return _.cloneDeep {
          tycoon: TYCOON_METADATA[query_parameters.tycoon_id]
        }

      if root_path == '/corporation/metadata'
        throw new Error(404) unless context.method == 'get'
        throw new Error(401) unless valid_session(query_parameters.session_token)
        throw new Error(400) unless query_parameters.corporation_id?.length
        for tycoon_id,tycoon of TYCOON_METADATA
          for corporation in tycoon.corporations
            if corporation.id == query_parameters.corporation_id
              corporation.tycoon_id = tycoon_id unless corporation.tycoon_id?
              return { corporation: corporation }
        throw new Error(404)

      if root_path == '/corporation/events'
        throw new Error(404) unless context.method == 'get'
        throw new Error(401) unless valid_session(query_parameters.session_token)
        throw new Error(400) unless query_parameters.corporation_id?.length
        throw new Error(400) unless query_parameters.last_update?.length
        throw new Error(404) unless CORPORATION_ID_EVENTS[query_parameters.corporation_id]?

        corp_metadata = {
          id: query_parameters.corporation_id
          cash: CORPORATION_ID_EVENTS[query_parameters.corporation_id].cash
          cashflow: CORPORATION_ID_EVENTS[query_parameters.corporation_id].cashflow()
          companies: []
        }
        for company_id,company of CORPORATION_ID_EVENTS[query_parameters.corporation_id].companies_by_id
          corp_metadata.companies.push {
            id: company.id
            cashflow: company.cashflow
          }
        return _.cloneDeep {
          corporation: corp_metadata
        }


      if root_path == '/bookmarks/metadata'
        throw new Error(404) unless context.method == 'get'
        throw new Error(401) unless valid_session(query_parameters.session_token)
        throw new Error(400) unless query_parameters.corporation_id?.length
        return _.cloneDeep {
          bookmarks: BOOKMARKS_METADATA[query_parameters.corporation_id] || []
        }
      if root_path == '/bookmarks/update'
        throw new Error(404) unless context.method == 'post'
        throw new Error(401) unless valid_session(params.session_token)
        throw new Error(400) unless params.corporation_id?.length
        throw new Error(404) unless BOOKMARKS_METADATA[params.corporation_id]?.bookmarks?

        updated = []
        for delta in params.deltas
          existing = _.find(BOOKMARKS_METADATA[params.corporation_id].bookmarks, (bookmark) -> bookmark.id == delta.id)
          if existing?
            existing.parent_id = delta.parent_id if delta.parent_id?
            existing.order = delta.order if delta.order?
            updated.push existing

        return _.cloneDeep {
          bookmarks: updated
        }
      if root_path == '/bookmarks/new'
        throw new Error(404) unless context.method == 'post'
        throw new Error(401) unless valid_session(params.session_token)
        throw new Error(400) unless params.corporation_id?.length
        throw new Error(400) unless params.parent_id?.length
        throw new Error(400) unless params.name?.length
        throw new Error(404) unless BOOKMARKS_METADATA[params.corporation_id]?.bookmarks?

        order = _.filter(BOOKMARKS_METADATA[params.corporation_id].bookmarks, (bookmark) -> bookmark.parent_id == params.parent_id).length

        if params.type == 'FOLDER'
          item = {
            type: 'FOLDER'
            id: Utils.uuid()
            parent_id: params.parent_id
            name: params.name
            order: order
          }
        else if params.type == 'LOCATION'
          throw new Error(400) unless params.map_x?
          throw new Error(400) unless params.map_y?
          item = {
            type: 'LOCATION'
            id: Utils.uuid()
            parent_id: params.parent_id
            name: params.name
            order: order
            map_x: params.map_x
            map_y: params.map_y
          }
        else if params.type == 'BUILDING'
          throw new Error(400) unless params.building_id?.length
          throw new Error(400) unless params.map_x?
          throw new Error(400) unless params.map_y?
          item = {
            type: 'BUILDING'
            id: Utils.uuid()
            parent_id: params.parent_id
            name: params.name
            order: order
            building_id: params.building_id
            map_x: params.map_x
            map_y: params.map_y
          }
        else
          throw new Error(400)

        BOOKMARKS_METADATA[params.corporation_id].bookmarks.push item
        return _.cloneDeep {
          bookmark: item
        }


      if root_path == '/mail/metadata'
        throw new Error(404) unless context.method == 'get'
        throw new Error(401) unless valid_session(query_parameters.session_token)
        throw new Error(400) unless query_parameters.corporation_id?.length
        return _.cloneDeep {
          mail: MAIL_METADATA[query_parameters.corporation_id] || []
        }

      if root_path == '/inventions/metadata'
        throw new Error(404) unless context.method == 'get'
        throw new Error(401) unless valid_session(query_parameters.session_token)
        throw new Error(400) unless query_parameters.company_id?.length
        return _.cloneDeep {
          inventions: {
            company_id: query_parameters.company_id
            pending_inventions: (COMPANY_ID_INVENTIONS[query_parameters.company_id]?.pending_inventions || [])
            completed_ids: (COMPANY_ID_INVENTIONS[query_parameters.company_id]?.completed_ids || [])
          }
        }
      if root_path == '/inventions/sell'
        throw new Error(404) unless context.method == 'post'
        throw new Error(401) unless valid_session(params.session_token)
        throw new Error(400) unless params.company_id?.length
        throw new Error(400) unless params.invention_id?.length
        throw new Error(404) unless COMPANY_ID_INVENTIONS[params.company_id]?

        inventions = COMPANY_ID_INVENTIONS[params.company_id]
        completed_index = inventions.completed_ids.indexOf(params.invention_id)
        pending_index = _.findIndex(inventions.pending_inventions, (pending) => pending.id == params.invention_id)
        if completed_index >= 0
          QUEUED_EVENTS.push { type: 'SELL_RESEARCH', company_id: params.company_id, invention_id: params.invention_id }
          inventions.completed_ids.splice(completed_index, 1)
        else if pending_index >= 0
          QUEUED_EVENTS.push { type: 'CANCEL_RESEARCH', company_id: params.company_id, invention_id: params.invention_id, refund: inventions.pending_inventions[pending_index].spent }
          inventions.pending_inventions[index].order -= 1 for index in [pending_index...inventions.pending_inventions.length]
          inventions.pending_inventions.splice(pending_index, 1)

        return _.cloneDeep {
          inventions: {
            company_id: params.company_id
            pending_inventions: (inventions.pending_inventions || [])
            completed_ids: (inventions.completed_ids || [])
          }
        }
      if root_path == '/inventions/queue'
        throw new Error(404) unless context.method == 'post'
        throw new Error(401) unless valid_session(params.session_token)
        throw new Error(400) unless params.company_id?.length
        throw new Error(400) unless params.invention_id?.length
        throw new Error(404) unless COMPANY_ID_INVENTIONS[params.company_id]?

        inventions = COMPANY_ID_INVENTIONS[params.company_id]
        completed_index = inventions.completed_ids.indexOf(params.invention_id)
        pending_index = _.findIndex(inventions.pending_inventions, (pending) => pending.id == params.invention_id)
        if completed_index >= 0 || pending_index >= 0
          throw new Error(404)
          inventions.completed_ids.splice(completed_index, 1)
        else
          inventions.pending_inventions.push {
            id: params.invention_id
            progress: 0
            order: inventions.pending_inventions.length
            spent: 0
          }

        return _.cloneDeep {
          inventions: {
            company_id: params.company_id
            pending_inventions: (inventions.pending_inventions || [])
            completed_ids: (inventions.completed_ids || [])
          }
        }

      return {} if root_path == '/inventions/status'


      if root_path == '/buildings/metadata'
        throw new Error(404) unless context.method == 'get'
        throw new Error(401) unless valid_session(query_parameters.session_token)
        buildings = []
        if query_parameters.company_id?.length
          buildings = COMPANY_ID_BUILDINGS[query_parameters.company_id] if COMPANY_ID_BUILDINGS[query_parameters.company_id]?
        else if query_parameters.building_id?.length
          buildings.push BUILDING_ID_BUILDING[query_parameters.building_id] if BUILDING_ID_BUILDING[query_parameters.building_id]?
        else
          throw new Error(400)
        return _.cloneDeep {
          buildings: buildings || []
        }

      if root_path == '/buildings/construct'
        throw new Error(404) unless context.method == 'post'
        throw new Error(401) unless valid_session(params.session_token)
        throw new Error(400) unless params.company_id?.length
        throw new Error(400) unless params.definition_id?.length
        throw new Error(400) unless params.name?.length
        throw new Error(400) unless params.map_x?
        throw new Error(400) unless params.map_y?

        throw new Error(404) unless COMPANY_ID_INFO[params.company_id]?
        throw new Error(404) unless PLANET_MAP_BUILDINGS[COMPANY_ID_INFO[params.company_id].planet_id]?

        building_info = {
          id: Utils.uuid()
          name: params.name
          tycoon_id: COMPANY_ID_INFO[params.company_id].tycoon_id
          corporation_id: COMPANY_ID_INFO[params.company_id].corporation_id
          company_id: params.company_id
          key: params.definition_id
          x: params.map_x
          y: params.map_y
          stage: -1
          progress: 0
        }

        chunk_x = Math.floor(params.map_x / ChunkMap.CHUNK_WIDTH)
        chunk_y = Math.floor(params.map_y / ChunkMap.CHUNK_HEIGHT)
        chunk_key = "#{chunk_x}x#{chunk_y}"

        PLANET_MAP_BUILDINGS[COMPANY_ID_INFO[params.company_id].planet_id][chunk_key] = [] unless PLANET_MAP_BUILDINGS[COMPANY_ID_INFO[params.company_id].planet_id][chunk_key]?
        PLANET_MAP_BUILDINGS[COMPANY_ID_INFO[params.company_id].planet_id][chunk_key].push building_info
        COMPANY_ID_BUILDINGS[params.company_id] = [] unless COMPANY_ID_BUILDINGS[params.company_id]?
        COMPANY_ID_BUILDINGS[params.company_id].push building_info
        BUILDING_ID_BUILDING[building_info.id] = building_info
        COMPANY_CONSTRUCTION_BUIDLINGS[params.company_id] = [] unless COMPANY_CONSTRUCTION_BUIDLINGS[params.company_id]?
        COMPANY_CONSTRUCTION_BUIDLINGS[params.company_id].push building_info

        BUILDING_EVENTS.push {'type':'construct', 'id':building_info.id, 'definition_id':building_info.key, 'x':building_info.x, 'y':building_info.y}

        return _.cloneDeep {
          building: building_info
        }

      if root_path == '/map/buildings'
        throw new Error(404) unless context.method == 'get'
        throw new Error(401) unless valid_session(query_parameters.session_token)
        throw new Error(400) unless query_parameters.planet_id?.length
        throw new Error(400) unless query_parameters.chunk_x? && query_parameters.chunk_y?
        throw new Error(404) unless PLANET_MAP_BUILDINGS[query_parameters.planet_id]?

        chunk_key = "#{query_parameters.chunk_x}x#{query_parameters.chunk_y}"
        return _.cloneDeep {
          buildings: PLANET_MAP_BUILDINGS[query_parameters.planet_id][chunk_key] || []
        }



      throw new Error(404)

    get: (match, data) ->
      return data

    post: (match, data) ->
      return data
  }
]
