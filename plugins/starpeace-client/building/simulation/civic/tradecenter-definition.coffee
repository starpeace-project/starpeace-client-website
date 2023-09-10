import _ from 'lodash'

import SimulationDefinition from '~/plugins/starpeace-client/building/simulation/simulation-definition.coffee'
import ResourceQuantity from '~/plugins/starpeace-client/industry/resource-quantity'

export default class TradecenterDefinition extends SimulationDefinition
  @TYPE: () -> 'TRADECENTER'

  constructor: (json) ->
    super(json)

  @from_json: (json) ->
    definition = new TradecenterDefinition(json)
    definition.labor = _.map(json.labor, ResourceQuantity.from_json)
    definition
