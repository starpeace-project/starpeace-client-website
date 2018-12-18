
export default class MetadataCompanyInventions
  constructor: (@company_id) ->

  @from_json: (json) ->
    metadata = new MetadataCompanyInventions(json.company_id)
    metadata.pending_inventions = json.pending_inventions || []
    metadata.completed_ids = json.completed_ids || []
    metadata
