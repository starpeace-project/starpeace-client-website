import _ from 'lodash'

import StoreProductOutput from '~/plugins/starpeace-client/building/simulation/store/store-product-output.coffee'
import ResourceQuantity from '~/plugins/starpeace-client/industry/resource-quantity.coffee'

export default class StoreProduct

  @from_json: (json) ->
    stage = new StoreProduct()
    stage.inputs = _.map(json.inputs, ResourceQuantity.from_json)
    stage.outputs = _.map(json.outputs, StoreProductOutput.from_json)
    stage
