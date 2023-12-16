import _ from 'lodash';
import { DateTime } from 'luxon';

import SandboxBuilding from '~/plugins/starpeace-client/api/sandbox/managers/sandbox-building.js';
import SandboxMetadata from '~/plugins/starpeace-client/api/sandbox/managers/sandbox-metadata.js';
import SandboxCorporation from '~/plugins/starpeace-client/api/sandbox/managers/sandbox-corporation.js';
import SandboxRankings from '~/plugins/starpeace-client/api/sandbox/managers/sandbox-rankings.js';
import SandboxGovernment from '~/plugins/starpeace-client/api/sandbox/managers/sandbox-government.js';
import SandboxOverlay from '~/plugins/starpeace-client/api/sandbox/managers/sandbox-overlay.js'
import SandboxRoads from '~/plugins/starpeace-client/api/sandbox/managers/sandbox-roads.js'

import GALAXY_METADATA from '~/plugins/starpeace-client/api/sandbox/data/mock-galaxy-metadata.json'
import PLANET_TOWNS from '~/plugins/starpeace-client/api/sandbox/data/mock-planet-towns.json'

const MONTH_SEASONS = [
  'winter',
  'spring',
  'spring',
  'spring',
  'summer',
  'summer',
  'summer',
  'fall',
  'fall',
  'fall',
  'winter',
  'winter'
];


export default class SandboxData {
  access_tokens: Record<string, string>;

  galaxy_metadata: any;
  planet_towns: any;

  metadata: SandboxMetadata;
  corporation: SandboxCorporation;
  rankings: SandboxRankings;
  building: SandboxBuilding;
  overlay: SandboxOverlay;
  roads: SandboxRoads;
  government: SandboxGovernment;

  planet_id_dates: Record<string, DateTime>;

  constructor () {
    this.access_tokens = {};

    this.galaxy_metadata = GALAXY_METADATA;
    this.planet_towns = PLANET_TOWNS;

    this.metadata = SandboxMetadata.create();
    this.corporation = SandboxCorporation.create();

    this.rankings = SandboxRankings.create(this.metadata, this.corporation);
    this.building = SandboxBuilding.create(this.metadata, this.corporation);

    this.overlay = SandboxOverlay.create();
    this.roads = SandboxRoads.create();
    this.government = SandboxGovernment.create(this.metadata, Object.values(this.planet_towns).flat().map(t => t.id));

    this.planet_id_dates = {
      'planet-1': DateTime.fromISO('2235-01-01'),
      'planet-2': DateTime.fromISO('2235-01-01'),
      'planet-3': DateTime.fromISO('2235-01-01')
    }
  }

  season_for_planet (planetId: string): string {
    return MONTH_SEASONS[this.planet_id_dates[planetId]?.month - 1] ?? 'winter';
  }

  add_building (planetId: string, companyId: string, chunkKey: string, building: any): void {
    if (!this.building.buildingsByPlanetIdChunkId[planetId]) {
      this.building.buildingsByPlanetIdChunkId[planetId] = {};
    }
    if (!this.building.buildingsByPlanetIdChunkId[planetId][chunkKey]) {
      this.building.buildingsByPlanetIdChunkId[planetId][chunkKey] = [];
    }
    this.building.buildingsByPlanetIdChunkId[planetId][chunkKey].push(building);

    if (!this.building.buildingsByCompanyId[companyId]) {
      this.building.buildingsByCompanyId[companyId] = [];
    }
    this.building.buildingsByCompanyId[companyId].push(building);

    this.building.buildingById[building.id] = building;
  }
}
