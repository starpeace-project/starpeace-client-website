
import moment from 'moment'
import Vue from 'vue'

import EventListener from '~/plugins/starpeace-client/state/event-listener.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class CorporationState
  constructor: () ->
    @event_listener = new EventListener()
    @reset_state()

  reset_state: () ->
    @events_as_of = null

    @company_ids = []
    @details_as_of = null

    @buildings_ids_by_company_id = {}
    @inventions_metadata_by_company_id = {}

  has_data: () ->
    return false unless @details_as_of?
    for company_id in @company_ids
      return false unless @buildings_ids_by_company_id[company_id]? && @inventions_metadata_by_company_id[company_id]?
    true

  subscribe_company_buildings_listener: (listener_callback) -> @event_listener.subscribe('corporation.company_buildings', listener_callback)
  notify_company_buildings_listeners: () -> @event_listener.notify_listeners('corporation.company_buildings')
  subscribe_company_inventions_listener: (listener_callback) -> @event_listener.subscribe('corporation.company_inventions', listener_callback)
  notify_company_inventions_listeners: () -> @event_listener.notify_listeners('corporation.company_inventions')

  set_company_ids: (company_ids) ->
    @company_ids = company_ids if Array.isArray(company_ids)

  building_ids_for_company: (company_id) -> @buildings_ids_by_company_id[company_id] || []
  set_company_building_ids: (company_id, building_ids) ->
    Vue.set(@buildings_ids_by_company_id, company_id, building_ids)
    @notify_company_buildings_listeners()

  set_company_inventions_metadata: (company_id, inventions_metadata) ->
    Vue.set(@inventions_metadata_by_company_id, company_id, inventions_metadata)
    @notify_company_inventions_listeners()
