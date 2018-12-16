
export default class MetadataCompany
  constructor: (@id) ->

  @from_json: (corporation_id, json) ->
    metadata = new MetadataCompany(json.id)
    metadata.corporation_id = corporation_id
    metadata.name = json.name
    metadata.seal_id = json.seal_id
    metadata.cashflow = if json.cashflow? then +json.cashflow else 0
    metadata
