
export interface BuildingStorageParameters {
  resourceId: string;

  /**
   * Settable properties
   */
  enabled: boolean;

  /**
   * Informational properties
   */
  mostRecentCapacity: number;
  mostRecentTotalQuality: number;

  /**
   * Sim configuration
   */
  maxCapacity: number;
}

export default class BuildingStorage {
  resourceId: string;

  /**
   * Settable properties
   */
  enabled: boolean;

  /**
   * Informational properties
   */
  mostRecentCapacity: number;
  mostRecentTotalQuality: number;

  /**
   * Sim configuration
   */
  maxCapacity: number;

  constructor (parameters: BuildingStorageParameters) {
    this.resourceId = parameters.resourceId;
    this.enabled = parameters.enabled;
    this.mostRecentCapacity = parameters.mostRecentCapacity;
    this.mostRecentTotalQuality = parameters.mostRecentTotalQuality;
    this.maxCapacity = parameters.maxCapacity;
  }

  toJson (): any {
    return {
      resourceId: this.resourceId,
      enabled: this.enabled,
      mostRecentCapacity: this.mostRecentCapacity,
      mostRecentTotalQuality: this.mostRecentTotalQuality,
      maxCapacity: this.maxCapacity,
    };
  }

  static fromJson (json: any): BuildingStorage {
    return new BuildingStorage({
      resourceId: json.resourceId,
      enabled: json.enabled ?? false,
      mostRecentCapacity: json.mostRecentCapacity ?? 0,
      mostRecentTotalQuality: json.mostRecentTotalQuality ?? 0,
      maxCapacity: json.maxCapacity ?? 0
    });
  }
}
