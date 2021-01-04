import _ from 'lodash'

import SinkConnection from '~/plugins/starpeace-client/building/details/sink-connection.coffee'

export default class Product
  constructor: () ->

  @from_json: (json) ->
    product = new Product()
    product.resource_id = json.resourceId
    product.price = json.price
    product.total_velocity = json.totalVelocity
    product.quality = json.quality
    product.connections = _.map(json.connections, SinkConnection.from_json)
    product
