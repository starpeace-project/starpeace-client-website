import moment from 'moment'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class CorporationManager
  constructor: (@api, @event_listener, @game_state) ->

  load_metadata: (corporation_id) ->
    new Promise (done, error) =>
      @game_state.session_state.start_corporation_metadata_request()
      @api.corporation_metadata(@game_state.session_state.session_token, corporation_id)
        .then (metadata) =>
          @game_state.session_state.set_corporation_metadata(metadata)
          @game_state.session_state.corporation.cash = metadata.cash || 0
          @game_state.session_state.corporation.cashflow = metadata.cashflow || 0
          @game_state.session_state.corporation.update_companies(metadata.companies || [])
          @game_state.session_state.finish_tycoon_metadata_request()
          @event_listener.notify_corporation_metadata_listeners()
          done()

        .catch (err) =>
          @game_state.session_state.finish_corporation_metadata_request()
          # FIXME: TODO: add error handling (failed to get tycoon metadata)
          error()

  load_events: (corporation_id) ->
    return unless @game_state.session_state.session_token?.length
    return if @game_state.session_state.is_refreshing_corporation_events()

    last_update = @game_state.session_state.corporation_events_as_of || @game_state.session_state.corporation_metadata_as_of
    return unless last_update?

    new Promise (done, error) =>
      @game_state.session_state.start_corporation_events_request()
      @api.corporation_events(@game_state.session_state.session_token, corporation_id, last_update)
        .then (corporation_events) =>
          return if @game_state.verify_corporation(corporation_events.id)

          @game_state.session_state.corporation.cash = corporation_events.cash || 0
          @game_state.session_state.corporation.cashflow = corporation_events.cashflow || 0
          @game_state.session_state.corporation.update_companies(corporation_events.companies || [])
          @game_state.session_state.corporation_events_as_of = moment()
          @game_state.session_state.finish_corporation_events_request()
          done()

        .catch (err) =>
          # FIXME: TODO: add error handling (failed to get corp events)
          @game_state.session_state.finish_corporation_events_request()
          console.log err
          error()
