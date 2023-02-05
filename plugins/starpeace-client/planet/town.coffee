

export default class Town
  constructor: (@id) ->

  @from_json: (json) ->
    metadata = new Town(json.id)
    metadata.name = json.name
    metadata.seal_id = json.sealId
    metadata.color = json.color
    metadata.building_id = json.buildingId
    metadata.map_x = json.mapX
    metadata.map_y = json.mapY
    metadata
