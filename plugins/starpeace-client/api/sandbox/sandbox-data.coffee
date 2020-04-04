
import moment from 'moment'
import _ from 'lodash'

import METADATA_BUILDING from '~/plugins/starpeace-client/api/sandbox/data/metadata-building.json'
import METADATA_CORE from '~/plugins/starpeace-client/api/sandbox/data/metadata-core.json'
import METADATA_INVENTION from '~/plugins/starpeace-client/api/sandbox/data/metadata-invention.json'

import BOOKMARKS_METADATA from '~/plugins/starpeace-client/api/sandbox/data/mock-bookmarks-metadata.json'
import GALAXY_METADATA from '~/plugins/starpeace-client/api/sandbox/data/mock-galaxy-metadata.json'
import PLANET_TOWNS from '~/plugins/starpeace-client/api/sandbox/data/mock-planet-towns.json'
import TYCOON_METADATA from '~/plugins/starpeace-client/api/sandbox/data/mock-tycoon-metadata.json'

import PLANET_1_MAP_BUILDINGS from '~/plugins/starpeace-client/api/sandbox/data/mock-planet-1-map-buildings.json'
import PLANET_1_TYCOON_1_BUILDINGS from '~/plugins/starpeace-client/api/sandbox/data/mock-planet-1-tycoon-1-buildings.json'
import PLANET_1_TYCOON_1_INVENTIONS from '~/plugins/starpeace-client/api/sandbox/data/mock-planet-1-tycoon-1-inventions.json'
import PLANET_2_MAP_BUILDINGS from '~/plugins/starpeace-client/api/sandbox/data/mock-planet-2-map-buildings.json'

PLANET_MAP_BUILDINGS = {
  'planet-1': PLANET_1_MAP_BUILDINGS
  'planet-2': PLANET_2_MAP_BUILDINGS
}

MONTH_SEASONS = {
  0: 'winter'
  1: 'winter'
  2: 'spring'
  3: 'spring'
  4: 'spring'
  5: 'summer'
  6: 'summer'
  7: 'summer'
  8: 'fall'
  9: 'fall'
  10: 'fall'
  11: 'winter'
}

export default class SandboxData
  constructor: () ->

    @tycoon_by_id = TYCOON_METADATA
    @corporation_by_id = _.keyBy(_.flatten(_.map(_.values(TYCOON_METADATA), 'corporations')), 'id')
    @bookmarks_by_corporation_id = BOOKMARKS_METADATA

    @metadata = {
      buildings: METADATA_BUILDING
      core: METADATA_CORE
      inventions: METADATA_INVENTION
    }

    @galaxy_metadata = GALAXY_METADATA
    @planet_towns = PLANET_TOWNS

    @planet_id_dates = {
      'planet-1': moment('2235-01-01')
      'planet-2': moment('2235-01-01')
      'planet-3': moment('2235-01-01')
    }

    @corporation_id_cashflow = {}
    @company_id_info = {}
    for tycoon_id,tycoon of TYCOON_METADATA
      for corporation in tycoon.corporations
        @corporation_id_cashflow[corporation.id] = {
          cash: corporation.cash || 0
          companies_by_id: {}
          cashflow: () -> _.reduce(_.values(@companies_by_id), ((sum, company) -> sum + company.cashflow), 0)
          increment_cash: () -> @cash = @cash + 24 * @cashflow()
        }

        for company in corporation.companies
          @corporation_id_cashflow[corporation.id].companies_by_id[company.id] = {
            id: company.id
            cashflow: 0
            original_cashflow: 0
            adjust_cashflow: (temporary_delta) -> @cashflow = @original_cashflow + (Math.floor(Math.random() * 500) - 50) * 1000 + temporary_delta
          }

          @company_id_info[company.id] = {
            tycoon_id: tycoon_id
            corporation_id: corporation.id
            planet_id: corporation.planetId
          }

    @company_id_inventions = {}
    for company_id,invention_data of PLANET_1_TYCOON_1_INVENTIONS
      @company_id_inventions[company_id] = invention_data

    @company_id_buildings = {}
    for company_id,buildings of PLANET_1_TYCOON_1_BUILDINGS
      @company_id_buildings[company_id] = buildings

    @planet_id_chunk_id_buildings = {}
    @building_id_building = {}
    for planet_id,planet_buildings of PLANET_MAP_BUILDINGS
      @planet_id_chunk_id_buildings[planet_id] = {} unless @planet_id_chunk_id_buildings[planet_id]?
      for chunk_id,chunk_buildings of planet_buildings
        @planet_id_chunk_id_buildings[planet_id][chunk_id] = chunk_buildings
        for building in chunk_buildings
          @company_id_buildings[building.companyId] = [] unless @company_id_buildings[building.companyId]?
          @company_id_buildings[building.companyId].push building
          @building_id_building[building.id] = building

  season_for_planet: (planet_id) ->
    if @planet_id_dates[planet_id]? then MONTH_SEASONS[@planet_id_dates[planet_id].month()] else 'winter'

  add_building: (planet_id, company_id, chunk_key, building) ->
    @planet_id_chunk_id_buildings[planet_id] = {} unless @planet_id_chunk_id_buildings[planet_id]?
    @planet_id_chunk_id_buildings[planet_id][chunk_key] = [] unless @planet_id_chunk_id_buildings[planet_id][chunk_key]?
    @planet_id_chunk_id_buildings[planet_id][chunk_key].push building

    @company_id_buildings[company_id] = [] unless @company_id_buildings[company_id]?
    @company_id_buildings[company_id].push building

    @building_id_building[building.id] = building
