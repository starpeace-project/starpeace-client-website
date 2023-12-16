import BuildingInput from './details/building-input';
import BuildingLabor from './details/building-labor';
import BuildingOutput from './details/building-output';
import BuildingRent from './details/building-rent';
import BuildingService from './details/building-service';
import BuildingStorage from './details/building-storage';

export interface BuildingDetailsParameters {
  id: string;

  inputs: Array<BuildingInput>;
  labors: Array<BuildingLabor>;
  outputs: Array<BuildingOutput>;
  rents: Array<BuildingRent>;
  services: Array<BuildingService>;
  storages: Array<BuildingStorage>;

  closed: boolean;
  connectionPosture: string;
  allowIncomingSettings: boolean;

  level: number;
  requestedLevel: number;
  maxLevel: number;
}

export default class BuildingDetails {
  id: string;

  inputs: Array<BuildingInput>;
  labors: Array<BuildingLabor>;
  outputs: Array<BuildingOutput>;
  rents: Array<BuildingRent>;
  services: Array<BuildingService>;
  storages: Array<BuildingStorage>;

  closed: boolean;
  connectionPosture: string;
  allowIncomingSettings: boolean;

  level: number;
  requestedLevel: number;
  maxLevel: number;

  constructor (parameters: BuildingDetailsParameters) {
    this.id = parameters.id;
    this.inputs = parameters.inputs;
    this.labors = parameters.labors;
    this.outputs = parameters.outputs;
    this.rents = parameters.rents;
    this.services = parameters.services;
    this.storages = parameters.storages;
    this.closed = parameters.closed;
    this.connectionPosture = parameters.connectionPosture;
    this.allowIncomingSettings = parameters.allowIncomingSettings;
    this.level = parameters.level;
    this.requestedLevel = parameters.requestedLevel;
    this.maxLevel = parameters.maxLevel;
  }

  static fromJson (json: any): BuildingDetails {
    return new BuildingDetails({
      id: json.id,
      inputs: (json.inputs ?? []).map(BuildingInput.fromJson),
      labors: (json.labors ?? []).map(BuildingLabor.fromJson),
      outputs: (json.outputs ?? []).map(BuildingOutput.fromJson),
      rents: (json.rents ?? []).map(BuildingRent.fromJson),
      services: (json.services ?? []).map(BuildingService.fromJson),
      storages: (json.storages ?? []).map(BuildingStorage.fromJson),
      closed: json.closed ?? false,
      connectionPosture: json.connectionPosture ?? 'ANYONE',
      allowIncomingSettings: json.allowIncomingSettings,
      level: json.level ?? 0,
      requestedLevel: json.requestedLevel ?? 0,
      maxLevel: json.maxLevel ?? 0
    });
  }
}
