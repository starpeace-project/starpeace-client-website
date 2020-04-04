
export default class StorageQuantity

  @from_json: (json) ->
    output = new StorageQuantity()
    output.resource_id = json.resourceId
    output.max = json.max
    output
