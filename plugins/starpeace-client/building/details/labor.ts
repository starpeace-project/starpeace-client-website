
export default class Labor {
  resourceId: string;
  price: number;
  maxVelocity: number;
  mostRecentVelocity: number;
  quality: number;

  constructor (resourceId: string, price: number, maxVelocity: number, mostRecentVelocity: number, quality: number) {
    this.resourceId = resourceId;
    this.price = price;
    this.maxVelocity = maxVelocity;
    this.mostRecentVelocity = mostRecentVelocity;
    this.quality = quality;
  }

  static fromJson (json: any): Labor {
    return new Labor(
      json.resourceId,
      json.price,
      json.maxVelocity,
      json.mostRecentVelocity,
      json.quality
    );
  }
}
