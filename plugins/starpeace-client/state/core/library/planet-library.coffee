import _ from 'lodash';

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
    @ranking_types_by_id = {}
    @resource_types_by_id = {}
    @resource_units_by_id = {}
    @company_seals_by_id = {}

  has_metadata: () ->
    Object.keys(@city_zones_by_id || {}).length > 0 &&
      Object.keys(@industry_categories_by_id || {}).length > 0 &&
      Object.keys(@industry_types_by_id || {}).length > 0 &&
      Object.keys(@levels_by_id || {}).length > 0 &&
      Object.keys(@ranking_types_by_id || {}).length > 0 &&
      Object.keys(@resource_types_by_id || {}).length > 0 &&
      Object.keys(@resource_units_by_id || {}).length > 0 &&
      Object.keys(@company_seals_by_id || {}).length > 0

  zone_for_id: (city_zone_id) -> @city_zones_by_id[city_zone_id]
  zone_for_value: (value) -> @city_zones_by_value[value]
  load_city_zones: (city_zones) ->
    for city_zone in (city_zones || [])
      @city_zones_by_id[city_zone.id] = city_zone
      @city_zones_by_value[city_zone.value] = city_zone

  category_for_id: (industry_category_id) -> @industry_categories_by_id[industry_category_id]
  categories_for_inventions: () -> _.without(_.map(_.values(@industry_categories_by_id), 'id'), 'NONE')
  load_industry_categories: (categories) ->
    for category in (categories || [])
      @industry_categories_by_id[category.id] = category

  type_for_id: (type_id) -> @industry_types_by_id[type_id]
  load_industry_types: (types) ->
    for type in (types || [])
      @industry_types_by_id[type.id] = type

  level_for_id: (level_id) -> @levels_by_id[level_id]
  next_level_for_id: (level_id) ->
    current_level = @levels_by_id[level_id]?.level
    ordered_levels = _.orderBy(Object.values(@levels_by_id), ['level'], ['asc'])
    index = ordered_levels.findIndex((l) => l.level > current_level)
    if index >= 0 then ordered_levels[index] else null
  load_levels: (levels) ->
    for level in (levels || [])
      @levels_by_id[level.id] = level

  ranking_type_for_id: (type_id) -> @ranking_types_by_id[type_id]
  ranking_type_for_parent_id: (parent_id) -> _.filter(_.values(@ranking_types_by_id), (type) -> type.parent_id == parent_id)
  ranking_type_roots: () -> _.filter(_.values(@ranking_types_by_id), (type) -> !type.parent_id?.length)
  load_ranking_types: (types) ->
    for type in (types || [])
      @ranking_types_by_id[type.id] = type

  all_resource_types: () -> Object.values(@resource_types_by_id)
  resource_type_for_id: (type_id) -> @resource_types_by_id[type_id]
  load_resource_types: (types) ->
    for type in (types || [])
      @resource_types_by_id[type.id] = type

  resource_unit_for_id: (unit_id) -> @resource_units_by_id[unit_id]
  load_resource_units: (units) ->
    for unit in (units || [])
      @resource_units_by_id[unit.id] = unit

  seal_for_id: (seal_id) -> @company_seals_by_id[seal_id]
  seals_for_inventions: () -> _.without(_.map(_.values(@company_seals_by_id), 'id'), 'GEN')
  seals_for_buildings: () -> _.without(_.map(_.values(@company_seals_by_id), 'id'), 'GEN')
  load_company_seals: (seals) ->
    for seal in (seals || [])
      @company_seals_by_id[seal.id] = seal
