
import _ from 'lodash'

import MetadataCompany from '~/plugins/starpeace-client/industry/metadata-company.coffee'

export default class MetadataCorporation
  constructor: (@id) ->

  @from_json: (tycoon_id, json) ->
    metadata = new MetadataCorporation(json.id)
    metadata.tycoon_id = tycoon_id
    metadata.name = json.name
    metadata.system_id = json.system_id
    metadata.planet_id = json.planet_id
    metadata.cash = if json.cash? then +json.cash else 0
    metadata.cashflow = if json.cashflow? then +json.cashflow else 0
    metadata.building_count = if json.building_count? then +json.building_count else 0
    metadata.companies_metadata = _.map(json.companies || [], (company_json) => MetadataCompany.from_json(json.corporation_id, company_json))
    metadata
