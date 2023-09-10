import { markRaw } from 'vue';

import Overlay from '~/plugins/starpeace-client/overlay/overlay.coffee'
import EventListener from '~/plugins/starpeace-client/state/event-listener'

MINI_MAP_ZOOM_MAX = 2
MINI_MAP_ZOOM_MIN = .25
MINI_MAP_ZOOM_STEP = .25

##
# state of client user interface (renderer or DOM)
##
export default class InterfaceState
  constructor: (@options) ->
    @event_listener = markRaw(new EventListener())
    @reset_state()

  reset_state: () ->
    @static_news_index = -1
    @event_ticker_message = '' # FIXME: TODO: move to better state class

    @remove_galaxy_visible = false
    @add_galaxy_visible = false

    @show_create_tycoon = false
    @create_tycoon_galaxy_id = null

    @show_overlay = false
    @current_overlay = Overlay.TYPES.TOWNS
    @show_losing_facilities = false

    @show_zones = false

    @is_mouse_primary_down = false
    @start_mouse_x = -1
    @start_mouse_y = -1
    @last_mouse_x = -1
    @last_mouse_y = -1

    @location_history = []
    @location_index = 0

    @show_inspect = false

    @selected_building_id = null

    @inventions_selected_category_id = 'SERVICE'
    @inventions_selected_industry_type_id = 'GENERAL'
    @inventions_selected_invention_id = null

    @construction_selected_category_id = null
    @construction_selected_building_id = null

    @construction_building_id = null
    @construction_building_map_x = 0
    @construction_building_map_y = 0
    @construction_building_city_zone_id = null
    @construction_building_width = 0
    @construction_building_height = 0

    @selected_tycoon_id = null

    @selected_politics_type = null
    @selected_politics_id = null

    @selected_ranking_type_id = null
    @selected_ranking_corporation_id = null

  subscribe_mini_map_zoom_listener: (listener_callback) -> @event_listener.subscribe('interface.mini_map_zoom', listener_callback)
  notify_mini_map_zoom_listeners: () -> @event_listener.notify_listeners('interface.mini_map_zoom')

  subscribe_mini_map_size_listener: (listener_callback) -> @event_listener.subscribe('interface.mini_map_size', listener_callback)
  notify_mini_map_size_listeners: () -> @event_listener.notify_listeners('interface.mini_map_size')

  subscribe_selected_ranking_type_id_listener: (listener_callback) -> @event_listener.subscribe('interface.selected_ranking_type_id', listener_callback)
  notify_selected_ranking_type_id_listeners: () -> @event_listener.notify_listeners('interface.selected_ranking_type_id')
  subscribe_selected_ranking_corporation_id_listener: (listener_callback) -> @event_listener.subscribe('interface.selected_ranking_corporation_id', listener_callback)
  notify_selected_ranking_corporation_id_listeners: () -> @event_listener.notify_listeners('interface.selected_ranking_corporation_id')

  show_add_galaxy: () -> @add_galaxy_visible = true
  hide_add_galaxy: () -> @add_galaxy_visible = false

  show_remove_galaxy: () -> @remove_galaxy_visible = true
  hide_remove_galaxy: () -> @remove_galaxy_visible = false

  toggle_overlay: () ->
    if @show_overlay
      @show_overlay = false
    else
      @show_zones = false
      @show_overlay = true

  toggle_zones: () ->
    if @show_zones
      @show_zones = false
    else
      @show_overlay = false
      @show_zones = true

  hide_inspect: () -> @show_inspect = false
  toggle_inspect: () -> @show_inspect = !@show_inspect

  mini_map_adjust_zoom: (zoom_delta) ->
    before = @options.option('mini_map.zoom')
    zoom = Math.min(MINI_MAP_ZOOM_MAX, Math.max(MINI_MAP_ZOOM_MIN, before + zoom_delta))
    if zoom != before
      @options.set_and_save_option('mini_map.zoom', zoom)
      @notify_mini_map_zoom_listeners()
      return true
    false
  mini_map_zoom_in: () -> @mini_map_adjust_zoom(MINI_MAP_ZOOM_STEP)
  mini_map_zoom_out: () -> @mini_map_adjust_zoom(-MINI_MAP_ZOOM_STEP)

  update_mini_map: (width, height) ->
    @options.set_and_save_option('mini_map.width', width)
    @options.set_and_save_option('mini_map.height', height)
    @notify_mini_map_size_listeners()

  toggle_building: (building_id) ->
    if building_id == @selected_building_id
      @unselect_building()
    else
      @selected_building_id = building_id
  select_and_inspect_building: (building_id) ->
    @selected_building_id = building_id
    @show_inspect = true
  unselect_building: () ->
    @selected_building_id = null
    @show_inspect = false
  select_building_id: (building_id) ->
    @selected_building_id = building_id

  select_ranking_type_id: (ranking_type_id) ->
    @selected_ranking_type_id = ranking_type_id
    @notify_selected_ranking_type_id_listeners()
  select_ranking_corporation_id: (corporation_id) ->
    @selected_ranking_corporation_id = corporation_id
    @notify_selected_ranking_corporation_id_listeners()
  toggle_ranking_corporation_id: (corporation_id) -> @select_ranking_corporation_id(if @selected_ranking_corporation_id == corporation_id then null else corporation_id)

  select_politics_president: (planet_id) -> @select_politics('PRESIDENT', planet_id)
  select_politics_mayor: (town_id) -> @select_politics('MAYOR', town_id)
  select_politics: (type, id) ->
    @selected_politics_type = type
    @selected_politics_id = id
  unselect_politics: () ->
    @selected_politics_type = null
    @selected_politics_id = null

  primary_mouse_down: (mouse_x, mouse_y) ->
    @is_moving = true
    @start_mouse_x = @last_mouse_x = mouse_x
    @start_mouse_y = @last_mouse_y = mouse_y
