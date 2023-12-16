
export default class BuildingLabor {
  resourceId: string;

  /**
   * Settable properties
   */
  price: number;

  /**
   * Informational properties
   */
  mostRecentVelocity: number;
  mostRecentTotalQuality: number;

  /**
   * Sim configuration
   */
  maxVelocity: number;

  constructor (resourceId: string, price: number, mostRecentVelocity: number, mostRecentTotalQuality: number, maxVelocity: number) {
    this.resourceId = resourceId;
    this.price = price;
    this.mostRecentVelocity = mostRecentVelocity;
    this.mostRecentTotalQuality = mostRecentTotalQuality;
    this.maxVelocity = maxVelocity;
  }

  toJson (): any {
    return {
      resourceId: this.resourceId,
      price: this.price,
      mostRecentVelocity: this.mostRecentVelocity,
      mostRecentTotalQuality: this.mostRecentTotalQuality,
      maxVelocity: this.maxVelocity,
    };
  }

  static fromJson (json: any): BuildingLabor {
    return new BuildingLabor(
      json.resourceId,
      json.price ?? 0,
      json.mostRecentVelocity ?? 0,
      json.mostRecentTotalQuality ?? 0,
      json.maxVelocity ?? 0
    );
  }
}
