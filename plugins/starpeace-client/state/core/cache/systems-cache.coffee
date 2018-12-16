
import _ from 'lodash'
import moment from 'moment'
import Vue from 'vue'

import EventListener from '~/plugins/starpeace-client/state/event-listener.coffee'

import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class SystemCache
  constructor: () ->
    @event_listener = new EventListener()
    @reset_state()

  reset_state: () ->
    @system_metadata_as_of = null
    @system_metadata_by_id = {}

  subscribe_systems_metadata_listener: (listener_callback) -> @event_listener.subscribe('systems_cache.metadata', listener_callback)
  notify_systems_metadata_listeners: () -> @event_listener.notify_listeners('systems_cache.metadata')

  has_systems_metadata_any: () -> @system_metadata_as_of?
  has_systems_metadata_fresh: () -> @system_metadata_as_of? && TimeUtils.within_minutes(@system_metadata_as_of, 15)

  system_exists: (system_id) -> @system_metadata_by_id[system_id]?
  metadata_for_id: (system_id) -> @system_metadata_by_id[system_id]
  all_systems: () -> _.values(@system_metadata_by_id)

  set_systems_metadata: (systems_metadata) ->
    Vue.set(@system_metadata_by_id, system.id, system) for system in systems_metadata
    @system_metadata_as_of = moment()
    @notify_systems_metadata_listeners()
