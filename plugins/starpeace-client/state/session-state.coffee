
import moment from 'moment'
import Vue from 'vue'

import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class SessionState
  constructor: (@game_state) ->
    @visa_type = null
    @identity = null

    @session_token_request = null
    @session_token_as_of = null
    @session_token = null

    @tycoon_metadata_request = null
    @tycoon_metadata_as_of = null
    @tycoon_metadata = null
    @tycoon_corporation_metadata_by_id = {}

    @prepare_for_initialization()

    @system_id = null
    @planet_id = null

    @tycoon_id = null
    @corporation_id = null
    @company_id = null

    @state_counter = 0

  prepare_for_initialization: () ->
    @planet_details_request = null
    @planet_details_as_of = null
    @planet_details = null

    @corporation_metadata_request = null
    @corporation_metadata_as_of = null
    @corporation_metadata = null
    @corporation_company_metadata_by_id = {}

    @bookmarks_by_id_request = null
    @bookmarks_by_id_as_of = null
    @bookmarks_by_id = null

    @mail_by_id_request = null
    @mail_by_id_as_of = null
    @mail_by_id = null

    @buildings_metadata_by_company_id_request = {}
    @buildings_metadata_by_company_id_as_of = {}
    @buildings_metadata_by_company_id = {}

    @inventions_metadata_by_company_id_request = {}
    @inventions_metadata_by_company_id_as_of = {}
    @inventions_metadata_by_company_id = {}


  start_tycoon_metadata_request: () ->
    @tycoon_metadata_request = true
    @state_counter += 1
    @game_state.start_ajax()
  finish_tycoon_metadata_request: () ->
    @tycoon_metadata_request = null
    @state_counter += 1
    @game_state.finish_ajax()

  start_planet_details_request: () ->
    @planet_details_request = true
    @state_counter += 1
    @game_state.start_ajax()
  finish_planet_details_request: () ->
    @planet_details_request = null
    @state_counter += 1
    @game_state.finish_ajax()

  start_corporation_metadata_request: () ->
    @corporation_metadata_request = true
    @state_counter += 1
    @game_state.start_ajax()
  finish_corporation_metadata_request: () ->
    @corporation_metadata_request = null
    @state_counter += 1
    @game_state.finish_ajax()

  start_bookmarks_metadata_request: () ->
    @bookmarks_by_id_request = true
    @state_counter += 1
    @game_state.start_ajax()
  finish_bookmarks_metadata_request: () ->
    @bookmarks_by_id_request = null
    @state_counter += 1
    @game_state.finish_ajax()
  start_mail_metadata_request: () ->
    @mail_by_id_request = true
    @state_counter += 1
    @game_state.start_ajax()
  finish_mail_metadata_request: () ->
    @mail_by_id_request = null
    @state_counter += 1
    @game_state.finish_ajax()

  start_buildings_metadata_request: (company_id) ->
    @buildings_metadata_by_company_id_request[company_id] = true
    @state_counter += 1
    @game_state.start_ajax()
  finish_buildings_metadata_request: (company_id) ->
    @buildings_metadata_by_company_id_request[company_id] = null
    @state_counter += 1
    @game_state.finish_ajax()
  start_inventions_metadata_request: (company_id) ->
    @inventions_metadata_by_company_id_request[company_id] = true
    @state_counter += 1
    @game_state.start_ajax()
  finish_inventions_metadata_request: (company_id) ->
    @inventions_metadata_by_company_id_request[company_id] = null
    @state_counter += 1
    @game_state.finish_ajax()


  is_refreshing_tycoon_metadata: () -> @tycoon_metadata_request || false
  is_refreshing_planet_details: () -> @planet_details_request || false
  is_refreshing_corporation_metadata: () -> @corporation_metadata_request || false
  is_refreshing_bookmarks_metadata: () -> @bookmarks_by_id_request || false
  is_refreshing_mail_metadata: () -> @mail_by_id_request || false

  is_refreshing_buildings_metadata_for_id: (company_id) -> @buildings_metadata_by_company_id_request[company_id] || false
  is_refreshing_inventions_metadata_for_id: (company_id) -> @inventions_metadata_by_company_id_request[company_id] || false

  has_tycoon_metadata_fresh: () -> @tycoon_metadata_as_of? && TimeUtils.within_minutes(@tycoon_metadata_as_of, 15)
  has_planet_details_fresh: () -> @planet_details_as_of? && TimeUtils.within_minutes(@planet_details_as_of, 15)
  has_corporation_metadata_fresh: () -> @corporation_metadata_as_of? && TimeUtils.within_minutes(@corporation_metadata_as_of, 15)
  has_bookmarks_metadata_fresh: () -> @bookmarks_by_id_as_of? && TimeUtils.within_minutes(@bookmarks_by_id_as_of, 15)
  has_mail_metadata_fresh: () -> @mail_by_id_as_of? && TimeUtils.within_minutes(@mail_by_id_as_of, 15)

  has_buildings_metadata_any_for_id: (company_id) -> @buildings_metadata_by_company_id_as_of[company_id]?
  has_inventions_metadata_any_for_id: (company_id) -> @inventions_metadata_by_company_id_as_of[company_id]?


  set_tycoon_metadata: (tycoon_metadata) ->
    @tycoon_metadata = tycoon_metadata
    Vue.set(@tycoon_corporation_metadata_by_id, corporation.id, corporation) for corporation in (tycoon_metadata.corporations || [])
    @tycoon_metadata_as_of = moment()
    @state_counter += 1
  set_planet_details: (details) ->
    @planet_details = details
    @planet_details_as_of = moment()
    @state_counter += 1
  set_corporation_metadata: (corporation_metadata) ->
    @corporation_metadata = corporation_metadata
    Vue.set(@corporation_company_metadata_by_id, company.id, company) for company in (corporation_metadata.companies || [])
    @corporation_metadata_as_of = moment()
    @state_counter += 1

  set_bookmarks_metadata: (bookmarks_items) ->
    @bookmarks_by_id = {}
    Vue.set(@bookmarks_by_id, item.id, item) for item in (bookmarks_items || [])
    @bookmarks_by_id_as_of = moment()
    @state_counter += 1
  set_mail_metadata: (mail_metadata) ->
    @mail_by_id = {}
    Vue.set(@mail_by_id, item.id, item) for item in (mail_metadata || [])
    @mail_by_id_as_of = moment()
    @state_counter += 1

  set_buildings_metadata_for_id: (company_id, buildings_metadata) ->
    Vue.set(@buildings_metadata_by_company_id, company_id, buildings_metadata)
    @buildings_metadata_by_company_id_as_of[company_id] = moment()
    @state_counter += 1
  set_inventions_metadata_for_id: (company_id, inventions_metadata) ->
    Vue.set(@inventions_metadata_by_company_id, company_id, inventions_metadata)
    @inventions_metadata_by_company_id_as_of[company_id] = moment()
    @state_counter += 1

  corporation_metadata_for_system_and_planet_id: (system_id, planet_id) ->
    for corporation in (@tycoon_metadata?.corporations || [])
      return corporation if corporation.system_id == system_id && corporation.planet_id == planet_id
    null
