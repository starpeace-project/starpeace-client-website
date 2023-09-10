import Translation from '~/plugins/starpeace-client/language/translation';

export default class IndustryType {
  id: string;
  label: Translation;

  constructor (id: string, label: Translation) {
    this.id = id;
    this.label = label;
  }

  static fromJson (json: any): IndustryType {
    return new IndustryType(json.id, Translation.from_json(json.label));
  }
}
