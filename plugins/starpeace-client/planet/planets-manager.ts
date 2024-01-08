import _ from 'lodash';

import { BuildingDefinition, CityZone, CompanySeal, IndustryCategory, IndustryType, Level, ResourceType, ResourceUnit, SimulationDefinitionParser } from '@starpeace/starpeace-assets-types';

import Company from '~/plugins/starpeace-client/company/company';
import RankingType from '~/plugins/starpeace-client/corporation/ranking-type';
import TycoonInfo from '~/plugins/starpeace-client/tycoon/tycoon-info';

import InventionDefinition from '~/plugins/starpeace-client/invention/invention-definition';

import Town from '~/plugins/starpeace-client/planet/town';
import TownDetails from '~/plugins/starpeace-client/planet/town-details';
import ApiClient from '~/plugins/starpeace-client/api/api-client';
import AjaxState from '~/plugins/starpeace-client/state/ajax-state';
import ClientState from '~/plugins/starpeace-client/state/client-state';

export interface PlanetSearchResult {
  tycoonId: string;
  tycoonName: string;
  corporationId: string;
  corporationName: string;
}

export default class PlanetsManager {
  api: ApiClient;
  ajax_state: AjaxState;
  clientState: ClientState;

  constructor (api: ApiClient, ajax_state: AjaxState, clientState: ClientState) {
    this.api = api;
    this.ajax_state = ajax_state;
    this.clientState = clientState;
  }

  async load_online_tycoons (): Promise<Array<TycoonInfo>> {
    if (!this.clientState.has_session()) {
      throw Error();
    }
    return await this.ajax_state.locked('planet_online_tycoons', 'ALL', async () => {
      const online_tycoons = (await this.api.online_tycoons_for_planet() ?? []).map(TycoonInfo.fromJson);
      this.clientState.planet.load_tycoons_online(online_tycoons);
      return online_tycoons;
    });
  }


  async load_rankings (ranking_type_id: string): Promise<any> {
    if (!this.clientState.has_session() || !ranking_type_id) {
      throw Error();
    }
    const rankings = this.clientState.core.planet_cache.rankings(ranking_type_id);
    if (rankings) {
      return Promise.resolve(rankings);
    }
    return await this.ajax_state.locked('planet_rankings', ranking_type_id, async () => {
      const rankings = await this.api.rankings_for_planet(ranking_type_id);
      this.clientState.core.planet_cache.load_rankings(ranking_type_id, rankings);
      return rankings;
    });
  }

  async load_towns (): Promise<Array<Town>> {
    if (!this.clientState.has_session()) {
      throw Error();
    }
    return await this.ajax_state.locked('planet_towns', 'ALL', async () => {
      const towns = _.map(await this.api.towns_for_planet(), Town.fromJson);
      this.clientState.planet.load_towns(towns);
      return towns;
    });
  }

  async load_planet_details (): Promise<TownDetails> {
    if (!this.clientState.has_session()) {
      throw Error();
    }
    const details = this.clientState.core.planet_cache.planet_details();
    if (details) {
      return Promise.resolve(details);
    }
    return await this.ajax_state.locked('planet_details', 'ALL', async () => {
      const details = TownDetails.fromJson(await this.api.details_for_planet());
      this.clientState.core.planet_cache.load_planet_details(details);
      return details;
    });
  }
  async load_town_details (townId: string, skipCache: boolean = false): Promise<TownDetails> {
    if (!this.clientState.has_session() || !townId) {
      throw Error();
    }
    const details = this.clientState.core.planet_cache.town_details(townId);
    if (!skipCache && details) {
      return Promise.resolve(details);
    }
    return await this.ajax_state.locked('planet_town_details', townId, async () => {
      const details = TownDetails.fromJson(await this.api.details_for_town(townId));
      this.clientState.core.planet_cache.load_town_details(townId, details);
      return details;
    });
  }


  async buildings_by_town (town_id: string, industryCategoryId: string, industryTypeId: string): Promise<Array<any>> {
    if (!this.clientState.has_session() || !town_id || !industryCategoryId || !industryTypeId) {
      throw Error();
    }
    const buildings = this.clientState.core.planet_cache.town_buildings(town_id, industryCategoryId, industryTypeId);
    if (buildings) {
      return Promise.resolve(buildings);
    }
    return await this.ajax_state.locked('planet_town_buildings', `${town_id}-${industryCategoryId}-${industryTypeId}`, async () => {
      const buildings = await this.api.buildings_for_town(town_id, industryCategoryId, industryTypeId);
      this.clientState.core.planet_cache.load_town_buildings(town_id, industryCategoryId, industryTypeId, buildings);
      return buildings;
    });
  }
  async companies_by_town (town_id: string): Promise<Array<Company>> {
    if (!this.clientState.has_session() || !town_id) {
      throw Error();
    }
    const companies = this.clientState.core.planet_cache.town_companies(town_id);
    if (companies) {
      return Promise.resolve(companies);
    }
    return await this.ajax_state.locked('planet_town_companies', town_id, async () => {
      const companies = (await this.api.companies_for_town(town_id) ?? []).map(Company.from_json);
      this.clientState.core.planet_cache.load_town_companies(town_id, companies);
      return companies;
    });
  }

  async load_metadata_building (): Promise<void> {
    if (!this.clientState.has_session()) {
      throw Error();
    }
    return await this.ajax_state.locked('planet_metadata_building', 'ALL', async () => {
      const definitions_json = await this.api.building_metadata_for_planet();
      this.clientState.core.building_library.load_definitions((definitions_json?.definitions ?? []).map(BuildingDefinition.fromJson));
      this.clientState.core.building_library.load_simulation_definitions((definitions_json?.simulationDefinitions ?? []).map(SimulationDefinitionParser.fromJson));
    });
  }
  async load_metadata_core (): Promise<void> {
    if (!this.clientState.has_session()) {
      throw Error();
    }
    return await this.ajax_state.locked('planet_metadata_core', 'ALL', async () => {
      const json = await this.api.core_metadata_for_planet()
      this.clientState.core.planet_library.load_city_zones(_.map(json.cityZones, CityZone.fromJson));
      this.clientState.core.planet_library.load_industry_categories(_.map(json.industryCategories, IndustryCategory.fromJson));
      this.clientState.core.planet_library.load_industry_types(_.map(json.industryTypes, IndustryType.fromJson));
      this.clientState.core.planet_library.load_levels(_.map(json.levels, Level.fromJson));
      this.clientState.core.planet_library.load_ranking_types(_.map(json.rankingTypes, RankingType.fromJson));
      this.clientState.core.planet_library.load_resource_types(_.map(json.resourceTypes, ResourceType.fromJson));
      this.clientState.core.planet_library.load_resource_units(_.map(json.resourceUnits, ResourceUnit.fromJson));
      this.clientState.core.planet_library.load_company_seals(_.map(json.seals, CompanySeal.fromJson));
    });
  }
  async load_metadata_invention (): Promise<void> {
    if (!this.clientState.has_session()) {
      throw Error();
    }
    return await this.ajax_state.locked('planet_metadata_invention', 'ALL', async () => {
      const json = await this.api.invention_metadata_for_planet();
      this.clientState.core.invention_library.load_inventions((json?.inventions ?? []).map(InventionDefinition.fromJson));
    });
  }

  async search_corporations (query: string, starts_with_query: boolean): Promise<Array<PlanetSearchResult>> {
    if (!this.clientState.has_session()|| !query?.length) {
      throw Error();
    }
    return await this.ajax_state.locked('planet_search_corporations', 'ALL', async () => {
      return await this.api.search_corporations_for_planet(query, starts_with_query);
    });
  }
  async search_tycoons (query: string, starts_with_query: boolean): Promise<Array<PlanetSearchResult>> {
    if (!this.clientState.has_session()|| !query?.length) {
      throw Error();
    }
    return await this.ajax_state.locked('planet_search_tycoons', 'ALL', async () => {
      return await this.api.search_tycoons_for_planet(query, starts_with_query);
    });
  }
}
