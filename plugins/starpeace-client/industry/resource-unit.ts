import Translation from '~/plugins/starpeace-client/language/translation';

export default class ResourceUnit {
  id: string;
  label_plural: Translation;

  constructor (id: string, label_plural: Translation) {
    this.id = id;
    this.label_plural = label_plural;
  }

  static fromJson (json: any): ResourceUnit {
    return new ResourceUnit(json.id, Translation.from_json(json.labelPlural));
  }
}
