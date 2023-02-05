import _ from 'lodash';

import BuildingDefinition from '~/plugins/starpeace-client/building/building-definition.coffee'
import SimulationDefinitionParser from '~/plugins/starpeace-client/building/simulation/simulation-definition-parser.coffee'

import Company from '~/plugins/starpeace-client/company/company.coffee'
import TycoonInfo from '~/plugins/starpeace-client/tycoon/tycoon-info.coffee'

import CityZone from '~/plugins/starpeace-client/industry/city-zone.coffee'
import CompanySeal from '~/plugins/starpeace-client/company/company-seal.coffee'
import IndustryCategory from '~/plugins/starpeace-client/industry/industry-category.coffee'
import IndustryType from '~/plugins/starpeace-client/industry/industry-type.coffee'
import Level from '~/plugins/starpeace-client/industry/level.coffee'
import RankingType from '~/plugins/starpeace-client/corporation/ranking-type.coffee'
import ResourceType from '~/plugins/starpeace-client/industry/resource-type.coffee'
import ResourceUnit from '~/plugins/starpeace-client/industry/resource-unit.coffee'
import InventionDefinition from '~/plugins/starpeace-client/invention/invention-definition.coffee'
import Town from '~/plugins/starpeace-client/planet/town.coffee'
import TownDetails from '~/plugins/starpeace-client/planet/town-details.coffee'

export default class PlanetsManager
  constructor: (@api, @ajax_state, @client_state) ->

  load_online_tycoons: () ->
    throw Error() if !@client_state.has_session()
    await @ajax_state.locked('planet_online_tycoons', 'ALL', =>
      online_tycoons = _.map(await @api.online_tycoons_for_planet(), TycoonInfo.fromJson)
      @client_state.planet.load_tycoons_online(online_tycoons)
      online_tycoons
    )


  load_rankings: (ranking_type_id) ->
    throw Error() if !@client_state.has_session() || !ranking_type_id?
    await @ajax_state.locked('planet_rankings', ranking_type_id, =>
      rankings = await @api.rankings_for_planet(ranking_type_id)
      @client_state.core.planet_cache.load_rankings(ranking_type_id, rankings)
      rankings
    )

  load_towns: () ->
    throw Error() if !@client_state.has_session()
    await @ajax_state.locked('planet_towns', 'ALL', =>
      towns = _.map(await @api.towns_for_planet(), Town.from_json)
      @client_state.planet.load_towns(towns)
      towns
    )

  load_planet_details: () ->
    details = @client_state.core.planet_cache.planet_details()
    return details if details?
    throw Error() if !@client_state.has_session()
    await @ajax_state.locked('planet_details', 'ALL', =>
      details = TownDetails.from_json(await @api.details_for_planet())
      @client_state.core.planet_cache.load_planet_details(details)
      details
    )
  load_town_details: (town_id) ->
    details = @client_state.core.planet_cache.town_details(town_id)
    return details if details?
    throw Error() if !@client_state.has_session() || !town_id?
    await @ajax_state.locked('planet_town_details', town_id, =>
      details = TownDetails.from_json(await @api.details_for_town(town_id))
      @client_state.core.planet_cache.load_town_details(town_id, details)
      details
    )


  buildings_by_town: (town_id, industry_category_id, industry_type_id) ->
    buildings = @client_state.core.planet_cache.town_buildings(town_id, industry_category_id, industry_type_id)
    return buildings if buildings?
    throw Error() if !@client_state.has_session() || !town_id? || !industry_category_id? || !industry_type_id?
    await @ajax_state.locked('planet_town_buildings', "#{town_id}-#{industry_category_id}-#{industry_type_id}", =>
      buildings = await @api.buildings_for_town(town_id, industry_category_id, industry_type_id)
      @client_state.core.planet_cache.load_town_buildings(town_id, industry_category_id, industry_type_id, buildings)
      buildings
    )
  companies_by_town: (town_id) ->
    companies = @client_state.core.planet_cache.town_companies(town_id)
    return companies if companies?
    throw Error() if !@client_state.has_session() || !town_id?
    await @ajax_state.locked('planet_town_companies', town_id, =>
      companies = _.map(await @api.companies_for_town(town_id), Company.from_json)
      @client_state.core.planet_cache.load_town_companies(town_id, companies)
      companies
    )

  load_metadata_building: () ->
    new Promise (done, error) =>
      if !@client_state.has_session() || @ajax_state.is_locked('planet_metadata_building', 'ALL')
        done()
      else
        lock = @ajax_state.with_lock('planet_metadata_building', 'ALL', done, error)
        @api.building_metadata_for_planet()
          .then (definitions_json) =>
            @client_state.core.building_library.load_definitions(_.map(definitions_json?.definitions, (json) -> BuildingDefinition.from_json(json)))
            @client_state.core.building_library.load_simulation_definitions(_.map(definitions_json?.simulationDefinitions, (json) -> SimulationDefinitionParser.from_json(json)))
            lock.done()
          .catch (err) => lock.error(err)
  load_metadata_core: () ->
    new Promise (done, error) =>
      if !@client_state.has_session() || @ajax_state.is_locked('planet_metadata_core', 'ALL')
        done()
      else
        lock = @ajax_state.with_lock('planet_metadata_core', 'ALL', done, error)
        @api.core_metadata_for_planet()
          .then (json) =>
            @client_state.core.planet_library.load_city_zones(_.map(json.cityZones, (json) -> CityZone.from_json(json)))
            @client_state.core.planet_library.load_industry_categories(_.map(json.industryCategories, (json) -> IndustryCategory.from_json(json)))
            @client_state.core.planet_library.load_industry_types(_.map(json.industryTypes, (json) -> IndustryType.from_json(json)))
            @client_state.core.planet_library.load_levels(_.map(json.levels, (json) -> Level.from_json(json)))
            @client_state.core.planet_library.load_ranking_types(_.map(json.rankingTypes, (json) -> RankingType.from_json(json)))
            @client_state.core.planet_library.load_resource_types(_.map(json.resourceTypes, (json) -> ResourceType.from_json(json)))
            @client_state.core.planet_library.load_resource_units(_.map(json.resourceUnits, (json) -> ResourceUnit.from_json(json)))
            @client_state.core.planet_library.load_company_seals(_.map(json.seals, (json) -> CompanySeal.from_json(json)))
            lock.done()
          .catch (err) => lock.error(err)
  load_metadata_invention: () ->
    new Promise (done, error) =>
      if !@client_state.has_session() || @ajax_state.is_locked('planet_metadata_invention', 'ALL')
        done()
      else
        lock = @ajax_state.with_lock('planet_metadata_invention', 'ALL', done, error)
        @api.invention_metadata_for_planet()
          .then (json) =>
            @client_state.core.invention_library.load_inventions(_.map(json?.inventions, (json) -> InventionDefinition.from_json(json)))
            lock.done()
          .catch (err) => lock.error(err)


  search_corporations: (query, starts_with_query) ->
    throw Error() if !@client_state.has_session() || !query?.length
    await @ajax_state.locked('planet_search_corporations', 'ALL', =>
      await @api.search_corporations_for_planet(query, starts_with_query)
    )
  search_tycoons: (query, starts_with_query) ->
    throw Error() if !@client_state.has_session() || !query?.length
    await @ajax_state.locked('planet_search_tycoons', 'ALL', =>
      await @api.search_tycoons_for_planet(query, starts_with_query)
    )
