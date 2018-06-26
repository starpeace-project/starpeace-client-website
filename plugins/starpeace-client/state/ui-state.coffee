
import Overlay from '~/plugins/starpeace-client/map/overlay.coffee'

class UIState
  constructor: () ->
    @event_ticker_message = ''

    @show_header = true
    @show_fps = true

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

export default UIState
