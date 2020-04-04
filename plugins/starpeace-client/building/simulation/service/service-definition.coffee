import _ from 'lodash'

import SimulationDefinition from '~/plugins/starpeace-client/building/simulation/simulation-definition.coffee'
import ResourceQuantity from '~/plugins/starpeace-client/industry/resource-quantity.coffee'

export default class ServiceDefinition extends SimulationDefinition
  @TYPE: () -> 'SERVICE'

  constructor: (json) ->
    super(json)

  @from_json: (json) ->
    definition = new ServiceDefinition(json)
    definition.labor = _.map(json.labor, ResourceQuantity.from_json)
    definition.service = _.map(json.service, ResourceQuantity.from_json)
    definition
