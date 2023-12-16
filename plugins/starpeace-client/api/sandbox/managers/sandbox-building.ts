import { TradeCenterDefinition } from '@starpeace/starpeace-assets-types';

import SandboxMetadata from '~/plugins/starpeace-client/api/sandbox/managers/sandbox-metadata.js';
import SandboxCorporation from '~/plugins/starpeace-client/api/sandbox/managers/sandbox-corporation.js';

import Utils from '~/plugins/starpeace-client/utils/utils.js';

import PLANET_1_TYCOON_1_BUILDINGS from '~/plugins/starpeace-client/api/sandbox/data/mock-planet-1-tycoon-1-buildings.json'
import PLANET_1_MAP_BUILDINGS from '~/plugins/starpeace-client/api/sandbox/data/mock-planet-1-map-buildings.json'
import PLANET_2_MAP_BUILDINGS from '~/plugins/starpeace-client/api/sandbox/data/mock-planet-2-map-buildings.json'
import { DateTime } from 'luxon';

const PLANET_MAP_BUILDINGS = {
  'planet-1': PLANET_1_MAP_BUILDINGS,
  'planet-2': PLANET_2_MAP_BUILDINGS
};

export interface BuildingDetails {
  id: string;
  products?: Array<any> | undefined;
  labors?: Array<any> | undefined;
}

export default class SandboxBuilding {
  buildingsByCompanyId: Record<string, Array<any>>;
  buildingsByPlanetIdChunkId: Record<string, Record<string, Array<any>>>;
  sinksByPlanetIdResourceId: Record<string, Record<string, Set<any>>>;

  buildingById: Record<string, any>;
  detailsById: Record<string, BuildingDetails>;

  constructor (buildingsByCompanyId: Record<string, Array<any>>, buildingsByPlanetIdChunkId: Record<string, Record<string, Array<any>>>, sinksByPlanetIdResourceId: Record<string, Record<string, Set<any>>>, buildingById: Record<string, any>, detailsById: Record<string, BuildingDetails>) {
    this.buildingsByCompanyId = buildingsByCompanyId;
    this.buildingsByPlanetIdChunkId = buildingsByPlanetIdChunkId;
    this.sinksByPlanetIdResourceId = sinksByPlanetIdResourceId;
    this.buildingById = buildingById;
    this.detailsById = detailsById;
  }

  static createDetails (metadata: SandboxMetadata, corporation: SandboxCorporation, buildingsByPlanetIdChunkId: Record<string, Record<string, any>>, buildingById: Record<string, any>, sinksByPlanetIdResourceId: Record<string, Record<string, Set<any>>>): any {
    const detailsById: Record<string, BuildingDetails> = {};

    for (const [planetId, buildingsByChunk] of Object.entries(buildingsByPlanetIdChunkId)) {
      for (const [chunkId, chunkBuildings] of Object.entries(buildingsByChunk)) {
        for (const building of chunkBuildings) {
          const simulation = metadata.building.simulations.find(d => d.id == building.definitionId);
          if (simulation?.type == 'TRADECENTER') {
            detailsById[building.id] = {
              id: building.id,
              products: ((simulation as TradeCenterDefinition).outputs ?? []).map((p) => {
                const connections = Array.from(sinksByPlanetIdResourceId[planetId][p.resourceId] ?? new Set()).map((bid) => {
                  const velocity = Math.floor(Math.random() * 10000);
                  return {
                    id: Utils.uuid(),
                    valid: Math.floor(Math.random() * 3) > 0,
                    sinkCompanyId: buildingById[bid].companyId,
                    sinkCompanyName: corporation.infoByCompanyId[buildingById[bid].companyId]?.name ?? buildingById[bid].companyId,
                    sinkBuildingId: bid,
                    sinkBuildingName: buildingById[bid].name,
                    sinkBuildingMapX: buildingById[bid].mapX,
                    sinkBuildingMapY: buildingById[bid].mapY,
                    velocity: velocity,
                    transportCost: velocity * 0.01
                  };
                });
                return {
                  resourceId: p.resourceId,
                  price: metadata.core.resourceTypes.find(t => t.id == p.resourceId)?.price ?? 0,
                  totalVelocity: connections.reduce((sum, c) => c.velocity + sum, 0),
                  quality: .4,
                  connections: connections
                };
              })
            };
          }
        }
      }
    }

    return detailsById;
  }

  static create (metadata: SandboxMetadata, corporation: SandboxCorporation): SandboxBuilding {
    const buildingsByCompanyId: Record<string, Array<any>> = PLANET_1_TYCOON_1_BUILDINGS;

    const sinksByPlanetIdResourceId: Record<string, Record<string, Set<any>>> = {};
    const buildingsByPlanetIdChunkId: Record<string, Record<string, Array<any>>> = {};
    const buildingById: Record<string, any> = {};

    for (const [planetId, planetBuildings] of Object.entries(PLANET_MAP_BUILDINGS)) {
      if (!sinksByPlanetIdResourceId[planetId]) {
        sinksByPlanetIdResourceId[planetId] = {};
      }

      if (!buildingsByPlanetIdChunkId[planetId]) {
        buildingsByPlanetIdChunkId[planetId] = {};
      }

      for (const [chunkId, chunkBuildings] of Object.entries(planetBuildings)) {
        buildingsByPlanetIdChunkId[planetId][chunkId] = chunkBuildings;

        for (const building of chunkBuildings) {
          (building as any).level = 1;
          (building as any).constructionFinishedAt = Math.random() < 0.95 ? DateTime.fromISO('2235-01-01') : undefined;

          buildingById[building.id] = building;

          const companyId = (building as any).companyId;
          if (companyId) {
            if (!buildingsByCompanyId[companyId]) {
              buildingsByCompanyId[companyId] = [];
            }
            buildingsByCompanyId[companyId].push(building);

            corporation.addCompany(planetId, building);
          }

          const simulation = metadata.building.simulations.find((d) => d.id === building.definitionId);
          if (!simulation) {
            continue;
          }

          for (const stage of ((simulation as any).stages ?? [])) {
            for (const input of (stage.inputs ?? [])) {
              if (!sinksByPlanetIdResourceId[planetId][input.resourceId]) {
                sinksByPlanetIdResourceId[planetId][input.resourceId] = new Set();
              }
              sinksByPlanetIdResourceId[planetId][input.resourceId].add(building.id);
            }
          }

          for (const product of ((simulation as any).products ?? [])) {
            for (const input of (product.inputs ?? [])) {
              if (!sinksByPlanetIdResourceId[planetId][input.resourceId]) {
                sinksByPlanetIdResourceId[planetId][input.resourceId] = new Set();
              }
              sinksByPlanetIdResourceId[planetId][input.resourceId].add(building.id);
            }
          }
        }
      }
    }

    return new SandboxBuilding(
      buildingsByCompanyId,
      buildingsByPlanetIdChunkId,
      sinksByPlanetIdResourceId,
      buildingById,
      SandboxBuilding.createDetails(metadata, corporation, buildingsByPlanetIdChunkId, buildingById, sinksByPlanetIdResourceId)
    );
  }
}
