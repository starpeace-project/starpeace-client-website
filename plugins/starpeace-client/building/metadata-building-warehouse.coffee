
export default class MetadataBuildingWarehouse
  constructor: () ->

  @from_json: (json) ->
    metadata = new MetadataBuildingWarehouse()
    metadata.cost = json.cost || 0
    metadata.required_inputs = json.required_inputs || []
    metadata.optional_inputs = json.optional_inputs || []
    metadata.storage = json.storage || []
    metadata
