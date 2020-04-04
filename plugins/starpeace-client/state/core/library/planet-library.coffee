import moment from 'moment'
import Vue from 'vue'

import Library from '~/plugins/starpeace-client/state/core/library/library.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class PlanetLibrary extends Library
  constructor: () ->
    super()
    @reset_planet()

  reset_planet: () ->
    @core_metadata = null

    @city_zones_by_id = {}
    @city_zones_by_value = {}

    @industry_categories_by_id = {}
    @industry_types_by_id = {}
    @levels_by_id = {}
    @resource_types_by_id = {}
    @resource_units_by_id = {}
    @company_seals_by_id = {}

  has_metadata: () ->
    Object.keys(@city_zones_by_id || {}).length &&
      Object.keys(@industry_categories_by_id || {}).length &&
      Object.keys(@industry_types_by_id || {}).length &&
      Object.keys(@levels_by_id || {}).length &&
      Object.keys(@resource_types_by_id || {}).length &&
      Object.keys(@resource_units_by_id || {}).length &&
      Object.keys(@company_seals_by_id || {}).length

  zone_for_id: (city_zone_id) -> @city_zones_by_id[city_zone_id]
  zone_for_value: (value) -> @city_zones_by_value[value]
  load_city_zones: (city_zones) ->
    for city_zone in (city_zones || [])
      Vue.set(@city_zones_by_id, city_zone.id, city_zone)
      Vue.set(@city_zones_by_value, city_zone.value, city_zone)

  category_for_id: (industry_category_id) -> @industry_categories_by_id[industry_category_id]
  categories_for_inventions: () -> _.without(_.map(_.values(@industry_categories_by_id), 'id'), 'NONE')
  load_industry_categories: (categories) ->
    for category in (categories || [])
      Vue.set(@industry_categories_by_id, category.id, category)

  type_for_id: (type_id) -> @industry_types_by_id[type_id]
  load_industry_types: (types) ->
    for type in (types || [])
      Vue.set(@industry_types_by_id, type.id, type)

  level_for_id: (seal_id) -> @levels_by_id[seal_id]
  load_levels: (levels) ->
    for level in (levels || [])
      Vue.set(@levels_by_id, level.id, level)

  resource_type_for_id: (type_id) -> @resource_types_by_id[type_id]
  load_resource_types: (types) ->
    for type in (types || [])
      Vue.set(@resource_types_by_id, type.id, type)

  resource_unit_for_id: (unit_id) -> @resource_units_by_id[unit_id]
  load_resource_units: (units) ->
    for unit in (units || [])
      Vue.set(@resource_units_by_id, unit.id, unit)

  seal_for_id: (seal_id) -> @company_seals_by_id[seal_id]
  seals_for_inventions: () -> _.without(_.map(_.values(@company_seals_by_id), 'id'), 'GEN')
  seals_for_buildings: () -> _.without(_.map(_.values(@company_seals_by_id), 'id'), 'GEN')
  load_company_seals: (seals) ->
    for seal in (seals || [])
      Vue.set(@company_seals_by_id, seal.id, seal)
