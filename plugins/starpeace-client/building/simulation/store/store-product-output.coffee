import _ from 'lodash'

import StoreProductCustomer from '~/plugins/starpeace-client/building/simulation/store/store-product-customer.coffee'

export default class StoreProductOutput

  @from_json: (json) ->
    output = new StoreProductOutput()
    output.resource_id = json.resourceId
    output.max_velocity = json.maxVelocity
    output.customers = _.map(json.customers, StoreProductCustomer.from_json)
    output
