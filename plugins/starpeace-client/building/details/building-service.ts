
export default class BuildingService {
  resourceId: string;

  /**
   * Settable properties
   */
  requestedVelocity: number;

  /**
   * Informational properties
   */
  mostRecentVelocity: number;

  /**
   * Sim configuration
   */
  maxVelocity: number;

  constructor (resourceId: string, requestedVelocity: number, mostRecentVelocity: number, maxVelocity: number) {
    this.resourceId = resourceId;
    this.requestedVelocity = requestedVelocity;
    this.mostRecentVelocity = mostRecentVelocity;
    this.maxVelocity = maxVelocity;
  }

  toJson (): any {
    return {
      resourceId: this.resourceId,
      requestedVelocity: this.requestedVelocity,
      mostRecentVelocity: this.mostRecentVelocity,
      maxVelocity: this.maxVelocity
    };
  }

  static fromJson (json: any): BuildingService {
    return new BuildingService(
      json.resourceId,
      json.requestedVelocity ?? 0,
      json.mostRecentVelocity ?? 0,
      json.maxVelocity ?? 0
    );
  }
}
