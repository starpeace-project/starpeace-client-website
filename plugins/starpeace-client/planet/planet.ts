
export default class Planet {
  id: string;
  name: string;
  enabled: boolean;
  planetType: string;
  planetWidth: number;
  planetHeight: number;
  mapId: string;
  population: number;
  investmentValue: number;
  corporationCount: number;
  onlineCount: number;

  constructor (id: string, name: string, enabled: boolean, planet_type: string, planet_width: number, planet_height: number, map_id: string, population: number, investment_value: number, corporation_count: number, onlineCount: number) {
    this.id = id;
    this.name = name;
    this.enabled = enabled;
    this.planetType = planet_type;
    this.planetWidth = planet_width;
    this.planetHeight = planet_height;
    this.mapId = map_id;
    this.population = population;
    this.investmentValue = investment_value;
    this.corporationCount = corporation_count;
    this.onlineCount = onlineCount;
  }

  get planet_type (): string {
    return this.planetType;
  }
  get planet_width (): number {
    return this.planetWidth;
  }
  get planet_height (): number {
    return this.planetHeight;
  }
  get map_id (): string {
    return this.mapId;
  }
  get investment_value (): number {
    return this.investmentValue;
  }
  get corporation_count (): number {
    return this.corporationCount;
  }

  static from_json (json: any): Planet {
    return new Planet(
      json.id,
      json.name,
      json.enabled == true || json.enabled == "true",
      json.planetType,
      json.planetWidth,
      json.planetHeight,
      json.mapId,
      json.population,
      json.investmentValue,
      json.corporationCount,
      json.onlineCount
    );
  }
}
