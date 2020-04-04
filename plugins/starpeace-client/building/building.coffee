
export default class Building
  constructor: (@id) ->

  @from_json: (json) ->
    metadata = new Building(json.id)
    metadata.tycoon_id = json.tycoonId
    metadata.corporation_id = json.corporationId
    metadata.company_id = json.companyId
    metadata.definition_id = json.definitionId
    metadata.name = json.name
    metadata.map_x = json.mapX
    metadata.map_y = json.mapY
    metadata.stage = json.stage || 0
    metadata
