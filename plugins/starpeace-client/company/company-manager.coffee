
import moment from 'moment'

import Company from '~/plugins/starpeace-client/company/company.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class CompanyManager
  constructor: (@api, @ajax_state, @client_state) ->

  create: (company_name, seal_id) ->
    new Promise (done, error) =>
      planet_id = @client_state.player.planet_id
      corporation_id = @client_state.current_corporation_metadata()?.id
      if !@client_state.has_session() || !planet_id? || !corporation_id? || @ajax_state.is_locked('company_create', @client_state.player.planet_id)
        error()
      else
        @ajax_state.lock('company_create', planet_id)
        @api.create_company(planet_id, company_name, seal_id)
          .then (json) =>
            company = Company.from_json(json)

            @client_state.core.company_cache.load_companies_metadata(company)
            @client_state.core.corporation_cache.add_corporation_company(corporation_id, company)
            @client_state.corporation.add_company_id(company.id)

            @ajax_state.unlock('company_create', planet_id)
            done(company)

          .catch (err) =>
            console.error err
            @ajax_state.unlock('company_create', planet_id) # FIXME: TODO add error handling
            error()
