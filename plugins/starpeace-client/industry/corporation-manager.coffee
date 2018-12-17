
import moment from 'moment'

import MetadataCorporation from '~/plugins/starpeace-client/industry/metadata-corporation.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class CorporationManager
  constructor: (@api, @ajax_state, @client_state) ->

  load_metadata: (corporation_id) ->
    new Promise (done, error) =>
      if !@client_state.has_session() || !corporation_id? || @ajax_state.is_locked('corporation_metadata', corporation_id)
        done()
      else
        @ajax_state.lock('corporation_metadata', corporation_id)
        @api.corporation_metadata(@client_state.session.session_token, corporation_id)
          .then (metadata_json) =>
            corporation_metadata = MetadataCorporation.from_json(metadata_json.tycoon_id, metadata_json)

            @client_state.core.corporation_cache.load_corporation_metadata(corporation_metadata)
            @client_state.core.company_cache.load_companies_metadata(corporation_metadata.companies_metadata)

            @client_state.corporation.details_as_of = moment() if @client_state.player.corporation_id == corporation_metadata.id

            @ajax_state.unlock('corporation_metadata', corporation_id)
            done()

          .catch (err) =>
            @ajax_state.unlock('corporation_metadata', corporation_id) # FIXME: TODO add error handling
            error()


  load_events: () ->
    new Promise (done, error) =>
      corporation_id = @client_state.player.corporation_id
      last_update = @client_state.corporation.events_as_of || @client_state.corporation.details_as_of

      if !@client_state.has_session() || !corporation_id? || !last_update? || @ajax_state.is_locked('corporation_events', corporation_id)
        done()
      else
        @ajax_state.lock('corporation_events', corporation_id)
        @api.corporation_events(@client_state.session.session_token, corporation_id, last_update)
          .then (corporation_events) =>
            unless corporation_id == corporation_events.id && @client_state.player.corporation_id == corporation_events.id
              @ajax_state.unlock('corporation_events', corporation_id)
              error()

            @client_state.core.corporation_cache.update_corporation_cash(corporation_id, corporation_events.cash || 0, corporation_events.cashflow || 0)
            @client_state.core.company_cache.update_companies(corporation_events.companies || [])
            @client_state.corporation.events_as_of = moment()

            @ajax_state.unlock('corporation_events', corporation_id)
            done()

          .catch (err) =>
            @ajax_state.unlock('corporation_events', corporation_id) # FIXME: TODO add error handling
            error()
