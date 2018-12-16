
import moment from 'moment'
import Vue from 'vue'

import EventListener from '~/plugins/starpeace-client/state/event-listener.coffee'
import MetadataCompany from '~/plugins/starpeace-client/industry/metadata-company.coffee'
import MetadataTycoon from '~/plugins/starpeace-client/tycoon/metadata-tycoon.coffee'

import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class CompanyCache
  constructor: () ->
    @event_listener = new EventListener()
    @reset_state()

  reset_state: () ->
    @company_metadata_by_id = {}

  load_companies_metadata: (company_metadata) ->
    if typeof company_metadata == MetadataCompany
      Vue.set(@company_metadata_by_id, company_metadata.id, company_metadata)
    else if Array.isArray(company_metadata)
      Vue.set(@company_metadata_by_id, metadata.id, metadata) for metadata in company_metadata

  metadata_for_id: (company_id) -> @company_metadata_by_id[company_id]

  update_company: (company) ->
    if @company_metadata_by_id[company.id]?
      @company_metadata_by_id[company.id].cash = company.cash if company.cash?
      @company_metadata_by_id[company.id].cashflow = company.cashflow if company.cashflow?

  update_companies: (companies) ->
    if Array.isArray(companies)
      @update_company(company) for company in companies
    else
      @update_company(companies)
