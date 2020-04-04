
import Translation from '~/plugins/starpeace-client/language/translation.coffee'

export default class ResourceQuantity
  constructor: () ->

  @from_json: (json) ->
    quantity = new ResourceQuantity()
    quantity.resource_id = json.resourceId
    quantity.max_velocity = json.maxVelocity
    quantity.weight_efficiency = if json.weightEfficiency? then json.weightEfficiency else 0
    quantity.weight_quality = if json.weightQuality? then json.weightQuality else 0
    quantity
