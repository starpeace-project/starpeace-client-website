
export default class ConstructionQuantity

  @from_json: (json) ->
    quantity = new ConstructionQuantity()
    quantity.resource_id = json.resourceId
    quantity.quantity = json.quantity
    quantity.max_velocity = json.maxVelocity
    quantity
