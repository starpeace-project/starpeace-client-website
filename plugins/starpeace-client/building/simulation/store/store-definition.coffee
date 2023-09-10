import _ from 'lodash'

import SimulationDefinition from '~/plugins/starpeace-client/building/simulation/simulation-definition.coffee'
import StoreProduct from '~/plugins/starpeace-client/building/simulation/store/store-product.coffee'
import ResourceQuantity from '~/plugins/starpeace-client/industry/resource-quantity'

export default class StoreDefinition extends SimulationDefinition
  @TYPE: () -> 'STORE'

  constructor: (json) ->
    super(json)

  @from_json: (json) ->
    definition = new StoreDefinition(json)
    definition.labor = _.map(json.labor, ResourceQuantity.from_json)
    definition.operations = _.map(json.operations, ResourceQuantity.from_json)
    definition.products = _.map(json.products, StoreProduct.from_json)
    definition
