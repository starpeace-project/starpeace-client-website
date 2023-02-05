import TinyCache from 'tinycache';
import { markRaw } from 'vue';

import Cache from '~/plugins/starpeace-client/state/core/cache/cache.coffee'
import Corporation from '~/plugins/starpeace-client/corporation/corporation.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class CorporationCache extends Cache
  constructor: () ->
    super()
    @corporation_metadata_by_id = markRaw(new TinyCache())
    @corporations_by_tycoon_id = markRaw(new TinyCache())

    # Object.defineProperty(@, 'corporation_metadata_by_id', { configurable: false }) # disable Vue.observable
    # Object.defineProperty(@, 'corporations_by_tycoon_id', { configurable: false }) # disable Vue.observable

  reset_multiverse: () ->
    @corporation_metadata_by_id.clear()
    @corporations_by_tycoon_id.clear()

  subscribe_corporation_metadata_listener: (listener_callback) -> @event_listener.subscribe('corporation_cache.metadata', listener_callback)
  notify_corporation_metadata_listeners: () -> @event_listener.notify_listeners('corporation_cache.metadata')

  metadata_for_id: (corporation_id) -> @corporation_metadata_by_id.get(corporation_id)
  load_corporation: (corporation) ->
    @corporation_metadata_by_id.put(corporation.id, corporation, Cache.FIVE_MINUTES)
    @notify_corporation_metadata_listeners()

  corporations_for_tycoon_id: (tycoon_id) -> @corporations_by_tycoon_id.get(tycoon_id)
  load_tycoon_corporations: (tycoon_id, corporations) ->
    @corporations_by_tycoon_id.put(tycoon_id, corporations)
    @corporation_metadata_by_id.put(corporation.id, corporation, Cache.FIVE_MINUTES) for corporation in corporations
    @notify_corporation_metadata_listeners()


  add_corporation_company: (corporation_id, company) ->
    @corporation_metadata_by_id.get(corporation_id).companies.push(company) if @corporation_metadata_by_id.get(corporation_id)?
