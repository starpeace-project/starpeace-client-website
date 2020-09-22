
import _ from 'lodash'

import Company from '~/plugins/starpeace-client/company/company.coffee'

export default class Corporation
  constructor: (@id) ->

  @from_json: (json) ->
    metadata = new Corporation(json.id)
    metadata.tycoon_id = json.tycoonId
    metadata.level_id = json.levelId
    metadata.name = json.name
    metadata.planet_id = json.planetId
    metadata.level_id = json.levelId
    metadata.building_count = if json.buildingCount? then +json.buildingCount else 0
    metadata.companies = _.map(json.companies || [], (company_json) => Company.from_json(company_json))
    metadata
