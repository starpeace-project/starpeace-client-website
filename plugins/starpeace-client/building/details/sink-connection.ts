
export default class SinkConnection {
  id: string
  valid: boolean;

  sink_company_id: string;
  sink_company_name: string;

  sink_building_id: string;
  sink_building_name: string;
  sink_building_map_x: number;
  sink_building_map_y: number;

  velocity: number;
  transport_cost: number;

  constructor (id: string, valid: boolean, sink_company_id: string, sink_company_name: string, sink_building_id: string, sink_building_name: string, sink_building_map_x: number, sink_building_map_y: number, velocity: number, transport_cost: number) {
    this.id = id;
    this.valid = valid;
    this.sink_company_id = sink_company_id;
    this.sink_company_name = sink_company_name;
    this.sink_building_id = sink_building_id;
    this.sink_building_name = sink_building_name;
    this.sink_building_map_x = sink_building_map_x;
    this.sink_building_map_y = sink_building_map_y;
    this.velocity = velocity;
    this.transport_cost = transport_cost;
  }

  static fromJson (json: any): SinkConnection {
    return new SinkConnection(
      json.id,

      json.valid,

      json.sinkCompanyId,
      json.sinkCompanyName,

      json.sinkBuildingId,
      json.sinkBuildingName,
      json.sinkBuildingMapX,
      json.sinkBuildingMapY,

      json.velocity,
      json.transportCost
    );
  }
}
