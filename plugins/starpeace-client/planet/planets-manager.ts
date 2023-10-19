import _ from 'lodash';

import BuildingDefinition from '~/plugins/starpeace-client/building/building-definition.coffee';
import SimulationDefinitionParser from '~/plugins/starpeace-client/building/simulation/simulation-definition-parser.coffee';

import Company from '~/plugins/starpeace-client/company/company';
import CompanySeal from '~/plugins/starpeace-client/company/company-seal';
import RankingType from '~/plugins/starpeace-client/corporation/ranking-type';
import TycoonInfo from '~/plugins/starpeace-client/tycoon/tycoon-info';

import CityZone from '~/plugins/starpeace-client/industry/city-zone';
import IndustryCategory from '~/plugins/starpeace-client/industry/industry-category';
import IndustryType from '~/plugins/starpeace-client/industry/industry-type';
import Level from '~/plugins/starpeace-client/industry/level';
import ResourceType from '~/plugins/starpeace-client/industry/resource-type';
import ResourceUnit from '~/plugins/starpeace-client/industry/resource-unit';

import InventionDefinition from '~/plugins/starpeace-client/invention/invention-definition';

import Town from '~/plugins/starpeace-client/planet/town';
import TownDetails from '~/plugins/starpeace-client/planet/town-details';

export default class PlanetsManager {
  api: any;
  ajax_state: any;
  client_state: any;

  constructor (api: any, ajax_state: any, client_state: any) {
    this.api = api;
    this.ajax_state = ajax_state;
    this.client_state = client_state;
  }

  async load_online_tycoons (): Promise<Array<TycoonInfo>> {
    if (!this.client_state.has_session()) {
      throw Error();
    }
    return await this.ajax_state.locked('planet_online_tycoons', 'ALL', async () => {
      const online_tycoons = (await this.api.online_tycoons_for_planet() ?? []).map(TycoonInfo.fromJson);
      this.client_state.planet.load_tycoons_online(online_tycoons);
      return online_tycoons;
    });
  }


  async load_rankings (ranking_type_id: string): Promise<any> {
    if (!this.client_state.has_session() || !ranking_type_id) {
      throw Error();
    }
    return await this.ajax_state.locked('planet_rankings', ranking_type_id, async () => {
      const rankings = await this.api.rankings_for_planet(ranking_type_id);
      this.client_state.core.planet_cache.load_rankings(ranking_type_id, rankings);
      return rankings;
    });
  }

  async load_towns (): Promise<Array<Town>> {
    if (!this.client_state.has_session()) {
      throw Error();
    }
    return await this.ajax_state.locked('planet_towns', 'ALL', async () => {
      const towns = _.map(await this.api.towns_for_planet(), Town.fromJson);
      this.client_state.planet.load_towns(towns);
      return towns;
    });
  }

  async load_planet_details (): Promise<TownDetails> {
    if (!this.client_state.has_session()) {
      throw Error();
    }
    const details = this.client_state.core.planet_cache.planet_details();
    if (details) {
      return Promise.resolve(details);
    }
    return await this.ajax_state.locked('planet_details', 'ALL', async () => {
      const details = TownDetails.fromJson(await this.api.details_for_planet());
      this.client_state.core.planet_cache.load_planet_details(details);
      return details;
    });
  }
  async load_town_details (town_id: string): Promise<TownDetails> {
    if (!this.client_state.has_session() || !town_id) {
      throw Error();
    }
    const details = this.client_state.core.planet_cache.town_details(town_id);
    if (details) {
      return Promise.resolve(details);
    }
    return await this.ajax_state.locked('planet_town_details', town_id, async () => {
      const details = TownDetails.fromJson(await this.api.details_for_town(town_id));
      this.client_state.core.planet_cache.load_town_details(town_id, details);
      return details;
    });
  }


  async buildings_by_town (town_id: string, industry_category_id: string, industry_type_id: string): Promise<Array<any>> {
    if (!this.client_state.has_session() || !town_id || !industry_category_id || !industry_type_id) {
      throw Error();
    }
    const buildings = this.client_state.core.planet_cache.town_buildings(town_id, industry_category_id, industry_type_id);
    if (buildings) {
      return Promise.resolve(buildings);
    }
    return await this.ajax_state.locked('planet_town_buildings', `${town_id}-${industry_category_id}-${industry_type_id}`, async () => {
      const buildings = await this.api.buildings_for_town(town_id, industry_category_id, industry_type_id);
      this.client_state.core.planet_cache.load_town_buildings(town_id, industry_category_id, industry_type_id, buildings);
      return buildings;
    });
  }
  async companies_by_town (town_id: string): Promise<Array<Company>> {
    if (!this.client_state.has_session() || !town_id) {
      throw Error();
    }
    const companies = this.client_state.core.planet_cache.town_companies(town_id);
    if (companies) {
      return Promise.resolve(companies);
    }
    return await this.ajax_state.locked('planet_town_companies', town_id, async () => {
      const companies = (await this.api.companies_for_town(town_id) ?? []).map(Company.from_json);
      this.client_state.core.planet_cache.load_town_companies(town_id, companies);
      return companies;
    });
  }

  async load_metadata_building (): Promise<void> {
    if (!this.client_state.has_session()) {
      throw Error();
    }
    return await this.ajax_state.locked('planet_metadata_building', 'ALL', async () => {
      const definitions_json = await this.api.building_metadata_for_planet();
      this.client_state.core.building_library.load_definitions((definitions_json?.definitions ?? []).map(BuildingDefinition.from_json));
      this.client_state.core.building_library.load_simulation_definitions((definitions_json?.simulationDefinitions ?? []).map(SimulationDefinitionParser.from_json));
    });
  }
  async load_metadata_core (): Promise<void> {
    if (!this.client_state.has_session()) {
      throw Error();
    }
    return await this.ajax_state.locked('planet_metadata_core', 'ALL', async () => {
      const json = await this.api.core_metadata_for_planet()
      this.client_state.core.planet_library.load_city_zones(_.map(json.cityZones, CityZone.fromJson));
      this.client_state.core.planet_library.load_industry_categories(_.map(json.industryCategories, IndustryCategory.fromJson));
      this.client_state.core.planet_library.load_industry_types(_.map(json.industryTypes, IndustryType.fromJson));
      this.client_state.core.planet_library.load_levels(_.map(json.levels, Level.fromJson));
      this.client_state.core.planet_library.load_ranking_types(_.map(json.rankingTypes, RankingType.fromJson));
      this.client_state.core.planet_library.load_resource_types(_.map(json.resourceTypes, ResourceType.fromJson));
      this.client_state.core.planet_library.load_resource_units(_.map(json.resourceUnits, ResourceUnit.fromJson));
      this.client_state.core.planet_library.load_company_seals(_.map(json.seals, CompanySeal.fromJson));
    });
  }
  async load_metadata_invention (): Promise<void> {
    if (!this.client_state.has_session()) {
      throw Error();
    }
    return await this.ajax_state.locked('planet_metadata_invention', 'ALL', async () => {
      const json = await this.api.invention_metadata_for_planet();
      this.client_state.core.invention_library.load_inventions((json?.inventions ?? []).map(InventionDefinition.fromJson));
    });
  }

  async search_corporations (query: string, starts_with_query: boolean): Promise<any> {
    if (!this.client_state.has_session()|| !query?.length) {
      throw Error();
    }
    return await this.ajax_state.locked('planet_search_corporations', 'ALL', async () => {
      return await this.api.search_corporations_for_planet(query, starts_with_query);
    });
  }
  async search_tycoons (query: string, starts_with_query: boolean): Promise<any> {
    if (!this.client_state.has_session()|| !query?.length) {
      throw Error();
    }
    return await this.ajax_state.locked('planet_search_tycoons', 'ALL', async () => {
      return await this.api.search_tycoons_for_planet(query, starts_with_query);
    });
  }
}