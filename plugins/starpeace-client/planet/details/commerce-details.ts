
export default class CommerceDetails {
  industryTypeId: string;
  demand: number;
  supply: number;
  capacity: number;
  ratio: number;
  ifelPrice: number;
  averagePrice: number;
  quality: number;

  constructor (industryTypeId: string, demand: number, supply: number, capacity: number, ratio: number, ifelPrice: number, averagePrice: number, quality: number) {
    this.industryTypeId = industryTypeId;
    this.demand = demand;
    this.supply = supply;
    this.capacity = capacity;
    this.ratio = ratio;
    this.ifelPrice = ifelPrice;
    this.averagePrice = averagePrice;
    this.quality = quality;
  }

  static fromJson (json: any): CommerceDetails {
    return new CommerceDetails(
      json.industryTypeId,
      json.demand,
      json.supply,
      json.capacity,
      json.ratio,
      json.ifelPrice,
      json.averagePrice,
      json.quality
    );
  }
}
