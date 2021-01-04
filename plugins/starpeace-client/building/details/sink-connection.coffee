
export default class SinkConnection
  constructor: () ->

  @from_json: (json) ->
    connection = new SinkConnection()
    connection.id = json.id

    connection.valid = json.valid

    connection.sink_company_id = json.sinkCompanyId
    connection.sink_company_name = json.sinkCompanyName

    connection.sink_building_id = json.sinkBuildingId
    connection.sink_building_name = json.sinkBuildingName
    connection.sink_building_map_x = json.sinkBuildingMapX
    connection.sink_building_map_y = json.sinkBuildingMapY

    connection.velocity = json.velocity
    connection.transport_cost = json.transportCost

    connection
