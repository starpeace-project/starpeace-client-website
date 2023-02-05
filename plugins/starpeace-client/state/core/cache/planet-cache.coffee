import _ from 'lodash'
import TinyCache from 'tinycache'
import { markRaw } from 'vue';

import Cache from '~/plugins/starpeace-client/state/core/cache/cache.coffee'

import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class PlanetCache extends Cache
  constructor: () ->
    super()
    @details_for_planet = markRaw(new TinyCache())
    @buildings_by_town_id = markRaw(new TinyCache())
    @companies_by_town_id = markRaw(new TinyCache())
    @details_by_town_id = markRaw(new TinyCache())
    @rankings_by_type_id = markRaw(new TinyCache())

    # Object.defineProperty(@, 'details_for_planet', { configurable: false }) # disable Vue.observable
    # Object.defineProperty(@, 'buildings_by_town_id', { configurable: false }) # disable Vue.observable
    # Object.defineProperty(@, 'companies_by_town_id', { configurable: false }) # disable Vue.observable
    # Object.defineProperty(@, 'details_by_town_id', { configurable: false }) # disable Vue.observable
    # Object.defineProperty(@, 'rankings_by_type_id', { configurable: false }) # disable Vue.observable

  reset_planet: () ->
    @details_for_planet.clear()
    @buildings_by_town_id.clear()
    @companies_by_town_id.clear()
    @details_by_town_id.clear()
    @rankings_by_type_id.clear()

  subscribe_rankings_listener: (listener_callback) -> @event_listener.subscribe('planet_cache.rankings', listener_callback)
  notify_rankings_listeners: () -> @event_listener.notify_listeners('planet_cache.rankings')

  planet_details: () -> @details_for_planet.get('PLANET')
  load_planet_details: (details) -> @details_for_planet.put('PLANET', details, Cache.FIVE_MINUTES)

  town_details: (town_id) -> @details_by_town_id.get(town_id)
  load_town_details: (town_id, details) -> @details_by_town_id.put(town_id, details, Cache.FIVE_MINUTES)

  rankings: (ranking_type_id) -> @rankings_by_type_id.get(ranking_type_id)
  load_rankings: (ranking_type_id, rankings) ->
    @rankings_by_type_id.put(ranking_type_id, rankings, Cache.FIVE_MINUTES)
    @notify_rankings_listeners()

  town_companies: (town_id) -> @companies_by_town_id.get(town_id)
  load_town_companies: (town_id, companies) -> @companies_by_town_id.put(town_id, companies, Cache.FIVE_MINUTES)

  town_buildings: (town_id, industry_category_id, industry_type_id) -> @buildings_by_town_id.get("#{town_id}-#{industry_category_id}-#{industry_type_id}")
  load_town_buildings: (town_id, industry_category_id, industry_type_id, buildings) -> @buildings_by_town_id.put("#{town_id}-#{industry_category_id}-#{industry_type_id}", buildings, Cache.FIVE_MINUTES)
