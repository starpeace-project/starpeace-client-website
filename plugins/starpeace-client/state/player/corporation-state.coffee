import _ from 'lodash';

import EventListener from '~/plugins/starpeace-client/state/event-listener.coffee'
import CompanyInventions from '~/plugins/starpeace-client/invention/company-inventions'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class CorporationState
  constructor: () ->
    @event_listener = new EventListener()
    @company_ids = null

    @last_mail_at = null
    @cash = null
    @cashflow = null
    @cashflow_by_company_id = {}

    @buildings_ids_by_company_id = {}
    @inventions_metadata_by_company_id = {}

  reset_state: () ->
    @company_ids = null

    @last_mail_at = null
    @cash = null
    @cashflow = null
    @cashflow_by_company_id = {}

    @buildings_ids_by_company_id = {}
    @inventions_metadata_by_company_id = {}

  has_data: () ->
    return false unless @company_ids? && @cash? && @cashflow?
    for company_id in @company_ids
      return false unless @cashflow_by_company_id[company_id]? && @buildings_ids_by_company_id[company_id]? && @inventions_metadata_by_company_id[company_id]?
    true

  company_ids_with_pending_inventions: () -> _.filter(@company_ids, (id) => @inventions_metadata_by_company_id[id]?.isActive())
  completed_invention_ids_for_company: (company_id) -> Array.from(@inventions_metadata_by_company_id[company_id]?.completedIds || new Set())

  subscribe_company_ids_listener: (listener_callback) -> @event_listener.subscribe('corporation.company_ids', listener_callback)
  notify_company_ids_listeners: () -> @event_listener.notify_listeners('corporation.company_ids')
  subscribe_cashflow_listener: (listener_callback) -> @event_listener.subscribe('corporation.cashflow', listener_callback)
  notify_cashflow_listeners: () -> @event_listener.notify_listeners('corporation.cashflow')
  subscribe_company_buildings_listener: (listener_callback) -> @event_listener.subscribe('corporation.company_buildings', listener_callback)
  notify_company_buildings_listeners: () -> @event_listener.notify_listeners('corporation.company_buildings')
  subscribe_company_inventions_listener: (listener_callback) -> @event_listener.subscribe('corporation.company_inventions', listener_callback)
  notify_company_inventions_listeners: () -> @event_listener.notify_listeners('corporation.company_inventions')

  set_company_ids: (company_ids) ->
    @company_ids = if Array.isArray(company_ids) then company_ids else []
    @notify_company_ids_listeners()

  add_company_id: (company_id) ->
    @company_ids.push(company_id)
    @buildings_ids_by_company_id[company_id] = []
    @inventions_metadata_by_company_id[company_id] = CompanyInventions.create(company_id)
    @notify_company_ids_listeners()
    @notify_company_buildings_listeners()
    @notify_company_inventions_listeners()

  update_cashflow: (last_mail_at, cash, cashflow) ->
    @last_mail_at = last_mail_at
    @cash = cash
    @cashflow = cashflow
    @notify_cashflow_listeners()
  update_cashflow_companies: (companies) ->
    for company in (if Array.isArray(companies) then companies else [companies])
      @cashflow_by_company_id[company.id] = company.cashflow || 0
    @notify_cashflow_listeners()


  building_ids_for_company: (company_id) -> @buildings_ids_by_company_id[company_id] || []
  set_company_building_ids: (company_id, building_ids) ->
    @buildings_ids_by_company_id[company_id] = building_ids
    @notify_company_buildings_listeners()

  add_company_building_id: (company_id, building_id) ->
    @buildings_ids_by_company_id[company_id] = [] unless @buildings_ids_by_company_id[company_id]?
    @buildings_ids_by_company_id[company_id].push building_id
    @notify_company_buildings_listeners()

  update_company_inventions_metadata: (company_id, inventions_metadata) ->
    @inventions_metadata_by_company_id[company_id] = inventions_metadata
    @notify_company_inventions_listeners()
