
export default class MailEntity {
  id: string;
  name: string;

  constructor (id: string, name: string) {
    this.id = id;
    this.name = name;
  }

  static from_json (json: any): MailEntity {
    return new MailEntity(json.id, json.name);
  }
}
