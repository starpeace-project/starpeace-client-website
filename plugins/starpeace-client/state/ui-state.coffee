
import Overlay from '~/plugins/starpeace-client/map/overlay.coffee'

class UIState
  constructor: () ->
    @event_ticker_message = ''

    @saved_show_header = @show_header = true
    @saved_show_fps = @show_fps = true

    @show_overlay = false
    @current_overlay = Overlay.TYPES.TOWNS
    @show_losing_facilities = false

    @show_zones = false

    @load_state()

  load_state: () ->
    @saved_show_header = @show_header = (localStorage.getItem('options.show_header') || 'true') == 'true'
    @saved_show_fps = @show_fps = (localStorage.getItem('options.show_fps') || 'true') == 'true'

  reset_state: () ->
    localStorage.removeItem('options.show_header')
    localStorage.removeItem('options.show_fps')
    @show_header = true
    @show_fps = true

  save_state: () ->
    localStorage.setItem('options.show_header', @show_header.toString())
    localStorage.setItem('options.show_fps', @show_fps.toString())
    @saved_show_header = @show_header
    @saved_show_fps = @show_fps

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

export default UIState
