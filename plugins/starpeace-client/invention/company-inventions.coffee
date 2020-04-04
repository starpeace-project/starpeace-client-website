
export default class CompanyInventions
  constructor: (@company_id) ->

  @from_json: (json) ->
    metadata = new CompanyInventions(json.companyId)
    metadata.pending_inventions = json.pendingInventions || []
    metadata.completed_ids = json.completedIds || []
    metadata
