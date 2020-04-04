import _ from 'lodash'

import SimulationDefinition from '~/plugins/starpeace-client/building/simulation/simulation-definition.coffee'
import ResourceQuantity from '~/plugins/starpeace-client/industry/resource-quantity.coffee'

export default class TownhallDefinition extends SimulationDefinition
  @TYPE: () -> 'TOWNHALL'

  constructor: (json) ->
    super(json)

  @from_json: (json) ->
    definition = new TownhallDefinition(json)
    definition.labor = _.map(json.labor, ResourceQuantity.from_json)
    definition
