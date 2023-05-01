
export default class Company {
  id: string;
  tycoon_id: string;
  corporation_id: string;
  name: string;
  seal_id: string;

  constructor (id: string, tycoon_id: string, corporation_id: string, name: string, seal_id: string) {
    this.id = id;
    this.tycoon_id = tycoon_id;
    this.corporation_id = corporation_id;
    this.name = name;
    this.seal_id = seal_id;
  }

  static from_json (json: any): Company {
    return new Company(
      json.id,
      json.tycoonId,
      json.corporationId,
      json.name,
      json.sealId
    );
  }
}
