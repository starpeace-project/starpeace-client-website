
export default class CommerceDetails {
  industry_type_id: string;
  demand: number;
  supply: number;
  capacity: number;
  ratio: number;
  ifel_price: number;
  average_price: number;
  quality: number;

  constructor (industry_type_id: string, demand: number, supply: number, capacity: number, ratio: number, ifel_price: number, average_price: number, quality: number) {
    this.industry_type_id = industry_type_id;
    this.demand = demand;
    this.supply = supply;
    this.capacity = capacity;
    this.ratio = ratio;
    this.ifel_price = ifel_price;
    this.average_price = average_price;
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
