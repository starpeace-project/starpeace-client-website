
export default class ServiceLevel {
  type: string;
  value: string;

  constructor (type: string, value: string) {
    this.type = type;
    this.value = value;
  }

  static fromJson (json: any): ServiceLevel {
    return new ServiceLevel(json.type, json.value);
  }
}
