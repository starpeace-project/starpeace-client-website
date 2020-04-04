
export default class Company
  constructor: (@id) ->

  @from_json: (json) ->
    metadata = new Company(json.id)
    metadata.corporation_id = json.corporationId
    metadata.name = json.name
    metadata.seal_id = json.sealId
    metadata
