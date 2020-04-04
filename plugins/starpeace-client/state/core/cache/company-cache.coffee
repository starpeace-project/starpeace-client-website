
import moment from 'moment'
import Vue from 'vue'

import Cache from '~/plugins/starpeace-client/state/core/cache/cache.coffee'
import Company from '~/plugins/starpeace-client/industry/company.coffee'

import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class CompanyCache extends Cache
  constructor: () ->
    super()

  reset_planet: () ->
    @company_metadata_by_id = {}

  load_companies_metadata: (companies) ->
    if typeof companies == Company
      Vue.set(@company_metadata_by_id, company_metadata.id, companies)
    else if Array.isArray(companies)
      Vue.set(@company_metadata_by_id, metadata.id, metadata) for metadata in companies

  metadata_for_id: (company_id) -> @company_metadata_by_id[company_id]
