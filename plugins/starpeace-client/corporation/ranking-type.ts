import { Translation } from '@starpeace/starpeace-assets-types';

export default class RankingType {
  id: string;
  parent_id: string;
  type: string;
  category_total: boolean;
  unit: string;
  label: Translation | undefined;
  industryCategoryId: string;
  industryTypeId: string;
  children: Array<RankingType>;

  constructor (id: string, parent_id: string, type: string, category_total: boolean, unit: string, label: Translation | undefined, industryCategoryId: string, industryTypeId: string, children: Array<RankingType>) {
    this.id = id;
    this.parent_id = parent_id;
    this.type = type;
    this.category_total = category_total;
    this.unit = unit;
    this.label = label;
    this.industryCategoryId = industryCategoryId;
    this.industryTypeId = industryTypeId;
    this.children = children;
  }

  static fromJson (json: any): RankingType {
    return new RankingType(
      json.id,
      json.parentId,
      json.type,
      json.categoryTotal ?? false,
      json.unit,
      json.label ? Translation.from_json(json.label) : undefined,
      json.industryCategoryId,
      json.industryTypeId,
      (json.children ?? []).map(RankingType.fromJson)
    );
  }
}
