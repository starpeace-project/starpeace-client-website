
import moment from 'moment'

import Corporation from '~/plugins/starpeace-client/corporation/corporation.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class CorporationManager
  constructor: (@api, @ajax_state, @client_state) ->

  load_by_corporation: (corporation_id) ->
    new Promise (done, error) =>
      if !@client_state.has_session() || !corporation_id? || @ajax_state.is_locked('corporation_metadata', corporation_id)
        done()
      else
        @ajax_state.lock('corporation_metadata', corporation_id)
        @api.corporation_for_id(corporation_id)
          .then (json) =>
            corporation = Corporation.from_json(json)
            @client_state.core.corporation_cache.load_corporation_metadata(corporation)
            @client_state.core.company_cache.load_companies_metadata(corporation.companies)
            @ajax_state.unlock('corporation_metadata', corporation_id)
            done(corporation)

          .catch (err) =>
            @ajax_state.unlock('corporation_metadata', corporation_id) # FIXME: TODO add error handling
            error()

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
            @client_state.core.corporation_cache.load_corporation_metadata(corporation)
            @client_state.core.company_cache.load_companies_metadata(corporation.companies)
            @ajax_state.unlock('corporation_create', planet_id)
            done(corporation)

          .catch (err) =>
            console.log err
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
            @client_state.corporation.update_cashflow(cashflow_json?.cash || 0, cashflow_json?.cashflow || 0)
            @client_state.corporation.update_cashflow_companies(cashflow_json?.companies || [])
            lock.done()

          .catch (err) =>
            # FIXME: TODO add error handling
            lock.error()
