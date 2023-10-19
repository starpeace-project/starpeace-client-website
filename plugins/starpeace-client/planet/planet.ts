import { DateTime }  from 'luxon';

export default class Planet {
  id: string;
  name: string;
  enabled: boolean;
  planet_type: string;
  planet_width: number;
  planet_height: number;
  map_id: string;
  population: number;
  investment_value: number;
  corporation_count: number;
  online_count: number;

  as_of: DateTime;

  constructor (id: string, name: string, enabled: boolean, planet_type: string, planet_width: number, planet_height: number, map_id: string, population: number, investment_value: number, corporation_count: number, online_count: number) {
    this.id = id;
    this.name = name;
    this.enabled = enabled;
    this.planet_type = planet_type;
    this.planet_width = planet_width;
    this.planet_height = planet_height;
    this.map_id = map_id;
    this.population = population;
    this.investment_value = investment_value;
    this.corporation_count = corporation_count;
    this.online_count = online_count;
    this.as_of = DateTime.now();
  }

  is_fresh (): boolean {
    return this.as_of && DateTime.now() < this.as_of.plus({ minutes: 15 });
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