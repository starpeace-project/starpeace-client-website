import TinyCache from 'tinycache';
import { markRaw } from 'vue';

import Cache from '~/plugins/starpeace-client/state/core/cache/cache.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class BuildingCache extends Cache
  constructor: () ->
    super()
    @details_by_building_id = markRaw(new TinyCache())

    # Object.defineProperty(@, 'details_by_building_id', { configurable: false }) # disable Vue.observable

  reset_planet: () ->
    @building_metadata_by_id = {}
    @details_by_building_id.clear()

  building_for_id: (building_id) -> @building_metadata_by_id[building_id]
  load_building: (building) ->
    @building_metadata_by_id[building.id] = building
  load_buildings: (buildings) ->
    @load_building(building) for building in buildings

  remove_building: (building) -> delete @building_metadata_by_id[building.id]

  building_details: (building_id) -> @details_by_building_id.get(building_id)
  load_building_details: (building_id, details) -> @details_by_building_id.put(building_id, details, Cache.ONE_MINUTE)
