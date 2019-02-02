
import moment from 'moment'
import Vue from 'vue'

import EventListener from '~/plugins/starpeace-client/state/event-listener.coffee'
import MetadataCorporation from '~/plugins/starpeace-client/industry/metadata-corporation.coffee'

import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class CorporationCache
  constructor: () ->
    @event_listener = new EventListener()
    @reset_state()

  reset_state: () ->
    @corporation_metadata_by_id = {}

  subscribe_corporation_metadata_listener: (listener_callback) -> @event_listener.subscribe('corporation_cache.metadata', listener_callback)
  notify_corporation_metadata_listeners: () -> @event_listener.notify_listeners('corporation_cache.metadata')

  has_corporation_metadata_fresh: (corporation_id) -> @corporation_metadata_by_id[corporation_id]?.is_fresh() || false
  load_corporation_metadata: (corporation_metadata) ->
    if corporation_metadata instanceof MetadataCorporation
      Vue.set(@corporation_metadata_by_id, corporation_metadata.id, corporation_metadata)
    else if Array.isArray(corporation_metadata)
      Vue.set(@corporation_metadata_by_id, metadata.id, metadata) for metadata in corporation_metadata
    @notify_corporation_metadata_listeners()

  metadata_for_id: (corporation_id) -> @corporation_metadata_by_id[corporation_id]
  corporation_metadata_for_planet_tycoon_id: (planet_id, tycoon_id) ->
    _.find(_.values(@corporation_metadata_by_id), (corporation) -> corporation.planet_id == planet_id && corporation.tycoon_id == tycoon_id)

  corporations_for_tycoon_id: (tycoon_id) ->
    _.filter(_.values(@corporation_metadata_by_id), (corporation) -> corporation.tycoon_id == tycoon_id)

  update_corporation_cash: (corporation_id, cash, cashflow) ->
    if @corporation_metadata_by_id[corporation_id]?
      @corporation_metadata_by_id[corporation_id].cash = cash
      @corporation_metadata_by_id[corporation_id].cashflow = cashflow
