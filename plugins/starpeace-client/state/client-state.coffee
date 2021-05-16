
import moment from 'moment'

import EventListener from '~/plugins/starpeace-client/state/event-listener.coffee'

import CoreState from '~/plugins/starpeace-client/state/core/core-state.coffee'

import BookmarkState from '~/plugins/starpeace-client/state/player/bookmark-state.coffee'
import CorporationState from '~/plugins/starpeace-client/state/player/corporation-state.coffee'
import IdentityState from '~/plugins/starpeace-client/state/player/identity-state.coffee'
import PlanetState from '~/plugins/starpeace-client/state/player/planet-state.coffee'
import PlayerState from '~/plugins/starpeace-client/state/player/player-state.coffee'

import CameraState from '~/plugins/starpeace-client/state/ui/camera-state.coffee'
import InterfaceState from '~/plugins/starpeace-client/state/ui/interface-state.coffee'
import MenuState from '~/plugins/starpeace-client/state/ui/menu-state.coffee'
import MusicState from '~/plugins/starpeace-client/state/ui/music-state.coffee'

import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'
import Utils from '~/plugins/starpeace-client/utils/utils.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

MAX_FAILED_AUTH_ERRORS = 3
MAX_FAILED_CONNECTION_ERRORS = 3

export default class ClientState
  constructor: (@options, @ajax_state) ->
    @event_listener = new EventListener()

    @core = new CoreState()

    @bookmarks = new BookmarkState()
    @corporation = new CorporationState()
    @identity = new IdentityState()
    @player = new PlayerState()
    @planet = new PlanetState()

    @camera = new CameraState()
    @interface = new InterfaceState(@options)
    @menu = new MenuState()
    @music = new MusicState()

    @reset_full_state()

    @core.corporation_cache.subscribe_corporation_metadata_listener => @update_state()
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
    @core.sign_library.subscribe_listener => @update_state()

    @bookmarks.subscribe_bookmarks_metadata_listener => @update_state()
    @corporation.subscribe_company_ids_listener => @update_state()
    @corporation.subscribe_cashflow_listener => @update_state()
    @corporation.subscribe_company_buildings_listener => @update_state()
    @corporation.subscribe_company_inventions_listener => @update_state()
    @identity.subscribe_visa_type_listener => @update_state()
    @planet.subscribe_state_listener => @update_state()
    @planet.subscribe_towns_listener => @update_state()
    @planet.subscribe_tycoons_online_listener => @update_state()
    @player.subscribe_planet_visa_type_listener => @update_state()
    @player.subscribe_planet_visa_id_listener => @update_state()
    @player.subscribe_corporation_id_listener => @update_state()
    @player.subscribe_mail_listener => @update_state()

  subscribe_workflow_status_listener: (listener_callback) -> @event_listener.subscribe('workflow_status', listener_callback)
  notify_workflow_status_listeners: () -> @event_listener.notify_listeners('workflow_status')

  reset_full_state: () ->
    @webgl_warning = false
    @session_expired_warning = false
    @server_connection_warning = false

    @loading = false
    @workflow_status = 'initializing'

    @renderer_initialized = false
    @mini_map_renderer_initialized = false
    @construction_preview_renderer_initialized = false
    @inspect_preview_renderer_initialized = false

    @ajax_state.reset_state()

    @core.reset_multiverse()
    @core.reset_planet()
    @core.galaxy_cache.load_galaxy_configuration(galaxy.id, galaxy) for galaxy in @options.get_galaxies()

    @identity.reset_state()

    @reset_planet_state()

  reset_planet_state: () ->
    @initialized = false

    @recent_system_messages = []
    @older_system_messages = []
    @system_message_callback = null

    @plane_sprites = []

    @core.reset_planet()

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
      @add_login_event() if new_state == 'ready'
      @workflow_status = new_state
      @notify_workflow_status_listeners()

  determine_state: () ->
    unless @initialized && @renderer_initialized && @mini_map_renderer_initialized && @construction_preview_renderer_initialized && @inspect_preview_renderer_initialized
      return 'pending_universe' unless @identity.galaxy_id? || @identity.galaxy_visa_type?

      planet_metadata = @current_planet_metadata()
      return 'pending_planet' unless planet_metadata?
      return 'pending_visa' unless @player.planet_visa_id?
      return 'pending_planet_details' unless @planet.has_data() && @core.has_metadata()
      return 'pending_player_data' if @state_needs_player_data()
      return 'pending_assets' unless @core.has_assets(@options.language(), planet_metadata.map_id, planet_metadata.planet_type)
      return 'pending_initialization'

    'ready'

  state_needs_player_data: () -> @is_tycoon() && @player.corporation_id? && (!@player.has_data() || !@corporation.has_data() || !@bookmarks.has_data())


  has_session: () -> @player.planet_visa_id? && @ajax_state.invalid_connection_counter < MAX_FAILED_CONNECTION_ERRORS && @ajax_state.invalid_session_counter < MAX_FAILED_AUTH_ERRORS
  handle_authorization_error: () ->
    if @ajax_state.invalid_session_as_of? && TimeUtils.within_minutes(@ajax_state.invalid_session_as_of, 5)
      @ajax_state.invalid_session_counter += 1
    else
      @ajax_state.invalid_session_counter = 1
    @ajax_state.invalid_session_as_of = moment()

    if @ajax_state.invalid_session_counter >= MAX_FAILED_AUTH_ERRORS && !@session_expired_warning
      @session_expired_warning = true
      setTimeout (=> @reset_full_state()), 5000
  handle_connection_error: () ->
    if @ajax_state.invalid_connection_as_of? && TimeUtils.within_minutes(@ajax_state.invalid_connection_as_of, 5)
      @ajax_state.invalid_connection_counter += 1
    else
      @ajax_state.invalid_connection_counter = 1
    @ajax_state.invalid_connection_as_of = moment()

    if @ajax_state.invalid_connection_counter >= MAX_FAILED_CONNECTION_ERRORS && !@server_connection_warning
      @server_connection_warning = true
      setTimeout (=> @reset_full_state()), 5000

  reset_to_galaxy: () ->
    setTimeout(=>
      @initialized = false
      @reset_planet_state()
    , 250)

  change_planet_id: (new_planet_visa_type, planet_id) ->
    @initialized = false
    setTimeout(=>
      @reset_planet_state()
      @player.set_planet_visa_type(planet_id, new_planet_visa_type)
    , 250)


  add_error_message: (message, err) ->
    Logger.warn(message)
    console.error(err) if err?
    @add_system_message(message)
  add_system_message: (message) ->
    @recent_system_messages.unshift { time: moment(), message }
    @system_message_callback = setTimeout((=> @poll_system_messages()), 1000) unless @system_message_callback
  poll_system_messages: () ->
    cutoff = moment().subtract(5, 'seconds')
    while @recent_system_messages.length && @recent_system_messages[@recent_system_messages.length - 1].time.isBefore(cutoff)
      @older_system_messages.unshift @recent_system_messages.splice(@recent_system_messages.length - 1, 1)[0]
    @system_message_callback = if @recent_system_messages.length then setTimeout((=> @poll_system_messages()), 1000) else null


  add_login_event: () ->
    name = if @is_tycoon() then @identity?.galaxy_tycoon?.name else 'Visitor'
    corporation_name = if @is_tycoon() then @current_corporation_metadata()?.name else null
    full_name = if corporation_name?.length then "#{name} of #{corporation_name}" else name
    @add_system_message("#{full_name} has entered #{@current_planet_metadata()?.name}")

  is_galaxy_tycoon: () -> @identity.galaxy_visa_type == 'tycoon'
  is_tycoon: () -> @is_galaxy_tycoon() && @player.planet_visa_type == 'tycoon' && @identity.galaxy_tycoon?

  current_planet_metadata: () -> if @player.planet_id? then @core.galaxy_cache.planet_metadata_for_id(@player.planet_id) else null
  current_corporation_metadata: () -> if @player.corporation_id? then @core.corporation_cache.metadata_for_id(@player.corporation_id) else null
  current_company_metadata: () -> if @player.company_id? then @core.company_cache.metadata_for_id(@player.company_id) else null

  current_location: () ->
    return null unless @initialized && @workflow_status == 'ready'
    center = @camera.center()
    @camera.map_to_iso(center.x, center.y)

  current_planet_details: () -> if @player.planet_id? && @planet.details? then @planet.details else null

  name_for_planet_id: (planet_id) -> @core.galaxy_cache.planet_metadata_for_id(planet_id)?.name
  name_for_tycoon_id: (tycoon_id) -> @core.tycoon_cache.metadata_for_id(tycoon_id)?.name
  name_for_corporation_id: (corporation_id) -> @core.corporation_cache.metadata_for_id(corporation_id)?.name

  seal_for_company_id: (company_id) -> @core.company_cache.metadata_for_id(company_id)?.seal_id || 'NONE'
  name_for_company_id: (company_id) -> @core.company_cache.metadata_for_id(company_id)?.name || ''

  town_for_location: () ->
    location = @current_location()
    return null unless location?
    @planet.town_for_color(@planet.game_map.town_color_at(location.i, location.j))

  selected_building: () -> if @interface.selected_building_id?.length then @core.building_cache.building_for_id(@interface.selected_building_id) else null

  inventions_for_company: ->
    if @is_tycoon()
      company_metadata = @current_company_metadata()
      if company_metadata? then @core.invention_library.metadata_for_seal_id(company_metadata.seal_id) else []
    else
      @core.invention_library.all_metadata()

  building_count_for_company: (building_definition_id) ->
    count = 0
    if @is_tycoon() && @player.company_id?.length
      for id in @corporation.building_ids_for_company(@player.company_id)
        building = @core.building_cache.building_for_id(id)
        count += 1 if building?.definition_id == building_definition_id
      count
    count


  matches_jump_history: (map_x, map_y) ->
    return false unless @interface.location_index >= 0 && @interface.location_index < @interface.location_history.length
    @interface.location_history[@interface.location_index].map_x == map_x && @interface.location_history[@interface.location_index].map_y == map_y

  add_jump_history: (map_x, map_y, building_id) ->
    @interface.location_history.unshift { map_x, map_y, building_id }
    @interface.location_history.pop() if @interface.location_history.length > 5

  jump_back: () ->
    location = @current_location()
    matches_back = @matches_jump_history(location.i, location.j)
    return unless @interface.location_index < @interface.location_history.length - 1 || !matches_back
    @interface.location_index++ if matches_back
    history = @interface.location_history[@interface.location_index]
    @jump_to(history.map_x, history.map_y, history.building_id, false)
  jump_next: () ->
    return unless @interface.location_index > 0
    @interface.location_index--
    history = @interface.location_history[@interface.location_index]
    @jump_to(history.map_x, history.map_y, history.building_id, false)

  jump_to: (map_x, map_y, building_id, with_history=true) ->
    if with_history
      location = @current_location()
      if @interface.location_index > 0
        @interface.location_history.splice(0, @interface.location_index)
        @interface.location_index = 0

      @add_jump_history(location.i, location.j, @interface.selected_building_id) unless @matches_jump_history(location.i, location.j)
      @add_jump_history(map_x, map_y, building_id) unless @matches_jump_history(map_x, map_y)

    @menu.hide_menu('body')
    @interface.select_building_id(building_id) if building_id?
    @camera.recenter_at(map_x, map_y) if map_x? && map_y?


  has_construction_requirements: (building_id) ->
    return false unless @player.company_id? && building_id?

    metadata = @core.building_library.definition_for_id(building_id)
    return false unless metadata?

    completed_invention_ids = @corporation.completed_invention_ids_for_company(@player.company_id)
    for id in (metadata.required_invention_ids || [])
      return false unless completed_invention_ids.indexOf(id) >= 0

    corporation = if @player.corporation_id? then @core.corporation_cache.metadata_for_id(@player.corporation_id) else null
    return false unless corporation?

    (corporation.cash || 0) >= 0 # FIXME: TODO: metadata.cost()

  can_construct_building: () ->
    return false unless @has_construction_requirements(@interface.construction_building_id)
    @planet.can_place_building(@interface.construction_building_map_x, @interface.construction_building_map_y, @interface.construction_building_city_zone_id, @interface.construction_building_width, @interface.construction_building_height)

  initiate_building_construction: (building_id) ->
    view_center = @camera.center()
    iso_start = @camera.map_to_iso(view_center.x, view_center.y)

    metadata = @core.building_library.metadata_by_id[building_id]
    image_metadata = if metadata? then @core.building_library.images_by_id[metadata.image_id] else null

    @interface.construction_building_id = building_id
    @interface.construction_building_map_x = iso_start.i
    @interface.construction_building_map_y = iso_start.j
    @interface.construction_building_city_zone_id = metadata.city_zone_id
    @interface.construction_building_width = if image_metadata? then image_metadata.w else 1
    @interface.construction_building_height = if image_metadata? then image_metadata.h else 1

    @interface.toggle_zones() unless @interface.show_zones


  show_politics: (town_id) ->
    @menu.toggle_menu('politics') unless @menu.is_visible('politics')
    @interface.select_politics_mayor(town_id)

  show_tycoon_profile: (tycoon_id) ->
    @interface.selected_tycoon_id = tycoon_id
    @menu.toggle_menu('tycoon') unless @menu.is_visible('tycoon')

  has_new_mail: () ->
    @player.corporation_id && @corporation.last_mail_at? && (!@player.last_mail_at? || @corporation.last_mail_at > @player.last_mail_at) && !@ajax_state.is_locked('mail_metadata', @player.corporation_id)
  send_mail: (tycoon_id, tycoon_name, corporation_id) ->
    @menu.toggle_menu('mail') unless @menu.is_visible('mail')
    @player.mail_compose_mode = true
    @player.mail_compose_to = "#{@player.mail_compose_to}#{(if _.trim(@player.mail_compose_to).length then '; ' else '')}#{tycoon_name}"
