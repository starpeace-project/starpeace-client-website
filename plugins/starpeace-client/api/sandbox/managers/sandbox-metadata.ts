import {
  BuildingDefinition,
  CityZone,
  CompanySeal,
  IndustryCategory,
  IndustryType,
  InventionDefinition,
  Level,
  ResourceType,
  ResourceUnit,
  SimulationDefinition,
  SimulationDefinitionParser
} from '@starpeace/starpeace-assets-types';

import OverlayType from '~/plugins/starpeace-client/overlay/overlay-type';

import METADATA_BUILDING from '~/plugins/starpeace-client/api/sandbox/data/metadata-building.json'
import METADATA_CORE from '~/plugins/starpeace-client/api/sandbox/data/metadata-core.json'
import METADATA_INVENTION from '~/plugins/starpeace-client/api/sandbox/data/metadata-invention.json'


export interface BuildingMetadata {
  definitions: Array<BuildingDefinition>;
  simulations: Array<SimulationDefinition>;
}

export interface CoreMetadata {
  cityZones: Array<CityZone>;
  industryCategories: Array<IndustryCategory>;
  industryTypes: Array<IndustryType>;
  levels: Array<Level>;
  overlayTypes: Array<OverlayType>;
  rankingTypes: Array<any>;
  resourceTypes: Array<ResourceType>;
  resourceUnits: Array<ResourceUnit>;
  seals: Array<CompanySeal>;
}

export interface InventionMetadata {
  inventions: Array<InventionDefinition>;
}

export default class SandboxMetadata {
  building: BuildingMetadata;
  core: CoreMetadata;
  invention: InventionMetadata;

  constructor (building: BuildingMetadata, core: CoreMetadata, invention: InventionMetadata) {
    this.building = building;
    this.core = core;
    this.invention = invention;
  }

  static create (): SandboxMetadata {
    return new SandboxMetadata(
      {
        definitions: (METADATA_BUILDING?.definitions ?? []).map(BuildingDefinition.fromJson),
        simulations: (METADATA_BUILDING?.simulationDefinitions ?? []).map(SimulationDefinitionParser.fromJson)
      },
      {
        cityZones: (METADATA_CORE?.cityZones ?? []).map(CityZone.fromJson),
        industryCategories: (METADATA_CORE?.industryCategories ?? []).map(IndustryCategory.fromJson),
        industryTypes: (METADATA_CORE?.industryTypes ?? []).map(IndustryType.fromJson),
        levels: (METADATA_CORE?.levels ?? []).map(Level.fromJson),
        overlayTypes: (METADATA_CORE?.overlayTypes ?? []).map(OverlayType.fromJson),
        rankingTypes: (METADATA_CORE?.rankingTypes ?? []),
        resourceTypes: (METADATA_CORE?.resourceTypes ?? []).map(ResourceType.fromJson),
        resourceUnits: (METADATA_CORE?.resourceUnits ?? []).map(ResourceUnit.fromJson),
        seals: (METADATA_CORE?.seals ?? []).map(CompanySeal.fromJson)
      },
      {
        inventions: (METADATA_INVENTION?.inventions ?? []).map(InventionDefinition.fromJson)
      }
    );
  }
}
