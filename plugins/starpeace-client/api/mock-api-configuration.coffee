
import moment from 'moment'
import _ from 'lodash'

import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'
import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

import BOOKMARKS_METADATA from '~/plugins/starpeace-client/api/mock-bookmarks-metadata.json'
import CORPORATION_METADATA from '~/plugins/starpeace-client/api/mock-corporation-metadata.json'
import PLANETS_DETAILS from '~/plugins/starpeace-client/api/mock-planet-details.json'
import PLANETS_METADATA_BY_SYSTEM_ID from '~/plugins/starpeace-client/api/mock-planets-metadata.json'
import SYSTEMS_METADATA from '~/plugins/starpeace-client/api/mock-systems-metadata.json'
import TYCOON_METADATA from '~/plugins/starpeace-client/api/mock-tycoon-metadata.json'

import PLANET_1_MAP_BUILDINGS from '~/plugins/starpeace-client/api/mock-planet-1-map-buildings.json'
import PLANET_1_TYCOON_1_BUILDINGS from '~/plugins/starpeace-client/api/mock-planet-1-tycoon-1-buildings.json'
import PLANET_2_MAP_BUILDINGS from '~/plugins/starpeace-client/api/mock-planet-2-map-buildings.json'
import PLANET_2_TYCOON_1_BUILDINGS from '~/plugins/starpeace-client/api/mock-planet-2-tycoon-1-buildings.json'

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
    for planet in PLANETS_METADATA_BY_SYSTEM_ID[system.id]
      if planet.enabled
        PLANET_ID_DATES[planet.id] = moment('2235-01-01')


CORPORATION_ID_EVENTS = {}
for tycoon_id,tycoon of TYCOON_METADATA
  for corporation in tycoon.corporations
    system = _.find(SYSTEMS_METADATA, (system) -> system.id == corporation.system_id)
    planet = _.find(system?.planets_metadata || [], (planet) -> planet.id == corporation.planet_id)
    if system?.enabled && planet?.enabled && CORPORATION_METADATA[corporation.id]?
      CORPORATION_ID_EVENTS[corporation.id] = {
        cash: corporation.cash
        companies_by_id: {}
        cashflow: () -> _.reduce(_.values(@companies_by_id), ((sum, company) -> sum + company.cashflow), 0)
        increment_cash: () -> @cash = @cash + 24 * @cashflow()
      }
      for company in CORPORATION_METADATA[corporation.id].companies
        CORPORATION_ID_EVENTS[corporation.id].companies_by_id[company.id] = {
          id: company.id
          cashflow: company.cashflow
          original_cashflow: company.cashflow
          adjust_cashflow: () -> @cashflow = @original_cashflow + (Math.floor(Math.random() * 500) - 250)
        }


SESSION_TOKENS = {}
valid_session = (token) -> SESSION_TOKENS[token]? && TimeUtils.within_minutes(SESSION_TOKENS[token], 15)
register_session = () ->
  token = Utils.uuid()
  SESSION_TOKENS[token] = moment()
  token


setInterval(=>
  PLANET_ID_DATES[id].add(1, 'day') for id,date of PLANET_ID_DATES

  for corp_id,corp_events of CORPORATION_ID_EVENTS
    company.adjust_cashflow() for company_id,company of corp_events.companies_by_id
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
          return {
            session_token: register_session()
          }
        else if params.type == 'tycoon'
          return {
            session_token: register_session()
            tycoon_id: 'tycoon-id-1'
          }
        else
          throw new Error(400)

      if root_path == '/systems/metadata'
        throw new Error(404) unless context.method == 'get'
        throw new Error(401) unless valid_session(query_parameters.session_token)
        return {
          systems: SYSTEMS_METADATA
        }

      if root_path == '/planets/metadata'
        throw new Error(404) unless context.method == 'get'
        throw new Error(401) unless valid_session(query_parameters.session_token)
        throw new Error(400) unless query_parameters.system_id?.length
        throw new Error(404) unless PLANETS_METADATA_BY_SYSTEM_ID[query_parameters.system_id]?.length
        return {
          planets: PLANETS_METADATA_BY_SYSTEM_ID[query_parameters.system_id]
        }
      if root_path == '/planets/details'
        throw new Error(404) unless context.method == 'get'
        throw new Error(401) unless valid_session(query_parameters.session_token)
        throw new Error(400) unless query_parameters.planet_id?.length
        throw new Error(404) unless PLANETS_DETAILS[query_parameters.planet_id]?
        details = PLANETS_DETAILS[query_parameters.planet_id]
        details.date = PLANET_ID_DATES[query_parameters.planet_id].format('YYYY-MM-DD')
        details.season = MONTH_SEASONS[PLANET_ID_DATES[query_parameters.planet_id].month()]
        return {
          planet: details
        }
      if root_path == '/planets/events'
        throw new Error(404) unless context.method == 'get'
        throw new Error(401) unless valid_session(query_parameters.session_token)
        throw new Error(400) unless query_parameters.planet_id?.length
        throw new Error(400) unless query_parameters.last_update?.length
        throw new Error(404) unless PLANET_ID_DATES[query_parameters.planet_id]?
        return {
          planet: {
            date: PLANET_ID_DATES[query_parameters.planet_id].format('YYYY-MM-DD')
            season: MONTH_SEASONS[PLANET_ID_DATES[query_parameters.planet_id].month()]
          }
        }

      if root_path == '/tycoons/metadata'
        throw new Error(404) unless context.method == 'get'
        throw new Error(401) unless valid_session(query_parameters.session_token)
        throw new Error(400) unless query_parameters.tycoon_id?.length
        throw new Error(404) unless TYCOON_METADATA[query_parameters.tycoon_id]?
        return {
          tycoon: TYCOON_METADATA[query_parameters.tycoon_id]
        }

      if root_path == '/corporation/metadata'
        throw new Error(404) unless context.method == 'get'
        throw new Error(401) unless valid_session(query_parameters.session_token)
        throw new Error(400) unless query_parameters.corporation_id?.length
        throw new Error(404) unless CORPORATION_METADATA[query_parameters.corporation_id]?
        return {
          corporation: CORPORATION_METADATA[query_parameters.corporation_id]
        }
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
        return {
          corporation: corp_metadata
        }


      if root_path == '/bookmarks/metadata'
        throw new Error(404) unless context.method == 'get'
        throw new Error(401) unless valid_session(query_parameters.session_token)
        throw new Error(400) unless query_parameters.corporation_id?.length
        return {
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

        return {
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
            type: "FOLDER"
            id: Utils.uuid()
            parent_id: params.parent_id
            name: params.name
            order: order
          }
        else
          throw new Error(400)

        BOOKMARKS_METADATA[params.corporation_id].bookmarks.push item
        return {
          bookmark: item
        }


      if root_path == '/mail/metadata'
        throw new Error(404) unless context.method == 'get'
        throw new Error(401) unless valid_session(query_parameters.session_token)
        throw new Error(400) unless query_parameters.corporation_id?.length
        return {
          mail: MAIL_METADATA[query_parameters.corporation_id] || []
        }



      return {} if root_path == '/inventions/metadata'
      return {} if root_path == '/inventions/status'

      if root_path == '/buildings/metadata'
        throw new Error(404) unless context.method == 'get'
        throw new Error(401) unless valid_session(query_parameters.session_token)
        throw new Error(400) unless query_parameters.company_id?.length
        buildings = []
        buildings = PLANET_1_TYCOON_1_BUILDINGS[query_parameters.company_id] if PLANET_1_TYCOON_1_BUILDINGS[query_parameters.company_id]?
        return {
          buildings: buildings || []
        }

      if root_path == '/map/buildings'
        throw new Error(404) unless context.method == 'get'
        throw new Error(401) unless valid_session(query_parameters.session_token)
        throw new Error(400) unless query_parameters.planet_id?.length
        throw new Error(400) unless query_parameters.chunk_x? && query_parameters.chunk_y?

        chunk_key = "#{query_parameters.chunk_x}x#{query_parameters.chunk_y}"
        buildings = []
        buildings = PLANET_1_MAP_BUILDINGS[chunk_key] if query_parameters.planet_id == 'planet-1'
        buildings = PLANET_2_MAP_BUILDINGS[chunk_key] if query_parameters.planet_id == 'planet-2'
        return {
          buildings: buildings || []
        }



      throw new Error(404)

    get: (match, data) ->
      return data

    post: (match, data) ->
      return data
  }
]
