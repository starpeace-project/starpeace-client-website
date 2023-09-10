import Translation from '~/plugins/starpeace-client/language/translation';

export default class IndustryCategory {
  id: string;
  label: Translation;

  constructor (id: string, label: Translation) {
    this.id = id;
    this.label = label;
  }

  static fromJson (json: any): IndustryCategory {
    return new IndustryCategory(json.id, Translation.from_json(json.label));
  }
}
