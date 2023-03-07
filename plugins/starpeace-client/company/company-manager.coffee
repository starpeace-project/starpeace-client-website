
import Company from '~/plugins/starpeace-client/company/company.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class CompanyManager
  constructor: (@api, @ajax_state, @client_state) ->

  create: (company_name, seal_id) ->
    corporation_id = @client_state.player.corporation_id
    throw Error() if !@client_state.has_session() || !corporation_id?
    await @ajax_state.locked('company_create', corporation_id, =>
      company = Company.from_json(await @api.create_company(company_name, seal_id))
      @client_state.core.company_cache.load_companies_metadata(company)
      @client_state.core.corporation_cache.add_corporation_company(corporation_id, company)
      @client_state.corporation.add_company_id(company.id)
      company
    )

  load_by_company: (company_id) ->
    company = @client_state.core.company_cache.metadata_for_id(company_id)
    return company if company?

    throw Error() if !@client_state.has_session() || !company_id?
    await @ajax_state.locked('company_metadata', company_id, =>
      company = Company.from_json(await @api.company_for_id(company_id))
      @client_state.core.company_cache.load_companies_metadata(company)
      company
    )
