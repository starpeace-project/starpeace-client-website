import Translation from '~/plugins/starpeace-client/language/translation';

export default class CompanySeal {
  id: string;
  name_short: string;
  name_long: string;
  descriptions: Array<Translation>;
  playable: boolean;
  pros: Translation | undefined;
  cons: Translation | undefined;
  strengths: Translation | undefined;
  weaknesses: Translation | undefined;
  building_ids: Array<string> = [];

  constructor (id: string, name_short: string, name_long: string, descriptions: Array<Translation>, playable: boolean, pros: Translation | undefined, cons: Translation | undefined, strengths: Translation | undefined, weaknesses: Translation | undefined, building_ids: Array<string>) {
    this.id = id;
    this.name_short = name_short;
    this.name_long = name_long;
    this.descriptions = descriptions;
    this.playable = playable;
    this.pros = pros;
    this.cons = cons;
    this.strengths = strengths;
    this.weaknesses = weaknesses;
    this.building_ids = building_ids;
  }

  static fromJson (json: any): CompanySeal {
    return new CompanySeal(
      json.id,
      json.nameShort,
      json.nameLong,
      (json.descriptions ?? []).map(Translation.from_json),
      json.playable ?? false,
      json.pros ? Translation.from_json(json.pros) : undefined,
      json.cons ? Translation.from_json(json.cons) : undefined,
      json.strengths ? Translation.from_json(json.strengths) : undefined,
      json.weaknesses ? Translation.from_json(json.weaknesses) : undefined,
      json.buildingIds || []
    );
  }
}
