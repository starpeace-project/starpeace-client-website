
export default class CorporationLoanOffer {
  id: string;
  bankerType: string;
  maxAmount: number;
  maxTermYears: number;
  interestRate: number;

  constructor (id: string, bankerType: string, maxAmount: number, maxTermYears: number, interestRate: number) {
    this.id = id;
    this.bankerType = bankerType;
    this.maxAmount = maxAmount;
    this.maxTermYears = maxTermYears;
    this.interestRate = interestRate;
  }

  get interestRatePercent (): number {
    return this.interestRate * 100;
  }

  static fromJson (json: any): CorporationLoanOffer {
    return new CorporationLoanOffer(
      json.id,
      json.bankerType,
      json.maxAmount,
      json.maxTermYears,
      json.interestRate
    );
  }
}
