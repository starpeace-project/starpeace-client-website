
import moment from 'moment'

import CommonMetadata from '~/plugins/starpeace-client/state/common-metadata.coffee'
import SessinState from '~/plugins/starpeace-client/state/session-state.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class GameState
  constructor: () ->
    @initialized = false
    @loading = false
    @has_assets = false
    @has_planet_details = false
    @has_player_metadata = false

    @ajax_requests = 0

    @common_metadata = new CommonMetadata(@)
    @session_state = new SessinState(@) # FIXME: TODO: consider loading state from url parameters (planet_id)

    @game_music_playing = false
    @game_music_volume = true

    @view_offset_x = 3600
    @view_offset_y = 4250

    @game_scale = 0.75
    @game_map = null

    @current_date = null
    @current_season = null

    @selected_building_id = null
    @selected_corporation_id = null

    @inventions_selected_category = 'SERVICE'
    @inventions_selected_industry_type = 'GENERAL'
    @inventions_selected_invention_id = ''
    @inventions_hover_invention_id = ''

  start_ajax: () -> @ajax_requests += 1
  finish_ajax: () -> @ajax_requests -= 1

  verify_corporation: (corporation_id) ->
    return false if @session_state.corporation_id == corporation_id
    console.log "corporation state is invalid, client should reset" # FIXME: TODO: add reset
    return true

  current_system_metadata: () -> if @session_state.system_id? then @common_metadata.systems_metadata_by_id[@session_state.system_id] else null
  current_planet_metadata: () -> if @session_state.planet_id? then @common_metadata.planets_metadata_by_id[@session_state.planet_id] else null
  current_company_metadata: () -> if @session_state.company_id? then @session_state.corporation_company_metadata_by_id[@session_state.company_id] else null

  is_refreshing_planets_metadata_for_current_system: () -> if @session_state.system_id? then @common_metadata.is_refreshing_planets_metadata_for_system_id(@session_state.system_id) else false
  has_planets_metadata_fresh_for_current_system: () -> if @session_state.system_id? then @common_metadata.has_planets_metadata_fresh_for_system_id(@session_state.system_id) else false

  enabled_for_system_id: (system_id) ->
    return @common_metadata.systems_metadata_by_id[system_id]?.enabled if @common_metadata.systems_metadata_by_id[system_id]?.enabled?
    false
  enabled_for_planet_id: (planet_id) ->
    return @common_metadata.planets_metadata_by_id[planet_id]?.enabled if @common_metadata.planets_metadata_by_id[planet_id]?.enabled?
    return @common_metadata.system_planets_metadata_by_id[planet_id]?.enabled if @common_metadata.system_planets_metadata_by_id[planet_id]?.enabled?
    false

  name_for_system_id: (system_id) -> @common_metadata.systems_metadata_by_id[system_id]?.name
  name_for_planet_id: (planet_id) -> @common_metadata.planets_metadata_by_id[planet_id]?.name || @common_metadata.system_planets_metadata_by_id[planet_id]?.name
  name_for_corporation_id: (corporation_id) -> @session_state.corporation_metadata?.name || @session_state.tycoon_corporation_metadata_by_id[corporation_id]?.name

  seal_for_company_id: (company_id) -> @session_state.corporation_company_metadata_by_id?[company_id]?.seal_id || 'NONE'
  name_for_company_id: (company_id) -> @session_state.corporation_company_metadata_by_id?[company_id]?.name || ''
