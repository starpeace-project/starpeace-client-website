import _ from 'lodash'

import Product from '~/plugins/starpeace-client/building/details/product.coffee'

export default class BuildingDetails
  constructor: () ->

  @from_json: (json) ->
    details = new BuildingDetails()
    details.id = json.id
    details.products = _.map(json.products, Product.from_json)
    details
