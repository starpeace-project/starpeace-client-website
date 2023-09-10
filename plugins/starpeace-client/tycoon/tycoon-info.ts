
export default class TycoonInfo {
  type: string;
  tycoonId: string;
  tycoonName: string;
  corporationId: string;
  corporationName: string;

  constructor (type: string, tycoonId: string, tycoonName: string, corporationId: string, corporationName: string) {
    this.type = type;
    this.tycoonId = tycoonId;
    this.tycoonName = tycoonName;
    this.corporationId = corporationId;
    this.corporationName = corporationName;
  }

  static fromJson (json: any): TycoonInfo {
    return new TycoonInfo(
      json.type,
      json.tycoonId,
      json.tycoonName,
      json.corporationId,
      json.corporationName
    );
  }
}
