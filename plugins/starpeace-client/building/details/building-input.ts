
export default class BuildingInput {
  resourceId: string;

  /**
   * Settable properties
   */
  maxPrice: number;
  minQuality: number;

  /**
   * Informational properties
   */
  mostRecentVelocity: number;
  mostRecentPrice: number;
  mostRecentTotalQuality: number;

  /**
   * Sim configuration
   */
  maxVelocity: number;

  constructor (resourceId: string, maxPrice: number, minQuality: number, mostRecentVelocity: number, mostRecentPrice: number, mostRecentTotalQuality: number, maxVelocity: number) {
    this.resourceId = resourceId;
    this.maxPrice = maxPrice;
    this.minQuality = minQuality;
    this.mostRecentVelocity = mostRecentVelocity;
    this.mostRecentPrice = mostRecentPrice;
    this.mostRecentTotalQuality = mostRecentTotalQuality;
    this.maxVelocity = maxVelocity;
  }

  toJson (): any {
    return {
      resourceId: this.resourceId,
      maxPrice: this.maxPrice,
      minQuality: this.minQuality,
      mostRecentVelocity: this.mostRecentVelocity,
      mostRecentPrice: this.mostRecentPrice,
      mostRecentTotalQuality: this.mostRecentTotalQuality,
      maxVelocity: this.maxVelocity,
    };
  }

  static fromJson (json: any): BuildingInput {
    return new BuildingInput(
      json.resourceId,
      json.maxPrice ?? 0,
      json.minQuality ?? 0,
      json.mostRecentVelocity ?? 0,
      json.mostRecentPrice ?? 0,
      json.mostRecentTotalQuality ?? 0,
      json.maxVelocity ?? 0
    );
  }
}
