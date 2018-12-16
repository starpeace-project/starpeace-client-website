
import moment from 'moment'
import Vue from 'vue'

import EventListener from '~/plugins/starpeace-client/state/event-listener.coffee'

import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class PlanetsCache
  constructor: () ->
    @event_listener = new EventListener()
    @reset_state()

  reset_state: () ->
    @planet_metadata_by_id = {}

  subscribe_planets_metadata_listener: (listener_callback) -> @event_listener.subscribe('planets_cache.metadata', listener_callback)
  notify_planets_metadata_listeners: () -> @event_listener.notify_listeners('planets_cache.metadata')

  has_planet_metadata_fresh: (planet_id) -> @planet_metadata_by_id[planet_id]?.is_fresh() || false

  set_planets_metadata: (planets_metadata) ->
    Vue.set(@planet_metadata_by_id, planet_metadata.id, planet_metadata) for planet_metadata in planets_metadata
    @notify_planets_metadata_listeners()

  metadata_for_id: (planet_id) -> @planet_metadata_by_id[planet_id]
