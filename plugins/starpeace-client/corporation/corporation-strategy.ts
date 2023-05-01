
export default class CorporationStrategy {
  id: string;
  corporationId: string;
  policy: string;
  otherTycoonId: string;
  otherTycoonName: string;
  otherCorporationId: string;
  otherCorporationName: string;
  otherPolicy: string;

  constructor (id: string, corporationId: string, policy: string, otherTycoonId: string, otherTycoonName: string, otherCorporationId: string, otherCorporationName: string, otherPolicy: string) {
    this.id = id;
    this.corporationId = corporationId;
    this.policy = policy;
    this.otherTycoonId = otherTycoonId;
    this.otherTycoonName = otherTycoonName;
    this.otherCorporationId = otherCorporationId;
    this.otherCorporationName = otherCorporationName;
    this.otherPolicy = otherPolicy;
  }

  get isPrioritize (): boolean {
    return this.policy === 'PRIORITIZE';
  }
  get isEmbargo (): boolean {
    return this.policy === 'EMBARGO';
  }

  get isOtherPrioritize (): boolean {
    return this.otherPolicy === 'PRIORITIZE';
  }

  static fromJson (json: any): CorporationStrategy {
    return new CorporationStrategy(
      json.id,
      json.corporationId,
      json.policy,
      json.otherTycoonId,
      json.otherTycoonName,
      json.otherCorporationId,
      json.otherCorporationName,
      json.otherPolicy
    );
  }
}
