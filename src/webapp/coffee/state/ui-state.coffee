

window.starpeace ||= {}
window.starpeace.state ||= {}
window.starpeace.state.UIState = class UIState

  constructor: () ->
    @event_ticker_message = ''

    @show_header = true
    @show_fps = true

    @theme = 'mineral'

    @show_menu_favorites = false
    @main_menu = null

    @show_zones = false
