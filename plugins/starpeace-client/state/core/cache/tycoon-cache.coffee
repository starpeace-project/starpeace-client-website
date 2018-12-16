
import moment from 'moment'
import Vue from 'vue'

import EventListener from '~/plugins/starpeace-client/state/event-listener.coffee'
import MetadataTycoon from '~/plugins/starpeace-client/tycoon/metadata-tycoon.coffee'

import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class TycoonCache
  constructor: () ->
    @event_listener = new EventListener()
    @reset_state()

  reset_state: () ->
    @tycoon_metadata_by_id = {}

  subscribe_tycoon_metadata_listener: (listener_callback) -> @event_listener.subscribe('tycoon_cache.metadata', listener_callback)
  notify_tycoon_metadata_listeners: () -> @event_listener.notify_listeners('tycoon_cache.metadata')

  has_tycoon_metadata_fresh: (tycoon_id) -> if @tycoon_metadata_by_id[tycoon_id]? then @tycoon_metadata_by_id[tycoon_id]?.is_fresh() else false

  set_tycoon_metadata: (tycoon_metadata) ->
    unless tycoon_metadata instanceof MetadataTycoon
      Logger.debug "client misconfiguration, object is not expected MetadataTycoon"
      return

    Vue.set(@tycoon_metadata_by_id, tycoon_metadata.id, tycoon_metadata)
    @notify_tycoon_metadata_listeners()

  metadata_for_id: (tycoon_id) -> @tycoon_metadata_by_id[tycoon_id]
