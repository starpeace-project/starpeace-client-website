
import moment from 'moment'

import EventListener from '~/plugins/starpeace-client/state/event-listener.coffee'

import CoreState from '~/plugins/starpeace-client/state/core/core-state.coffee'

import BookmarkState from '~/plugins/starpeace-client/state/player/bookmark-state.coffee'
import CorporationState from '~/plugins/starpeace-client/state/player/corporation-state.coffee'
import IdentityState from '~/plugins/starpeace-client/state/player/identity-state.coffee'
import PlanetState from '~/plugins/starpeace-client/state/player/planet-state.coffee'
import PlayerState from '~/plugins/starpeace-client/state/player/player-state.coffee'
import SessionState from '~/plugins/starpeace-client/state/player/session-state.coffee'

import CameraState from '~/plugins/starpeace-client/state/ui/camera-state.coffee'
import InterfaceState from '~/plugins/starpeace-client/state/ui/interface-state.coffee'
import MenuState from '~/plugins/starpeace-client/state/ui/menu-state.coffee'
import MusicState from '~/plugins/starpeace-client/state/ui/music-state.coffee'

import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

MAX_FAILED_AUTH_ERRORS = 3

export default class ClientState
  constructor: (@options, @ajax_state) ->
    @event_listener = new EventListener()

    @core = new CoreState()

    @bookmarks = new BookmarkState()
    @corporation = new CorporationState()
    @identity = new IdentityState()
    @session = new SessionState()
    @player = new PlayerState()
    @planet = new PlanetState()

    @camera = new CameraState()
    @interface = new InterfaceState(@options)
    @menu = new MenuState()
    @music = new MusicState()

    @reset_full_state()

    @core.corporation_cache.subscribe_corporation_metadata_listener => @update_state()
    @core.planets_cache.subscribe_planets_metadata_listener => @update_state()
    @core.systems_cache.subscribe_systems_metadata_listener => @update_state()
    @core.tycoon_cache.subscribe_tycoon_metadata_listener => @update_state()

    @core.building_library.subscribe_listener => @update_state()
    @core.concrete_library.subscribe_listener => @update_state()
    @core.effect_library.subscribe_listener => @update_state()
    @core.invention_library.subscribe_listener => @update_state()
    @core.land_library.subscribe_listener => @update_state()
    @core.map_library.subscribe_listener => @update_state()
    @core.news_library.subscribe_listener => @update_state()
    @core.overlay_library.subscribe_listener => @update_state()
    @core.plane_library.subscribe_listener => @update_state()
    @core.road_library.subscribe_listener => @update_state()
    @core.translations_library.subscribe_listener => @update_state()

    @bookmarks.subscribe_bookmarks_metadata_listener => @update_state()
    @corporation.subscribe_company_buildings_listener => @update_state()
    @corporation.subscribe_company_inventions_listener => @update_state()
    @identity.subscribe_visa_type_listener => @update_state()
    @identity.subscribe_identity_listener => @update_state()
    @session.subscribe_session_token_listener => @update_state()
    @player.subscribe_system_id_listener => @update_state()
    @player.subscribe_planet_id_listener => @update_state()
    @player.subscribe_corporation_id_listener => @update_state()
    @player.subscribe_mail_metadata_listener => @update_state()
    @planet.subscribe_planet_details_listener => @update_state()

    # @event_listener.subscribe_corporation_metadata_listener(=> @notify_corporation_metadata_changed())

  subscribe_workflow_status_listener: (listener_callback) -> @event_listener.subscribe('workflow_status', listener_callback)
  notify_workflow_status_listeners: () -> @event_listener.notify_listeners('workflow_status')

  reset_full_state: () ->
    @webgl_warning = false
    @session_expired_warning = false

    @loading = false
    @workflow_status = 'initializing'

    @renderer_initialized = false
    @mini_map_renderer_initialized = false

    @ajax_state.reset_state()
    @core.corporation_cache.reset_state()
    @core.planets_cache.reset_state()
    @core.systems_cache.reset_state()
    @core.tycoon_cache.reset_state()

    @identity.reset_state()
    @session.reset_state()

    @reset_planet_state()

  reset_planet_state: () ->
    @initialized = false

    @plane_sprites = []

    @core.building_cache.reset_state()
    @core.company_cache.reset_state()

    @bookmarks.reset_state()
    @corporation.reset_state()
    @player.reset_state()
    @planet.reset_state()

    @camera.reset_state()
    @interface.reset_state()
    @menu.reset_state()
    @music.reset_state()

    @update_state()


  finish_initialization: () ->
    @initialized = true
    @update_state()

  update_state: () ->
    new_state = @determine_state()
    unless @workflow_status == new_state
      @workflow_status = new_state
      @notify_workflow_status_listeners()

  determine_state: () ->
    unless @initialized && @renderer_initialized && @mini_map_renderer_initialized
      return 'pending_visa_type' unless @identity.visa_type?
      return 'pending_identity' unless @identity.identity?
      return 'pending_session' unless @session.session_token?

      return 'pending_tycoon_metadata' if @state_needs_tycoon_metadata()
      return 'pending_system_metadata' if @state_needs_system_metadata()
      return 'pending_system' unless @player.system_id?
      return 'pending_planet' unless @player.planet_id?

      planet_metadata = @core.planets_cache.metadata_for_id(@player.planet_id)

      return 'pending_assets' unless @core.has_assets(@options.language(), planet_metadata.map_id, planet_metadata.planet_type)
      return 'pending_planet_details' unless @planet.has_data()
      return 'pending_player_data' if @state_needs_player_data()
      return 'pending_initialization'

    'ready'

  state_needs_tycoon_metadata: () -> @identity.identity.is_tycoon() && !@core.tycoon_cache.has_tycoon_metadata_fresh(@session.tycoon_id)
  state_needs_system_metadata: () -> !@core.systems_cache.has_systems_metadata_fresh()
  state_needs_player_data: () ->
    # console.log "#{@identity.identity.is_tycoon()} && #{@player.corporation_id?} && (#{!@player.has_data()} || #{!@corporation.has_data()} || #{!@bookmarks.has_data()})"
    @identity.identity.is_tycoon() && @player.corporation_id? && (!@player.has_data() || !@corporation.has_data() || !@bookmarks.has_data())


  has_session: () -> @session.session_token? && @ajax_state.invalid_session_counter < MAX_FAILED_AUTH_ERRORS
  handle_authorization_error: () ->
    if @ajax_state.invalid_session_as_of? && TimeUtils.within_minutes(@ajax_state.invalid_session_as_of, 5)
      @ajax_state.invalid_session_counter += 1
    else
      @ajax_state.invalid_session_counter = 1
    @ajax_state.invalid_session_as_of = moment()

    if @ajax_state.invalid_session_counter >= MAX_FAILED_AUTH_ERRORS && !@session_expired_warning
      @session_expired_warning = true
      setTimeout (=> @reset_full_state()), 3000


  reset_system: ->
    Logger.debug "resetting planetary system back to empty, will need to re-select"
    @player.system_id = null
    @update_state()

  change_planet_id: (planet_id) ->
    @initialized = false
    setTimeout(=>
      @reset_planet_state()

      planet_metadata = if planet_id?.length then @core.planets_cache.metadata_for_id(planet_id) else null
      if planet_metadata?
        @player.set_system_id(planet_metadata.system_id)
        @player.set_planet_id(planet_metadata.id)
    , 250)


  current_tycoon_metadata: () -> if @session.tycoon_id? then @core.tycoon_cache.metadata_for_id(@session.tycoon_id) else null
  current_system_metadata: () -> if @player.system_id? then @core.systems_cache.metadata_for_id(@player.system_id) else null
  current_planet_metadata: () -> if @player.planet_id? then @core.planets_cache.metadata_for_id(@player.planet_id) else null
  current_corporation_metadata: () -> if @player.corporation_id? then @core.corporation_cache.metadata_for_id(@player.corporation_id) else null
  current_company_metadata: () -> if @player.company_id? then @core.company_cache.metadata_for_id(@player.company_id) else null

  current_planet_details: () -> if @player.planet_id? && @planet.details? then @planet.details else null

  enabled_for_system_id: (system_id) ->
    system_metadata = @core.systems_cache.metadata_for_id(system_id)
    if system_metadata?.enabled? then system_metadata.enabled else false
  enabled_for_planet_id: (planet_id) ->
    planet_metadata = @core.planets_cache.metadata_for_id(planet_id)
    if planet_metadata?.enabled? then planet_metadata.enabled else false

  name_for_system_id: (system_id) -> @core.systems_cache.metadata_for_id(system_id)?.name
  name_for_planet_id: (planet_id) -> @core.planets_cache.metadata_for_id(planet_id)?.name
  name_for_tycoon_id: (tycoon_id) -> @core.tycoon_cache.metadata_for_id(tycoon_id)?.name
  name_for_corporation_id: (corporation_id) -> @core.corporation_cache.metadata_for_id(corporation_id)?.name

  seal_for_company_id: (company_id) -> @core.company_cache.metadata_for_id(company_id)?.seal_id || 'NONE'
  name_for_company_id: (company_id) -> @core.company_cache.metadata_for_id(company_id)?.name || ''

  selected_building_metadata: () -> if @interface.selected_building_id?.length then @core.building_cache.building_metadata_for_id(@interface.selected_building_id) else null

  inventions_for_company: ->
    if @identity?.identity?.is_tycoon()
      company_metadata = @current_company_metadata()
      if company_metadata? then @core.invention_library.metadata_for_seal_id(company_metadata.seal_id) else []
    else
      @core.invention_library.all_metadata()
