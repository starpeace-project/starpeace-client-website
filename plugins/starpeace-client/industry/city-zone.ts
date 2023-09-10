import Translation from '~/plugins/starpeace-client/language/translation';

export default class CityZone {
  id: string;
  label: Translation;
  value: string;
  color: number;
  mini_map_color: number;
  included_city_zone_ids: Array<string>;

  constructor (id: string, label: Translation, value: string, color: number, mini_map_color: number, included_city_zone_ids: Array<string>) {
    this.id = id;
    this.label = label;
    this.value = value;
    this.color = color;
    this.mini_map_color = mini_map_color;
    this.included_city_zone_ids = included_city_zone_ids;
  }

  matches (other_id: string): boolean {
    return this.id == other_id || this.included_city_zone_ids.indexOf(other_id) >= 0;
  }

  static fromJson (json: any): CityZone {
    return new CityZone(
      json.id,
      Translation.from_json(json.label),
      json.value,
      json.color ?? 0,
      json.miniMapColor ?? json.color ?? 0,
      json.includedCityZoneIds ?? []
    );
  }
}
