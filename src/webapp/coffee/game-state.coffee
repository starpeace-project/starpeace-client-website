

window.starpeace ||= {}
window.starpeace.GameState = class GameState

  constructor: () ->
    @initialized = false
    @loading = false

    @view_offset_x = 3600
    @view_offset_y = 4250

    @game_scale = 1
