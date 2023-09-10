import _ from 'lodash'

import SimulationDefinition from '~/plugins/starpeace-client/building/simulation/simulation-definition.coffee'
import ResourceQuantity from '~/plugins/starpeace-client/industry/resource-quantity'

export default class OfficeDefinition extends SimulationDefinition
  @TYPE: () -> 'OFFICE'

  constructor: (json) ->
    super(json)

  @from_json: (json) ->
    definition = new OfficeDefinition(json)
    definition.labor = _.map(json.labor, ResourceQuantity.from_json)
    definition.efficiency = json.efficiency
    definition.capacity = json.capacity
    definition
