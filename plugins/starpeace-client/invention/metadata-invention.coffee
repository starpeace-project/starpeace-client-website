
export default class MetadataInvention
  constructor: (@id) ->

  @from_json: (json) ->
    metadata = new MetadataInvention(json.id)
    metadata.category = json.category
    metadata.industry_type = json.industry_type
    metadata.name_key = json.name_key
    metadata.description_key = json.description_key
    metadata.properties = json.properties
    metadata.depends_on = json.depends_on || []
    metadata
