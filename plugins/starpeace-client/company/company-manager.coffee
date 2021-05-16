
import moment from 'moment'

import Company from '~/plugins/starpeace-client/company/company.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class CompanyManager
  constructor: (@api, @ajax_state, @client_state) ->

  create: (company_name, seal_id) ->
    planet_id = @client_state.player.planet_id
    corporation_id = @client_state.player.corporation_id
    throw Error() if !@client_state.has_session() || !planet_id? || !corporation_id?
    await @ajax_state.locked('company_create', planet_id, =>
      company = Company.from_json(await @api.create_company(planet_id, company_name, seal_id))
      @client_state.core.company_cache.load_companies_metadata(company)
      @client_state.core.corporation_cache.add_corporation_company(corporation_id, company)
      @client_state.corporation.add_company_id(company.id)
      company
    )
