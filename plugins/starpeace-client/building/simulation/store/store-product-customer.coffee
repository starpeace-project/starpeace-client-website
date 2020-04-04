import _ from 'lodash'

export default class StoreProductCustomer

  @from_json: (json) ->
    customer = new StoreProductCustomer()
    customer.resource_id = json.resourceId
    customer.max_velocity = json.maxVelocity
    customer.probability = json.probability
    customer
