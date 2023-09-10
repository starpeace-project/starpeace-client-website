
import Translation from '~/plugins/starpeace-client/language/translation';

export default class InventionDefinition {
  id: string;
  industry_category_id: string;
  industry_type_id: string;
  name: Translation;
  description: Translation;
  properties: Record<string, any> = {};
  depends_on: Array<string> = [];

  constructor (id: string, industry_category_id: string, industry_type_id: string, name: Translation, description: Translation, properties: Record<string, any>, depends_on: Array<string>) {
    this.id = id;
    this.industry_category_id = industry_category_id;
    this.industry_type_id = industry_type_id;
    this.name = name;
    this.description = description;
    this.properties = properties;
    this.depends_on = depends_on;
  }

  static fromJson (json: any): InventionDefinition {
    return new InventionDefinition(
      json.id,
      json.industryCategoryId,
      json.industryTypeId,
      Translation.from_json(json.name),
      Translation.from_json(json.description),
      json.properties ?? {},
      json.dependsOnIds ?? []
    );
  }
}
