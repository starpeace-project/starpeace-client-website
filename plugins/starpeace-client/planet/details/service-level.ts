
export default class ServiceLevel {
  typeId: string;
  value: string;

  constructor (typeId: string, value: string) {
    this.typeId = typeId;
    this.value = value;
  }

  static fromJson (json: any): ServiceLevel {
    return new ServiceLevel(json.typeId, json.value);
  }
}
