
import moment from 'moment'

import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'
import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

import BOOKMARKS_METADATA from '~/plugins/starpeace-client/api/mock-bookmarks-metadata.json'
import CORPORATION_METADATA from '~/plugins/starpeace-client/api/mock-corporation-metadata.json'
import PLANETS_DETAILS from '~/plugins/starpeace-client/api/mock-planet-details.json'
import PLANETS_METADATA_BY_SYSTEM_ID from '~/plugins/starpeace-client/api/mock-planets-metadata.json'
import SYSTEMS_METADATA from '~/plugins/starpeace-client/api/mock-systems-metadata.json'
import TYCOON_METADATA from '~/plugins/starpeace-client/api/mock-tycoon-metadata.json'

MAIL_METADATA = {}

API_DELAY = 500

SESSION_TOKENS = {}
valid_session = (token) -> SESSION_TOKENS[token]? && TimeUtils.within_minutes(SESSION_TOKENS[token], 15)
register_session = () ->
  token = Utils.uuid()
  SESSION_TOKENS[token] = moment()
  token

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
        return {
          planet: PLANETS_DETAILS[query_parameters.planet_id]
        }

      return {} if root_path == '/planets/events'

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

      return {} if root_path == '/corporation/events'


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


      if root_path == '/mail/metadata'
        throw new Error(404) unless context.method == 'get'
        throw new Error(401) unless valid_session(query_parameters.session_token)
        throw new Error(400) unless query_parameters.corporation_id?.length
        return {
          mail: MAIL_METADATA[query_parameters.corporation_id] || []
        }


      return {} if root_path == '/buildings/metadata'

      return {} if root_path == '/inventions/metadata'
      return {} if root_path == '/inventions/status'




      throw new Error(404)

    get: (match, data) ->
      return data

    post: (match, data) ->
      return data
  }
]
