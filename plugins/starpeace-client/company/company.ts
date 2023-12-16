
export default class Company {
  id: string;
  tycoonId: string;
  corporationId: string;
  name: string;
  sealId: string;

  constructor (id: string, tycoonId: string, corporationId: string, name: string, sealId: string) {
    this.id = id;
    this.tycoonId = tycoonId;
    this.corporationId = corporationId;
    this.name = name;
    this.sealId = sealId;
  }

  get tycoon_id (): string {
    return this.tycoonId;
  }
  get corporation_id (): string {
    return this.corporationId;
  }
  get seal_id (): string {
    return this.sealId;
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
