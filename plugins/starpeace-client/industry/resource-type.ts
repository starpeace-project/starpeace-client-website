import Translation from '~/plugins/starpeace-client/language/translation'

export default class ResourceType {
  id: string;
  label_plural: Translation;
  unit_id: string;
  price: number;

  constructor (id: string, label_plural: Translation, unit_id: string, price: number) {
    this.id = id;
    this.label_plural = label_plural;
    this.unit_id = unit_id;
    this.price = price;
  }

  static fromJson (json: any): ResourceType {
    return new ResourceType(
      json.id,
      Translation.from_json(json.labelPlural),
      json.unitId,
      json.price
    );
  }
}
