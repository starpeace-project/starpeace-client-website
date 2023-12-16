import _ from 'lodash';
import TinyCache from 'tinycache';
import { markRaw } from 'vue';

import Cache from '~/plugins/starpeace-client/state/core/cache/cache'
import Building from '~/plugins/starpeace-client/building/building';
import BuildingDetails from '~/plugins/starpeace-client/building/building-details';
import BuildingConnection from '~/plugins/starpeace-client/building/details/building-connection';

export default class BuildingCache extends Cache {
  metadataById: Record<string, Building> = {};

  constructionProgressByBuildingId: TinyCache;
  cashflowByBuildingId: TinyCache;
  detailsByBuildingId: TinyCache;
  connectionsByTypeResourceIdByBuildingId: TinyCache;

  constructor () {
    super();
    this.constructionProgressByBuildingId = markRaw(new TinyCache());
    this.cashflowByBuildingId = markRaw(new TinyCache());
    this.detailsByBuildingId = markRaw(new TinyCache());
    this.connectionsByTypeResourceIdByBuildingId = markRaw(new TinyCache());
  }

  reset_planet () {
    this.metadataById = {};
    this.constructionProgressByBuildingId.clear();
    this.cashflowByBuildingId.clear();
    this.detailsByBuildingId.clear();
    this.connectionsByTypeResourceIdByBuildingId.clear();
  }

  remove_building (buildingId: string): void {
    delete this.metadataById[buildingId];
    this.constructionProgressByBuildingId.del(buildingId);
    this.cashflowByBuildingId.del(buildingId);
    this.detailsByBuildingId.del(buildingId);
    this.connectionsByTypeResourceIdByBuildingId.del(buildingId);
  }

  building_for_id (buildingId: string): Building | undefined {
    return this.metadataById[buildingId];
  }
  load_building (building: Building): void {
    this.metadataById[building.id] = building;
  }
  load_buildings (buildings: Array<Building>): void {
    for (const building of buildings) {
      this.load_building(building);
    }
  }

  constructionProgressForBuildingId (buildingId: string): number | undefined {
    return this.constructionProgressByBuildingId.get(buildingId) ?? undefined;
  }
  loadConstructionProgress (buildingId: string, progress: number): void {
    this.constructionProgressByBuildingId.put(buildingId, progress, Cache.ONE_MINUTE);
  }
  clearConstructionProgress (buildingId: string): void {
    this.constructionProgressByBuildingId.del(buildingId);
  }

  cashflowForBuildingId (buildingId: string): number | undefined {
    return this.cashflowByBuildingId.get(buildingId) ?? undefined;
  }
  loadCashflow (buildingId: string, cashflow: number): void {
    this.cashflowByBuildingId.put(buildingId, cashflow, Cache.ONE_MINUTE);
  }

  detailsForBuildingId (buildingId: string): BuildingDetails | undefined {
    return this.detailsByBuildingId.get(buildingId) ?? undefined;
  }
  loadDetails (buildingId: string, details: BuildingDetails): void {
    this.detailsByBuildingId.put(buildingId, details, Cache.ONE_MINUTE);
  }

  connectionsForBuildingIdResourceId (buildingId: string, type: string, resourceId: string): BuildingConnection[] {
    return (this.connectionsByTypeResourceIdByBuildingId.get(buildingId) ?? {})[type]?.[resourceId] ?? [];
  }
  loadConnections (buildingId: string, type: string, resourceId: string, connections: BuildingConnection[]): void {
    this.connectionsByTypeResourceIdByBuildingId.put(buildingId, _.merge(this.connectionsByTypeResourceIdByBuildingId.get(buildingId) ?? {}, {
      [type]: {
        [resourceId]: connections
      }
    }), Cache.ONE_MINUTE);
  }
}
