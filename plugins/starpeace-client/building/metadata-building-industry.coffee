
export default class MetadataBuildingIndustry
  constructor: () ->

  @from_json: (json) ->
    metadata = new MetadataBuildingIndustry()
    metadata.budget = json.budget || 0
    metadata.cost = json.cost || 0
    metadata.required_inputs = json.required_inputs || []
    metadata.optional_inputs = json.optional_inputs || []
    metadata.outputs = json.outputs || []
    metadata
