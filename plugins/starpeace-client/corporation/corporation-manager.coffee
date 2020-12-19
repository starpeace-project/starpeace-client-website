
import moment from 'moment'

import Corporation from '~/plugins/starpeace-client/corporation/corporation.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class CorporationManager
  constructor: (@api, @ajax_state, @client_state) ->

  load_by_corporation: (corporation_id) ->
    corporation = @client_state.core.corporation_cache.metadata_for_id(corporation_id)
    return corporation if corporation?

    throw Error() if !@client_state.has_session() || !corporation_id?
    await @ajax_state.locked('corporation_metadata', corporation_id, =>
      corporation_json = await @api.corporation_for_id(corporation_id)
      corporation = Corporation.from_json(corporation_json)
      @client_state.core.corporation_cache.load_corporation(corporation)
      @client_state.core.company_cache.load_companies_metadata(corporation.companies)
      corporation
    )

  create: (corporation_name) ->
    new Promise (done, error) =>
      planet_id = @client_state.player.planet_id
      if !@client_state.has_session() || !planet_id? || @ajax_state.is_locked('corporation_create', @client_state.player.planet_id)
        error()
      else
        @ajax_state.lock('corporation_create', planet_id)
        @api.create_corporation(planet_id, corporation_name)
          .then (json) =>
            corporation = Corporation.from_json(json)
            @client_state.core.corporation_cache.load_corporation(corporation)
            @client_state.core.company_cache.load_companies_metadata(corporation.companies)
            @ajax_state.unlock('corporation_create', planet_id)
            done(corporation)

          .catch (err) =>
            console.error err
            @ajax_state.unlock('corporation_create', planet_id) # FIXME: TODO add error handling
            error()

  load_cashflow: () ->
    new Promise (done, error) =>
      corporation_id = @client_state.player.corporation_id
      if !@client_state.has_session() || !corporation_id? || @ajax_state.is_locked('corporation_cashflow', corporation_id)
        done()
      else
        lock = @ajax_state.with_lock('corporation_events', corporation_id, done, error)
        @api.cashflow_for_corporation(corporation_id)
          .then (cashflow_json) =>
            mailAt = if cashflow_json.lastMailAt? then moment(cashflow_json.lastMailAt) else null
            @client_state.corporation.update_cashflow(mailAt, cashflow_json.cash || 0, cashflow_json.cashflow || 0)
            @client_state.corporation.update_cashflow_companies(cashflow_json.companies || [])
            lock.done()

          .catch (err) =>
            # FIXME: TODO add error handling
            lock.error()
