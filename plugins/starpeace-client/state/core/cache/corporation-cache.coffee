
import moment from 'moment'
import Vue from 'vue'

import Cache from '~/plugins/starpeace-client/state/core/cache/cache.coffee'
import Corporation from '~/plugins/starpeace-client/corporation/corporation.coffee'

import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class CorporationCache extends Cache
  constructor: () ->
    super()

  reset_multiverse: () ->
    @corporation_metadata_by_id = {}

  subscribe_corporation_metadata_listener: (listener_callback) -> @event_listener.subscribe('corporation_cache.metadata', listener_callback)
  notify_corporation_metadata_listeners: () -> @event_listener.notify_listeners('corporation_cache.metadata')

  has_corporation_metadata_fresh: (corporation_id) -> @corporation_metadata_by_id[corporation_id]?.is_fresh() || false
  load_corporation_metadata: (corporations) ->
    if corporations instanceof Corporation
      Vue.set(@corporation_metadata_by_id, corporations.id, corporations)
    else if Array.isArray(corporations)
      Vue.set(@corporation_metadata_by_id, metadata.id, metadata) for metadata in corporations
    @notify_corporation_metadata_listeners()

  metadata_for_id: (corporation_id) -> @corporation_metadata_by_id[corporation_id]
  corporation_metadata_for_planet_tycoon_id: (planet_id, tycoon_id) ->
    _.find(_.values(@corporation_metadata_by_id), (corporation) -> corporation.planet_id == planet_id && corporation.tycoon_id == tycoon_id)

  corporations_for_tycoon_id: (tycoon_id) ->
    _.filter(_.values(@corporation_metadata_by_id), (corporation) -> corporation.tycoon_id == tycoon_id)

  add_corporation_company: (corporationId, company) ->
    @corporation_metadata_by_id[corporationId].companies.push(company) if @corporation_metadata_by_id[corporationId]?
