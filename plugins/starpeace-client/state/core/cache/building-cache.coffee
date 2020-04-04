import Vue from 'vue'

import Cache from '~/plugins/starpeace-client/state/core/cache/cache.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class BuildingCache extends Cache
  constructor: () ->
    super()

  reset_planet: () ->
    @building_metadata_by_id = {}

  load_building: (building) ->
    Vue.set(@building_metadata_by_id, building.id, building)
  load_buildings: (buildings) ->
    @load_building(building) for building in buildings

  remove_building: (building) ->
    Vue.delete(@building_metadata_by_id, building.id)

  building_for_id: (building_id) -> @building_metadata_by_id[building_id]
