
export default class Town {
  id: string;
  name: string | undefined;
  seal_id: string | undefined;
  color: number | undefined;
  building_id: string | undefined;
  map_x: number | undefined;
  map_y: number | undefined;

  constructor (id: string) {
    this.id = id;
  }

  static from_json (json: any): Town {
    return Town.fromJson(json);
  }
  static fromJson (json: any) {
    const metadata = new Town(json.id);
    metadata.name = json.name;
    metadata.seal_id = json.sealId;
    metadata.color = json.color;
    metadata.building_id = json.buildingId;
    metadata.map_x = json.mapX;
    metadata.map_y = json.mapY;
    return metadata;
  }
}