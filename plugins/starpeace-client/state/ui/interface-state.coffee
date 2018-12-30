
import Overlay from '~/plugins/starpeace-client/overlay/overlay.coffee'

import EventListener from '~/plugins/starpeace-client/state/event-listener.coffee'

MINI_MAP_ZOOM_MAX = 2
MINI_MAP_ZOOM_MIN = .25
MINI_MAP_ZOOM_STEP = .25

##
# state of client user interface (renderer or DOM)
##
export default class InterfaceState
  constructor: (@options) ->
    @event_listener = new EventListener()
    @reset_state()

  reset_state: () ->
    @static_news_index = -1
    @event_ticker_message = '' # FIXME: TODO: move to better state class

    @show_overlay = false
    @current_overlay = Overlay.TYPES.TOWNS
    @show_losing_facilities = false

    @show_zones = false

    @selected_building_id = null

    @systems_menu_selected_system_id = null

    @inventions_selected_category = 'SERVICE'
    @inventions_selected_industry_type = 'GENERAL'
    @inventions_selected_invention_id = ''
    @inventions_hover_invention_id = ''

    @construction_selected_category = null
    @construction_selected_building_id = null

  subscribe_mini_map_zoom_listener: (listener_callback) -> @event_listener.subscribe('interface.mini_map_zoom', listener_callback)
  notify_mini_map_zoom_listeners: () -> @event_listener.notify_listeners('interface.mini_map_zoom')

  subscribe_mini_map_size_listener: (listener_callback) -> @event_listener.subscribe('interface.mini_map_size', listener_callback)
  notify_mini_map_size_listeners: () -> @event_listener.notify_listeners('interface.mini_map_size')


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


  select_building_id: (building_id) ->
    @selected_building_id = building_id
