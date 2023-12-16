import { Translation } from '@starpeace/starpeace-assets-types';

export default class InventionDefinition {
  id: string;
  industryCategoryId: string;
  industryTypeId: string;
  name: Translation;
  description: Translation;
  properties: Record<string, any> = {};
  dependsOnIds: Array<string> = [];

  constructor (id: string, industryCategoryId: string, industryTypeId: string, name: Translation, description: Translation, properties: Record<string, any>, dependsOnIds: Array<string>) {
    this.id = id;
    this.industryCategoryId = industryCategoryId;
    this.industryTypeId = industryTypeId;
    this.name = name;
    this.description = description;
    this.properties = properties;
    this.dependsOnIds = dependsOnIds;
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
