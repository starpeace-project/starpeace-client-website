import _ from 'lodash'

import CommerceDetails from '~/plugins/starpeace-client/planet/details/commerce-details.coffee'
import EmploymentDetails from '~/plugins/starpeace-client/planet/details/employment-details.coffee'
import HousingDetails from '~/plugins/starpeace-client/planet/details/housing-details.coffee'
import PopulationDetails from '~/plugins/starpeace-client/planet/details/population-details.coffee'
import ServiceLevel from '~/plugins/starpeace-client/planet/details/service-level.coffee'
import TaxDetails from '~/plugins/starpeace-client/planet/details/tax-details.coffee'

import CurrentTerm from '~/plugins/starpeace-client/planet/politics/current-term.coffee'
import NextTerm from '~/plugins/starpeace-client/planet/politics/next-term.coffee'

export default class TownDetails
  constructor: () ->

  @from_json: (json) ->
    metadata = new TownDetails()
    metadata.id = json.id
    metadata.qol = json.qol
    metadata.services = _.map(json.services, ServiceLevel.from_json)
    metadata.commerce = _.map(json.commerce, CommerceDetails.from_json)
    metadata.taxes = _.map(json.taxes, TaxDetails.from_json)
    metadata.population = _.map(json.population, PopulationDetails.from_json)
    metadata.employment = _.map(json.employment, EmploymentDetails.from_json)
    metadata.housing = _.map(json.housing, HousingDetails.from_json)
    metadata.current_term = CurrentTerm.from_json(json.currentTerm)
    metadata.next_term = NextTerm.from_json(json.nextTerm)
    metadata
