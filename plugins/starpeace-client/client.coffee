
import Logger from '~/plugins/starpeace-client/logger.coffee'

import Managers from '~/plugins/starpeace-client/manager/managers.coffee'

import GameMap from '~/plugins/starpeace-client/map/game-map.coffee'

import EventListener from '~/plugins/starpeace-client/state/event-listener.coffee'
import GameState from '~/plugins/starpeace-client/state/game-state.coffee'
import MenuState from '~/plugins/starpeace-client/state/menu-state.coffee'
import Options from '~/plugins/starpeace-client/state/options.coffee'
import UIState from '~/plugins/starpeace-client/state/ui-state.coffee'

import MusicManager from '~/plugins/starpeace-client/sound/music-manager.coffee'

import MiniMapRenderer from '~/plugins/starpeace-client/renderer/mini-map-renderer.coffee'
import Renderer from '~/plugins/starpeace-client/renderer/renderer.coffee'
import CameraManager from '~/plugins/starpeace-client/renderer/camera/camera-manager.coffee'
import InputHandler from '~/plugins/starpeace-client/renderer/input/input-handler.coffee'

import Identity from '~/plugins/starpeace-client/identity/identity.coffee'
import APIClient from '~/plugins/starpeace-client/api/api-client.coffee'

export default class Client
  constructor: () ->
    @event_listener = new EventListener()
    @event_listener.subscribe_planet_details_listener(=> @notify_planet_details_changed())
    @event_listener.subscribe_corporation_metadata_listener(=> @notify_corporation_metadata_changed())
    @event_listener.subscribe_bookmarks_metadata_listener(=> @notify_player_metadata_changed())
    @event_listener.subscribe_mail_metadata_listener(=> @notify_player_metadata_changed())
    @event_listener.subscribe_company_metadata_listener(=> @notify_player_metadata_changed())
    @event_listener.subscribe_asset_listener(=> @notify_assets_changed())

    @options = new Options()
    @game_state = new GameState()
    @menu_state = new MenuState()
    @ui_state = new UIState(@options)

    @api = new APIClient()

    @managers = new Managers(@api, @event_listener, @options, @game_state, @ui_state)
    @music_manager = new MusicManager(@game_state)

    @renderer = new Renderer(@event_listener, @managers, @game_state, @options, @ui_state)
    @mini_map_renderer = new MiniMapRenderer(@event_listener, @managers, @renderer, @game_state, @options, @ui_state)
    @camera_manager = new CameraManager(@renderer, @game_state)
    @input_handler = new InputHandler(@game_state, @menu_state, @camera_manager, @renderer)

    @initialize_callback = null
    @refresh_events_interval = null

    Logger.banner()

  prepare_for_initialization: () ->
    clearTimeout(@refresh_events_interval) if @refresh_events_interval?

    @game_state.has_assets = false
    @game_state.has_planet_details = false
    @game_state.has_player_metadata = false
    @game_state.initialized = false

    @game_state.session_state.prepare_for_initialization()
    @menu_state.hide_all_menus()
    @event_listener.notify_asset_listeners()

  finish_initialization: () ->
    @game_state.loading = false

    clearTimeout(@refresh_events_interval) if @refresh_events_interval?
    @refresh_events_interval = setInterval(=>
      @managers.refresh_planet_events()
      @managers.refresh_corporation_events() if @game_state.session_state.corporation_id?.length
    , 5000)

  initialize_if_ready: () ->
    return unless !@game_state.initialized && @game_state.has_assets && @game_state.has_planet_details
    return if @game_state.session_state.identity.is_tycoon() && @game_state.session_state.corporation_id?.length && !@game_state.has_player_metadata

    planet = @game_state.current_planet_metadata()
    return unless planet?

    clearTimeout(@initialize_callback) if @initialize_callback
    @initialize_callback = setTimeout(=>
      @managers.initialize()

      @game_state.game_map = new GameMap(@event_listener, @managers.building_manager, @managers.road_manager, @managers.overlay_manager,
          @managers.land_manager.land_manifest_by_planet_type[planet.planet_type], @managers.land_manager.map_id_texture[planet.map_id], @options, @ui_state)

      @renderer.initialize()
      @input_handler.initialize()
      @mini_map_renderer.initialize()
      @game_state.initialized = true

      setTimeout (=> @finish_initialization()), 500
    , 500)

  notify_planet_details_changed: () ->
    return unless !@game_state.has_planet_details && @game_state.session_state.has_planet_details_fresh()

    @game_state.has_planet_details = true
    @initialize_if_ready()

  notify_assets_changed: () ->
    return unless @managers.has_assets()
    @game_state.has_assets = true
    @game_state.loading = true
    @initialize_if_ready()

  notify_player_metadata_changed: () ->
    return if @game_state.has_player_metadata || @game_state.initialized
    return unless @game_state.session_state.has_corporation_metadata_fresh() && @game_state.session_state.has_bookmarks_metadata_fresh() && @game_state.session_state.has_mail_metadata_fresh()
    for company in @game_state.session_state.corporation_metadata.companies
      return unless @game_state.session_state.has_buildings_metadata_any_for_id(company.id)
      return unless @game_state.session_state.has_inventions_metadata_any_for_id(company.id)

    @game_state.has_player_metadata = true
    @game_state.loading = true
    @initialize_if_ready()

  notify_corporation_metadata_changed: () ->
    return unless @game_state.session_state.corporation_id?.length

    if @game_state.session_state.corporation_metadata.companies?.length
      @game_state.session_state.company_id = _.sortBy(@game_state.session_state.corporation_metadata.companies, (company) -> company.name)[0].id

    promises = []
    for company in @game_state.session_state.corporation_metadata.companies
      unless @game_state.session_state.is_refreshing_buildings_metadata_for_id(company.id) || @game_state.session_state.has_buildings_metadata_any_for_id(company.id)
        promises.push @managers.building_manager.load_metadata(company.id)
      unless @game_state.session_state.is_refreshing_inventions_metadata_for_id(company.id) || @game_state.session_state.has_inventions_metadata_any_for_id(company.id)
        promises.push @managers.invention_manager.load_metadata(company.id)

    Promise.all promises
      .then ->
        Logger.debug 'loaded company metadata'
      .catch (err) ->
        # FIXME: TODO: add error handling
        console.log "problem loading companies #{err}"


  set_current_visa_type: (visa_type) ->
    @game_state.session_state.visa_type = visa_type
    @game_state.session_state.identity.reset_and_destroy() if @game_state.session_state.identity?
    @game_state.session_state.identity = null

  set_current_identity: (identity) ->
    @game_state.session_state.identity = identity

    Logger.debug "proceeding with identity <#{@game_state.session_state.identity}>, attempting to register session"
    @api.register_session(@game_state.session_state.identity)
      .then (session) =>
        @game_state.session_state.session_token = session.session_token
        @game_state.session_state.tycoon_id = session.tycoon_id if @game_state.session_state.identity.is_tycoon()
        Logger.debug "successfully retrieved session <#{@game_state.session_state.session_token}> for identity"

        @event_listener.notify_session_listeners()

      .catch (err) ->
        console.log "error registering session #{err}" # FIXME: TODO: figure out error handling


  proceed_as_visitor: () ->
    @set_current_visa_type('visitor')
    @set_current_identity(Identity.visitor())

  proceed_as_tycoon: () ->
    @set_current_visa_type('tycoon')
    Identity.mock_tycoon()
      .then (identity) =>
        @set_current_identity(identity)
      .catch (error) ->
        # FIXME: TODO: figure out error handling (failed to get auth_token from provider)

  reset_system: ->
    window.document.title = "STARPEACE" if window?.document?
    @game_state.session_state.system_id = null
    @game_state.session_state.planet_id = null
    @game_state.session_state.corporation_id = null
    @prepare_for_initialization()
    Logger.debug "resetting planetary system back to empty, will need to re-select"

    @managers.refresh_systems_metadata() unless @game_state.common_metadata.has_systems_metadata_fresh()

  select_system_id: (system_id) ->
    throw "unknown system id <#{system_id}>" unless @game_state.common_metadata.systems_metadata_by_id[system_id]?

    @game_state.session_state.system_id = system_id
    window.document.title = "#{@game_state.common_metadata.systems_metadata_by_id[system_id]?.name} - STARPEACE" if window?.document?
    Logger.debug "proceeding with planetary system <#{system_id}>"

    @event_listener.notify_system_listeners()

  select_planet_id: (planet_id) ->
    throw "unknown planet id <#{planet_id}>" unless @game_state.common_metadata.planets_metadata_by_id[planet_id]?

    @game_state.session_state.planet_id = planet_id
    @game_state.session_state.corporation_id = null
    window.document.title = "#{@game_state.common_metadata.planets_metadata_by_id[planet_id].name} - STARPEACE" if window?.document?
    Logger.debug "proceeding with planet <#{planet_id}>"

    @prepare_for_initialization()
    @event_listener.notify_planet_listeners()

  select_corporation: (corporation) ->
    @game_state.session_state.system_id = corporation.system_id
    @game_state.session_state.planet_id = corporation.planet_id
    @game_state.session_state.corporation_id = corporation.id

    window.document.title = "#{@game_state.name_for_planet_id(corporation.planet_id)} - STARPEACE" if window?.document?
    Logger.debug "proceeding with corporation <#{corporation.id}>"

    @prepare_for_initialization()
    @event_listener.notify_system_listeners()
    @event_listener.notify_planet_listeners()
    @event_listener.notify_corporation_listeners()


  tick: () ->
    @renderer.tick() if @renderer.initialized
    @mini_map_renderer.tick() if @mini_map_renderer.initialized
