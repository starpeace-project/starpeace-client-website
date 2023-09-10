import Translation from '~/plugins/starpeace-client/language/translation';

export default class Level {
  id: string;
  label: Translation;
  description: Translation;
  level: number;
  facilityLimit: number;
  supplierPriority: number;
  supplierIfel: boolean;
  rewardPrestige: number;
  refundResearch: number;
  refundDemolition: number;
  requiredFee: number;
  requiredHourlyProfit: number;
  requiredPrestige: number;

  constructor (id: string, label: Translation, description: Translation, level: number, facilityLimit: number, supplierPriority: number, supplierIfel: boolean, rewardPrestige: number, refundResearch: number, refundDemolition: number, requiredFee: number, requiredHourlyProfit: number, requiredPrestige: number) {
    this.id = id;
    this.label = label;
    this.description = description;
    this.level = level;
    this.facilityLimit = facilityLimit;
    this.supplierPriority = supplierPriority;
    this.supplierIfel = supplierIfel;
    this.rewardPrestige = rewardPrestige;
    this.refundResearch = refundResearch;
    this.refundDemolition = refundDemolition;
    this.requiredFee = requiredFee;
    this.requiredHourlyProfit = requiredHourlyProfit;
    this.requiredPrestige = requiredPrestige;
  }

  static fromJson (json: any): Level {
    return new Level(
      json.id,
      Translation.from_json(json.label),
      Translation.from_json(json.description),
      json.level ?? 0,
      json.facilityLimit,
      json.supplierPriority,
      json.supplierIfel,
      json.rewardPrestige,
      json.refundResearch,
      json.refundDemolition,
      json.requiredFee,
      json.requiredHourlyProfit,
      json.requiredPrestige
    );
  }
}
