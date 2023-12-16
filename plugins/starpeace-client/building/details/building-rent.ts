
export interface BuildingRentParameters {
  resourceId: string;

  /**
   * Settable properties
   */
  rentFactor: number;
  maintenanceFactor: number;

  /**
   * Informational properties
   */
  mostRecentVelocity: number;

  mostRecentExtraBeauty: number;
  mostRecentCrimeResistance: number;
  mostRecentPollutionResistance: number;
  mostRecentExtraPrivacy: number;

  /**
   * Sim configuration
   */
  maxVelocity: number;
}

export default class BuildingRent {
  resourceId: string;

  /**
   * Settable properties
   */
  rentFactor: number;
  maintenanceFactor: number;

  /**
   * Informational properties
   */
  mostRecentVelocity: number;

  mostRecentExtraBeauty: number;
  mostRecentCrimeResistance: number;
  mostRecentPollutionResistance: number;
  mostRecentExtraPrivacy: number;

  /**
   * Sim configuration
   */
  maxVelocity: number;

  constructor (parameters: BuildingRentParameters) {
    this.resourceId = parameters.resourceId;
    this.rentFactor = parameters.rentFactor;
    this.maintenanceFactor = parameters.maintenanceFactor;
    this.mostRecentVelocity = parameters.mostRecentVelocity;
    this.mostRecentExtraBeauty = parameters.mostRecentExtraBeauty;
    this.mostRecentCrimeResistance = parameters.mostRecentCrimeResistance;
    this.mostRecentPollutionResistance = parameters.mostRecentPollutionResistance;
    this.mostRecentExtraPrivacy = parameters.mostRecentExtraPrivacy;
    this.maxVelocity = parameters.maxVelocity;
  }

  toJson (): any {
    return {
      resourceId: this.resourceId,
      rentFactor: this.rentFactor,
      maintenanceFactor: this.maintenanceFactor,
      mostRecentVelocity: this.mostRecentVelocity,
      mostRecentExtraBeauty: this.mostRecentExtraBeauty,
      mostRecentCrimeResistance: this.mostRecentCrimeResistance,
      mostRecentPollutionResistance: this.mostRecentPollutionResistance,
      mostRecentExtraPrivacy: this.mostRecentExtraPrivacy,
      maxVelocity: this.maxVelocity,
    };
  }

  static fromJson (json: any): BuildingRent {
    return new BuildingRent({
      resourceId: json.resourceId,
      rentFactor: json.rentFactor ?? 0,
      maintenanceFactor: json.maintenanceFactor ?? 0,
      mostRecentVelocity: json.mostRecentVelocity ?? 0,
      mostRecentExtraBeauty: json.mostRecentExtraBeauty ?? 0,
      mostRecentCrimeResistance: json.mostRecentCrimeResistance ?? 0,
      mostRecentPollutionResistance: json.mostRecentPollutionResistance ?? 0,
      mostRecentExtraPrivacy: json.mostRecentExtraPrivacy ?? 0,
      maxVelocity: json.maxVelocity ?? 0
    });
  }
}
