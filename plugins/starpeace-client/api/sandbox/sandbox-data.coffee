import _ from 'lodash';
import { DateTime } from 'luxon';

import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

import METADATA_BUILDING from '~/plugins/starpeace-client/api/sandbox/data/metadata-building.json'
import METADATA_CORE from '~/plugins/starpeace-client/api/sandbox/data/metadata-core.json'
import METADATA_INVENTION from '~/plugins/starpeace-client/api/sandbox/data/metadata-invention.json'

import BOOKMARKS_METADATA from '~/plugins/starpeace-client/api/sandbox/data/mock-bookmarks-metadata.json'
import GALAXY_METADATA from '~/plugins/starpeace-client/api/sandbox/data/mock-galaxy-metadata.json'
import MAIL from '~/plugins/starpeace-client/api/sandbox/data/mock-mail.json'
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
  12: 'winter'
}

SERVICE_TYPES = ['COLLEGE', 'GARBAGE', 'FIRE', 'HOSPITAL', 'PRISON', 'MUSEUM', 'POLICE', 'SCHOOL', 'PARK']
RATING_TYPES = SERVICE_TYPES.concat(['TAX_REVENUE', 'EMPLOYMENT', 'POPULATION_GROWTH', 'ECONOMIC_GROWTH'])

export default class SandboxData
  constructor: () ->
    @access_tokens = {}

    @tycoon_by_id = TYCOON_METADATA

    @corporation_by_id = {}
    @corporation_identifiers_by_tycoon_id = {}
    for tycoon_id,tycoon of @tycoon_by_id
      @corporation_identifiers_by_tycoon_id[tycoon_id] = []
      for corporation in tycoon.corporations
        @corporation_identifiers_by_tycoon_id[tycoon_id].push({id: corporation.id, name: corporation.name, planetId: corporation.planetId})
        @corporation_by_id[corporation.id] = corporation

    @bookmarks_by_corporation_id = BOOKMARKS_METADATA
    @mail_by_corporation_id = MAIL

    @strategies_by_corporation_id = {
      'corp-id-1': [{
        id: 's-id-1'
        corporationId: 'corp-id-1'
        policy: 'NONE'
        otherTycoonId: 'tycoon-id-2'
        otherTycoonName: 'Other Tycoon'
        otherCorporationId: 'corp-id-4'
        otherCorporationName: 'Corporation Other'
        otherPolicy: 'PRIORITIZE'
      }, {
        id: 's-id-2'
        corporationId: 'corp-id-1'
        policy: 'PRIORITIZE'
        otherTycoonId: 'tycoon-id-3'
        otherTycoonName: 'Other Tycoon 2'
        otherCorporationId: 'corp-id-5'
        otherCorporationName: 'Corporation Other 2'
        otherPolicy: 'PRIORITIZE'
      }, {
        id: 's-id-3'
        corporationId: 'corp-id-1'
        policy: 'EMBARGO'
        otherTycoonId: 'tycoon-id-4'
        otherTycoonName: 'Other Tycoon 3'
        otherCorporationId: 'corp-id-6'
        otherCorporationName: 'Corporation Other 3'
        otherPolicy: 'NONE'
      }, {
        id: 's-id-4'
        corporationId: 'corp-id-1'
        policy: 'NONE'
        otherTycoonId: 'tycoon-id-5'
        otherTycoonName: 'Other Tycoon 4'
        otherCorporationId: 'corp-id-7'
        otherCorporationName: 'Corporation Other 4'
        otherPolicy: 'EMBARGO'
      }]
    }


    @planet_rankings_by_type_id = {}
    for planet_id in ['planet-1', 'planet-2', 'planet-3']
      corporations = _.filter(_.values(@corporation_by_id), (corporation) -> corporation.planetId == planet_id)
      @planet_rankings_by_type_id[planet_id] = {}
      for ranking_type in METADATA_CORE.rankingTypes
        max_value = switch ranking_type.type
          when 'CORPORATION' then 15000
          when 'PROFIT' then 1000000000
          when 'PRESTIGE' then 1000
          when 'WEALTH' then 1000000000000
          else 0
        continue unless max_value > 0

        @planet_rankings_by_type_id[planet_id][ranking_type.id] = _.map(_.orderBy(_.map(corporations, (corporation) => {
          rank: 0
          value: Math.round(max_value * Math.random())
          tycoonId: corporation.tycoonId
          tycoonName: @tycoon_by_id[corporation.tycoonId].name
          corporationId: corporation.id
          corporationName: corporation.name
        }), ['value'], ['desc']), (ranking, index) ->
          ranking.rank = index + 1
          ranking
        )

    @metadata = {
      buildings: METADATA_BUILDING
      core: METADATA_CORE
      inventions: METADATA_INVENTION
    }

    @galaxy_metadata = GALAXY_METADATA
    @planet_towns = PLANET_TOWNS

    @planet_id_dates = {
      'planet-1': DateTime.fromISO('2235-01-01')
      'planet-2': DateTime.fromISO('2235-01-01')
      'planet-3': DateTime.fromISO('2235-01-01')
    }

    @corporation_id_cashflow = {}
    @company_id_info = {}
    for tycoon_id,tycoon of TYCOON_METADATA
      for corporation in tycoon.corporations
        mailAt = _.first(_.orderBy(@mail_by_corporation_id[corporation.id], ['desc'], ['sentAt']))?.sentAt
        cash = corporation.cash || 0
        @corporation_id_cashflow[corporation.id] = {
          lastMailAt: if mailAt? then DateTime.fromISO(mailAt) else null
          cash: cash
          cashCurrentYear: cash / 4
          companies_by_id: {}
          cashflow: () -> _.reduce(_.values(@companies_by_id), ((sum, company) -> sum + company.cashflow), 0)
          increment_cash: () ->
            daily_cashflow = 24 * @cashflow()
            @cashCurrentYear = @cashCurrentYear + daily_cashflow
            @cash = @cash + daily_cashflow
        }

        for company in corporation.companies
          @corporation_id_cashflow[corporation.id].companies_by_id[company.id] = {
            id: company.id
            cashflow: 0
            original_cashflow: 0
            adjust_cashflow: (temporary_delta) -> @cashflow = @original_cashflow + (Math.floor(Math.random() * 500) - 50) * 1000 + temporary_delta
          }

          @company_id_info[company.id] = {
            id: company.id
            name: company.name
            sealId: company.sealId
            tycoonId: tycoon_id
            tycoon_id: tycoon_id
            corporationId: corporation.id
            corporation_id: corporation.id
            planetId: corporation.planetId
            planet_id: corporation.planetId
          }

    @company_id_inventions = {}
    for company_id,invention_data of PLANET_1_TYCOON_1_INVENTIONS
      @company_id_inventions[company_id] = invention_data

    @company_id_buildings = {}
    for company_id,buildings of PLANET_1_TYCOON_1_BUILDINGS
      @company_id_buildings[company_id] = buildings

    planet_id_resource_sinks = {}
    @planet_id_chunk_id_buildings = {}
    @building_id_building = {}
    @building_id_building_details = {}
    for planet_id,planet_buildings of PLANET_MAP_BUILDINGS
      planet_id_resource_sinks[planet_id] = {} unless planet_id_resource_sinks[planet_id]?
      @planet_id_chunk_id_buildings[planet_id] = {} unless @planet_id_chunk_id_buildings[planet_id]?
      for chunk_id,chunk_buildings of planet_buildings
        @planet_id_chunk_id_buildings[planet_id][chunk_id] = chunk_buildings
        for building in chunk_buildings
          @building_id_building[building.id] = building

          if building.companyId?
            @company_id_buildings[building.companyId] = [] unless @company_id_buildings[building.companyId]?
            @company_id_buildings[building.companyId].push building

            @company_id_info[building.companyId] = {
              id: building.companyId
              name: 'Random Company ' + Math.round(Math.random() * 100)
              sealId: 'DIS'
              tycoonId: building.tycoonId
              tycoon_id: building.tycoonId
              corporationId: building.corporationId
              corporation_id: building.corporationId
              planetId: planet_id
              planet_id: planet_id
            } if !@company_id_info[building.companyId]

          simulation = _.find(METADATA_BUILDING.simulationDefinitions, (d) -> d.id == building.definitionId)
          continue unless simulation?
          for stage in (simulation.stages || [])
            for input in (stage.inputs || [])
              planet_id_resource_sinks[planet_id][input.resourceId] = new Set() unless planet_id_resource_sinks[planet_id][input.resourceId]?
              planet_id_resource_sinks[planet_id][input.resourceId].add(building.id)
          for product in (simulation.products || [])
            for input in (product.inputs || [])
              planet_id_resource_sinks[planet_id][input.resourceId] = new Set() unless planet_id_resource_sinks[planet_id][input.resourceId]?
              planet_id_resource_sinks[planet_id][input.resourceId].add(building.id)

    for planet_id,planet_buildings of PLANET_MAP_BUILDINGS
      for chunk_id,chunk_buildings of planet_buildings
        for building in chunk_buildings
          simulation = _.find(METADATA_BUILDING.simulationDefinitions, (d) -> d.id == building.definitionId)
          if simulation?.type == 'TRADECENTER'
            @building_id_building_details[building.id] = {
              id: building.id
              products: _.map(simulation.products, (p) =>
                connections = _.map(Array.from(planet_id_resource_sinks[planet_id][p.resourceId] || []), (bid) =>
                  velocity = Math.floor(Math.random() * 10000)
                  {
                    id: Utils.uuid()
                    valid: Math.floor(Math.random() * 3) > 0
                    sinkCompanyId: @building_id_building[bid].companyId
                    sinkCompanyName: @company_id_info[@building_id_building[bid].companyId]?.company_name || @building_id_building[bid].companyId
                    sinkBuildingId: bid
                    sinkBuildingName: @building_id_building[bid].name
                    sinkBuildingMapX: @building_id_building[bid].mapX
                    sinkBuildingMapY: @building_id_building[bid].mapY
                    velocity: velocity
                    transportCost: velocity * 0.01
                  })
                {
                  resourceId: p.resourceId
                  price: _.find(METADATA_CORE.resourceTypes, (t) -> t.id == p.resourceId).price
                  totalVelocity: _.reduce(connections, ((sum, c) -> c.velocity + sum), 0)
                  quality: .4
                  connections: connections
                })
            }


    @empty_overlay_data = Uint8Array.from("0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" +
        "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" +
        "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" +
        "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000").buffer
    @overlay_chunk_data = {}
    for type in ['ZONES', 'BEAUTY', 'HC_RESIDENTIAL', 'MC_RESIDENTIAL', 'LC_RESIDENTIAL', 'QOL',
        'CRIME', 'POLLUTION', 'BAP', 'FRESH_FOOD', 'PROCESSED_FOOD', 'CLOTHES', 'APPLIANCES',
        'CARS', 'RESTAURANTS', 'BARS', 'TOYS', 'DRUGS', 'MOVIES', 'GASOLINE', 'COMPUTERS',
        'FURNITURE', 'BOOKS', 'COMPACT_DISCS', 'FUNERAL_PARLORS']
      for chunk_y in [2...9]
        for chunk_x in [8...14]
          info = @overlay_chunk_data["#{type}x#{chunk_x}x#{chunk_y}"] = {
            chunk_x: chunk_x
            chunk_y: chunk_y
            width: 20
            height: 20
          }

          if type == 'ZONES'
            info.data = Uint8Array.from("1111122222333334444411111222223333344444111112222233333444441111122222333334444411111222223333344444" +
                "5555566666777778888855555666667777788888555556666677777888885555566666777778888855555666667777111888" +
                "9999900000000012100099999000000000111000999990000000000000009999900000000000000099999000000000000000" +
                "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000").buffer
          else
            magnitude = 0.5 + 0.5 * Math.random()
            data = new Array(20 * 20)
            for y in [0...20]
              for x in [0...20]
                distance = Math.sqrt((10 - x) * (10 - x) + (10 - y) * (10 - y))
                data[y * 20 + x] = Math.round(255 * (1 - Math.min(1, magnitude * (distance / 10))))
            info.data = Uint8Array.from(data).buffer

    ROAD_X_START = 190
    ROAD_X_END = 250
    ROAD_Y_START = 50
    ROAD_Y_END = 400

    @empty_road_buffer = new Uint8Array(20 * 20 * .5).buffer
    road_chunk_data = {}
    for y in [ROAD_Y_START..ROAD_Y_END] by 1
      for x in [ROAD_X_START..ROAD_X_END] by 1
        x_line = (x - 190) % 20 == 0
        y_line = y % 10 == 0
        continue unless x_line || y_line
        chunk_x = Math.floor(x / 20)
        chunk_y = Math.floor(y / 20)
        chunk_key = "#{chunk_x}x#{chunk_y}"
        road_chunk_data[chunk_key] = new Uint8Array(20 * 20) unless road_chunk_data[chunk_key]?

        has_n = x_line && y > ROAD_Y_START
        has_e = y_line && x < ROAD_X_END
        has_s = x_line && y < ROAD_Y_END
        has_w = y_line && x > ROAD_X_START

        index = 20 * (y - chunk_y * 20) + (x - chunk_x * 20)
        road_chunk_data[chunk_key][index] = ((has_n & 0x01) << 0) | ((has_e & 0x01) << 1) | ((has_s & 0x01) << 2) | ((has_w & 0x01) << 3)


    @road_chunk_data = {}
    for chunk_key in Object.keys(road_chunk_data)
      @road_chunk_data[chunk_key] = new Uint8Array(road_chunk_data[chunk_key].length * .5)
      for index in [0...data.length]
        @road_chunk_data[chunk_key][index] = ((road_chunk_data[chunk_key][index * 2 + 0] & 0x0F) << 4) | ((road_chunk_data[chunk_key][index * 2 + 1] & 0x0F) << 0)

    COMMERCE_TAX_CATEGORY_IDS = new Set(['COMMERCE', 'INDUSTRY', 'LOGISTICS', 'REAL_ESTATE', 'SERVICE'])
    COMMERCE_TAX_SKIPPED_INDUSTRY_IDS = new Set(['HEADQUARTERS', 'MAUSOLEUM'])
    types_by_categories = {}
    for definition in METADATA_BUILDING.definitions
      continue unless COMMERCE_TAX_CATEGORY_IDS.has(definition.industryCategoryId)
      continue if COMMERCE_TAX_SKIPPED_INDUSTRY_IDS.has(definition.industryTypeId)
      types_by_categories[definition.industryCategoryId] = new Set() unless types_by_categories[definition.industryCategoryId]?
      types_by_categories[definition.industryCategoryId].add(definition.industryTypeId)

    commerce_types = Array.from(types_by_categories['COMMERCE'])
    tax_types = []
    for category,types of types_by_categories
      for type in Array.from(types)
        tax_types.push { c: category, t: type }

    @planet_details = {
      qol: Math.random()
      services: _.map(SERVICE_TYPES, (t) -> {
        type: t
        value: Math.random()
      })
      commerce: _.map(commerce_types, (t) -> {
        industryTypeId: t
        demand: 0
        supply: 0
        capacity: 0
        ratio: Math.random()
        ifelPrice: 0
        averagePrice: 0
        quality: 0
      })
      taxes: _.map(tax_types, (t) -> {
        industryCategoryId: t.c
        industrytypeId: t.t
        taxRate: Math.random()
        lastYear: 0
      })
      population: [{
        type: "EXECUTIVE"
        population: 0
        unemployed: 0
        homeless: 0
      }, {
        type: "PROFESSIONAL"
        population: 0
        unemployed: 0
        homeless: 0
      }, {
        "type": "WORKER"
        population: 0
        unemployed: 0
        homeless: 0
      }]
      employment: [{
        type: "EXECUTIVE"
        vacancies: 0
        spendingPower: .8
        averageWage: 1
        minimumWage: 1
      }, {
        type: "PROFESSIONAL"
        vacancies: 0
        spendingPower: .25
        averageWage: 1
        minimumWage: 1
      }, {
        type: "WORKER"
        vacancies: 0
        spendingPower: .05
        averageWage: 1
        minimumWage: 1
      }]
      housing: [{
        type: "EXECUTIVE"
        vacancies: 0
        averageRent: 1
        qualityIndex: Math.random()
      }, {
        type: "PROFESSIONAL"
        vacancies: 0
        averageRent: 1
        qualityIndex: Math.random()
      }, {
        type: "WORKER"
        vacancies: 0
        averageRent: 1
        qualityIndex: Math.random()
      }]
      currentTerm: {
        start: '2230-01-01'
        end: '2240-01-01'
        length: 120
        overallRating: Math.random()
        serviceRatings: _.map(RATING_TYPES, (t) -> {
          type: t
          delta: Math.round((Math.random() - .5) * 100)
          rating: Math.random()
        })
      }
      nextTerm: {
        start: '2240-01-01'
        end: '2250-01-01'
        length: 120
        candidates: []
      }
    }

    @empty_town_details = {
      qol: Math.random()
      services: _.map(SERVICE_TYPES, (t) -> {
        type: t
        value: Math.random()
      })
      commerce: _.map(commerce_types, (t) -> {
        industryTypeId: t
        demand: 0
        supply: 0
        capacity: 0
        ratio: Math.random()
        ifelPrice: 0
        averagePrice: 0
        quality: 0
      })
      taxes: _.map(tax_types, (t) -> {
        industryCategoryId: t.c
        industrytypeId: t.t
        taxRate: Math.random()
        lastYear: 0
      })
      population: [{
        type: "EXECUTIVE"
        population: 0
        unemployed: 0
        homeless: 0
      }, {
        type: "PROFESSIONAL"
        population: 0
        unemployed: 0
        homeless: 0
      }, {
        "type": "WORKER"
        population: 0
        unemployed: 0
        homeless: 0
      }]
      employment: [{
        type: "EXECUTIVE"
        vacancies: 0
        spendingPower: .8
        averageWage: 1
        minimumWage: 1
      }, {
        type: "PROFESSIONAL"
        vacancies: 0
        spendingPower: .25
        averageWage: 1
        minimumWage: 1
      }, {
        type: "WORKER"
        vacancies: 0
        spendingPower: .05
        averageWage: 1
        minimumWage: 1
      }]
      housing: [{
        type: "EXECUTIVE"
        vacancies: 0
        averageRent: 1
        qualityIndex: Math.random()
      }, {
        type: "PROFESSIONAL"
        vacancies: 0
        averageRent: 1
        qualityIndex: Math.random()
      }, {
        type: "WORKER"
        vacancies: 0
        averageRent: 1
        qualityIndex: Math.random()
      }]
      currentTerm: {
        start: '2230-01-01'
        end: '2240-01-01'
        length: 120
        overallRating: Math.random()
        serviceRatings: _.map(RATING_TYPES, (t) -> {
          type: t
          delta: Math.round((Math.random() - .5) * 100)
          rating: Math.random()
        })
      }
      nextTerm: {
        start: '2240-01-01'
        end: '2250-01-01'
        length: 120
        candidates: []
      }
    }
    @town_details = {}
    @town_details['town-id-8'] = {
      qol: Math.random()
      services: _.map(SERVICE_TYPES, (t) -> {
        type: t
        value: Math.random()
      })
      commerce: _.map(commerce_types, (t) -> {
        industryTypeId: t
        demand: 0
        supply: 0
        capacity: 0
        ratio: Math.random()
        ifelPrice: 0
        averagePrice: 0
        quality: 0
      })
      taxes: _.map(tax_types, (t) -> {
        industryCategoryId: t.c
        industrytypeId: t.t
        taxRate: Math.random()
        lastYear: 0
      })
      population: [{
        type: "EXECUTIVE"
        population: 0
        unemployed: 0
        homeless: 0
      }, {
        type: "PROFESSIONAL"
        population: 0
        unemployed: 0
        homeless: 0
      }, {
        "type": "WORKER"
        population: 0
        unemployed: 0
        homeless: 0
      }]
      employment: [{
        type: "EXECUTIVE"
        vacancies: 0
        spendingPower: .8
        averageWage: 1
        minimumWage: 1
      }, {
        type: "PROFESSIONAL"
        vacancies: 0
        spendingPower: .25
        averageWage: 1
        minimumWage: 1
      }, {
        type: "WORKER"
        vacancies: 0
        spendingPower: .05
        averageWage: 1
        minimumWage: 1
      }]
      housing: [{
        type: "EXECUTIVE"
        vacancies: 0
        averageRent: 1
        qualityIndex: Math.random()
      }, {
        type: "PROFESSIONAL"
        vacancies: 0
        averageRent: 1
        qualityIndex: Math.random()
      }, {
        type: "WORKER"
        vacancies: 0
        averageRent: 1
        qualityIndex: Math.random()
      }]
      currentTerm: {
        start: '2230-01-01'
        end: '2240-01-01'
        length: 120
        politician: {
          id: 'tycoon-id-1'
          name: 'Tycoon Name'
          prestige: 300
          terms: 1
        }
        overallRating: Math.random()
        serviceRatings: _.map(RATING_TYPES, (t) -> {
          type: t
          delta: Math.round((Math.random() - .5) * 100)
          rating: Math.random()
        })
      }
      nextTerm: {
        start: '2240-01-01'
        end: '2250-01-01'
        length: 120
        candidates: [{
          id: 'tycoon-id-1'
          name: 'Tycoon Name'
          prestige: 300
          votes: 2
        }]
      }
    }

  season_for_planet: (planet_id) ->
    MONTH_SEASONS[@planet_id_dates[planet_id]?.month] || 'winter'

  add_building: (planet_id, company_id, chunk_key, building) ->
    @planet_id_chunk_id_buildings[planet_id] = {} unless @planet_id_chunk_id_buildings[planet_id]?
    @planet_id_chunk_id_buildings[planet_id][chunk_key] = [] unless @planet_id_chunk_id_buildings[planet_id][chunk_key]?
    @planet_id_chunk_id_buildings[planet_id][chunk_key].push building

    @company_id_buildings[company_id] = [] unless @company_id_buildings[company_id]?
    @company_id_buildings[company_id].push building

    @building_id_building[building.id] = building
