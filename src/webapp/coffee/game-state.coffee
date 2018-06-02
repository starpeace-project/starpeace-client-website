

window.starpeace ||= {}
window.starpeace.GameState = class GameState

  constructor: () ->
    @loading = false
    
  is_initialized: () ->
    false


  is_loading: () ->
    @loading
