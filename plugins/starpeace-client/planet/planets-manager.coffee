
import moment from 'moment'

import BuildingDefinition from '~/plugins/starpeace-client/building/building-definition.coffee'
import SimulationDefinitionParser from '~/plugins/starpeace-client/building/simulation/simulation-definition-parser.coffee'

import CityZone from '~/plugins/starpeace-client/industry/city-zone.coffee'
import CompanySeal from '~/plugins/starpeace-client/industry/company-seal.coffee'
import IndustryCategory from '~/plugins/starpeace-client/industry/industry-category.coffee'
import IndustryType from '~/plugins/starpeace-client/industry/industry-type.coffee'
import Level from '~/plugins/starpeace-client/industry/level.coffee'
import ResourceType from '~/plugins/starpeace-client/industry/resource-type.coffee'
import ResourceUnit from '~/plugins/starpeace-client/industry/resource-unit.coffee'
import InventionDefinition from '~/plugins/starpeace-client/invention/invention-definition.coffee'
import DetailsPlanet from '~/plugins/starpeace-client/planet/details-planet.coffee'

export default class PlanetsManager
  constructor: (@api, @ajax_state, @client_state) ->

  load_events: (planet_id) ->
    new Promise (done, error) =>
      if !@client_state.has_session() || !planet_id? || @ajax_state.is_locked('planet_events', planet_id)
        done()
      else
        lock = @ajax_state.with_lock('planet_events', planet_id, done, error)
        events_as_of = @client_state.planet.events_as_of || moment()
        refresh_at = moment()
        @api.events_for_planet(planet_id, events_as_of)
          .then (json) =>
            @client_state.planet.load_state(json.date, json.season)

            for building_event in (json.buildingEvents || [])
              building_chunk_info = @client_state.planet.game_map.building_map.chunk_building_info_at(building_event.x, building_event.y)
              @client_state.planet.game_map.building_map.chunk_building_update_at(building_event.x, building_event.y) if building_chunk_info?

            @client_state.planet.events_as_of = refresh_at
            lock.done()
          .catch (err) => lock.error(err)

  load_online_corporations: (planet_id) ->
    new Promise (done, error) =>
      if !@client_state.has_session() || !planet_id? || @ajax_state.is_locked('planet_online_corporations', planet_id)
        done()
      else
        lock = @ajax_state.with_lock('planet_online_corporations', planet_id, done, error)
        @api.online_corporations_for_planet(planet_id)
          .then (json) =>
            @client_state.planet.load_tycoons_online(json?.corporations || [])
            lock.done()
          .catch (err) => lock.error(err)

  load_towns: (planet_id) ->
    new Promise (done, error) =>
      if !@client_state.has_session() || !planet_id? || @ajax_state.is_locked('planet_towns', planet_id)
        done()
      else
        lock = @ajax_state.with_lock('planet_towns', planet_id, done, error)
        @api.towns_for_planet(planet_id)
          .then (towns_json) =>
            @client_state.planet.load_towns(towns_json || [])
            lock.done()
          .catch (err) => lock.error(err)

  load_metadata_building: (planet_id) ->
    new Promise (done, error) =>
      if !@client_state.has_session() || !planet_id? || @ajax_state.is_locked('planet_metadata_building', planet_id)
        done()
      else
        lock = @ajax_state.with_lock('planet_metadata_building', planet_id, done, error)
        @api.building_metadata_for_planet(planet_id)
          .then (definitions_json) =>
            @client_state.core.building_library.load_definitions(_.map(definitions_json?.definitions, (json) -> BuildingDefinition.from_json(json)))
            @client_state.core.building_library.load_simulation_definitions(_.map(definitions_json?.simulationDefinitions, (json) -> SimulationDefinitionParser.from_json(json)))
            lock.done()
          .catch (err) => lock.error(err)
  load_metadata_core: (planet_id) ->
    new Promise (done, error) =>
      if !@client_state.has_session() || !planet_id? || @ajax_state.is_locked('planet_metadata_core', planet_id)
        done()
      else
        lock = @ajax_state.with_lock('planet_metadata_core', planet_id, done, error)
        @api.core_metadata_for_planet(planet_id)
          .then (json) =>
            @client_state.core.planet_library.load_city_zones(_.map(json.cityZones, (json) -> CityZone.from_json(json)))
            @client_state.core.planet_library.load_industry_categories(_.map(json.industryCategories, (json) -> IndustryCategory.from_json(json)))
            @client_state.core.planet_library.load_industry_types(_.map(json.industryTypes, (json) -> IndustryType.from_json(json)))
            @client_state.core.planet_library.load_levels(_.map(json.levels, (json) -> Level.from_json(json)))
            @client_state.core.planet_library.load_resource_types(_.map(json.resourceTypes, (json) -> ResourceType.from_json(json)))
            @client_state.core.planet_library.load_resource_units(_.map(json.resourceUnits, (json) -> ResourceUnit.from_json(json)))
            @client_state.core.planet_library.load_company_seals(_.map(json.seals, (json) -> CompanySeal.from_json(json)))
            lock.done()
          .catch (err) => lock.error(err)
  load_metadata_invention: (planet_id) ->
    new Promise (done, error) =>
      if !@client_state.has_session() || !planet_id? || @ajax_state.is_locked('planet_metadata_invention', planet_id)
        done()
      else
        lock = @ajax_state.with_lock('planet_metadata_invention', planet_id, done, error)
        @api.invention_metadata_for_planet(planet_id)
          .then (json) =>
            @client_state.core.invention_library.load_inventions(_.map(json?.inventions, (json) -> InventionDefinition.from_json(json)))
            lock.done()
          .catch (err) => lock.error(err)
