import { DateTime } from 'luxon';

export interface BuildingConnectionParameters {
  id: string;

  sourceBuildingId: string;
  sourceBuildingDefinitionId?: string | undefined;
  sourceBuildingName?: string | undefined;
  sourceBuildingMapX?: number | undefined;
  sourceBuildingMapY?: number | undefined;
  sourceCompanyName?: string | undefined;

  sinkBuildingId: string;
  sinkBuildingDefinitionId?: string | undefined;
  sinkBuildingName?: string | undefined;
  sinkBuildingMapX?: number | undefined;
  sinkBuildingMapY?: number | undefined;
  sinkCompanyName?: string | undefined;

  resourceId: string;
  connectedAt: DateTime;
  valid: boolean;

  mostRecentPrice?: number | undefined;
  mostRecentVelocity?: number | undefined;
  mostRecentQuality?: number | undefined;
  mostRecentTransportCost?: number | undefined;
}

export default class BuildingConnection {
  id: string;

  sourceBuildingId: string;
  sourceBuildingDefinitionId: string | undefined;
  sourceBuildingName: string | undefined;
  sourceBuildingMapX: number | undefined;
  sourceBuildingMapY: number | undefined;
  sourceCompanyName: string | undefined;

  sinkBuildingId: string;
  sinkBuildingDefinitionId: string | undefined;
  sinkBuildingName: string | undefined;
  sinkBuildingMapX: number | undefined;
  sinkBuildingMapY: number | undefined;
  sinkCompanyName: string | undefined;

  resourceId: string;
  connectedAt: DateTime;

  valid: boolean;

  mostRecentPrice: number;
  mostRecentVelocity: number;
  mostRecentQuality: number;
  mostRecentTransportCost: number;

  constructor (parameters: BuildingConnectionParameters) {
    this.id = parameters.id;
    this.sourceBuildingId = parameters.sourceBuildingId;
    this.sourceBuildingDefinitionId = parameters.sourceBuildingDefinitionId;
    this.sourceBuildingName = parameters.sourceBuildingName;
    this.sourceBuildingMapX = parameters.sourceBuildingMapX;
    this.sourceBuildingMapY = parameters.sourceBuildingMapY;
    this.sourceCompanyName = parameters.sourceCompanyName;
    this.sinkBuildingId = parameters.sinkBuildingId;
    this.sinkBuildingDefinitionId = parameters.sinkBuildingDefinitionId;
    this.sinkBuildingName = parameters.sinkBuildingName;
    this.sinkBuildingMapX = parameters.sinkBuildingMapX;
    this.sinkBuildingMapY = parameters.sinkBuildingMapY;
    this.sinkCompanyName = parameters.sinkCompanyName;
    this.resourceId = parameters.resourceId;
    this.connectedAt = parameters.connectedAt;
    this.valid = parameters.valid;
    this.mostRecentPrice = parameters.mostRecentPrice ?? 0;
    this.mostRecentVelocity = parameters.mostRecentVelocity ?? 0;
    this.mostRecentQuality = parameters.mostRecentQuality ?? 0;
    this.mostRecentTransportCost = parameters.mostRecentTransportCost ?? 0;
  }

  toJson (): any {
    return {
      id: this.id,
      sourceBuildingId: this.sourceBuildingId,
      sourceBuildingDefinitionId: this.sourceBuildingDefinitionId,
      sourceBuildingName: this.sourceBuildingName,
      sourceBuildingMapX: this.sourceBuildingMapX,
      sourceBuildingMapY: this.sourceBuildingMapY,
      sourceCompanyName: this.sourceCompanyName,
      sinkBuildingId: this.sinkBuildingId,
      sinkBuildingDefinitionId: this.sinkBuildingDefinitionId,
      sinkBuildingName: this.sinkBuildingName,
      sinkBuildingMapX: this.sinkBuildingMapX,
      sinkBuildingMapY: this.sinkBuildingMapY,
      sinkCompanyName: this.sinkCompanyName,
      resourceId: this.resourceId,
      connectedAt: this.connectedAt.toISO(),
      valid: this.valid,
      mostRecentPrice: this.mostRecentPrice,
      mostRecentVelocity: this.mostRecentVelocity,
      mostRecentQuality: this.mostRecentQuality,
      mostRecentTransportCost: this.mostRecentTransportCost
    };
  }

  static fromJson (json: any): BuildingConnection {
    return new BuildingConnection({
      id: json.id,
      sourceBuildingId: json.sourceBuildingId,
      sourceBuildingDefinitionId: json.sourceBuildingDefinitionId,
      sourceBuildingName: json.sourceBuildingName,
      sourceBuildingMapX: json.sourceBuildingMapX,
      sourceBuildingMapY: json.sourceBuildingMapY,
      sourceCompanyName: json.sourceCompanyName,
      sinkBuildingId: json.sinkBuildingId,
      sinkBuildingDefinitionId: json.sinkBuildingDefinitionId,
      sinkBuildingName: json.sinkBuildingName,
      sinkBuildingMapX: json.sinkBuildingMapX,
      sinkBuildingMapY: json.sinkBuildingMapY,
      sinkCompanyName: json.sinkCompanyName,
      resourceId: json.resourceId,
      connectedAt: DateTime.fromISO(json.connectedAt),
      valid: json.valid,
      mostRecentPrice: json.mostRecentPrice,
      mostRecentVelocity: json.mostRecentVelocity,
      mostRecentQuality: json.mostRecentQuality,
      mostRecentTransportCost: json.mostRecentTransportCost
    });
  }
}
