
import Overlay from '~/plugins/starpeace-client/map/types/overlay.coffee'

MINI_MAP_ZOOM_MAX = 2
MINI_MAP_ZOOM_MIN = .25
MINI_MAP_ZOOM_STEP = .25

export default class UIState
  constructor: (@options) ->
    @event_ticker_message = ''

    @show_overlay = false
    @current_overlay = Overlay.TYPES.TOWNS
    @show_losing_facilities = false

    @show_zones = false

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

  update_mini_map_zoom: (zoom_delta) ->
    before = @options.option('mini_map.zoom')
    zoom = Math.min(MINI_MAP_ZOOM_MAX, Math.max(MINI_MAP_ZOOM_MIN, before + zoom_delta))
    if zoom != before
      @options.set_and_save_option('mini_map.zoom', zoom)
      return true
    false

  update_mini_map: (width, height) ->
    @options.set_and_save_option('mini_map.width', width)
    @options.set_and_save_option('mini_map.height', height)
