import Cache from '~/plugins/starpeace-client/state/core/cache/cache'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class CompanyCache extends Cache
  constructor: () ->
    super()

  reset_planet: () ->
    @company_metadata_by_id = {}

  load_companies_metadata: (companies) ->
    if Array.isArray(companies)
      @company_metadata_by_id[metadata.id] = metadata for metadata in companies
    else
      @company_metadata_by_id[companies.id] = companies

  metadata_for_id: (company_id) -> @company_metadata_by_id[company_id]
