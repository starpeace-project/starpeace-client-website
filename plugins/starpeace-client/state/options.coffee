
OPTIONS = [
  {name: 'general.show_header', _default: true},
  {name: 'general.show_fps', _default: true},
  {name: 'general.show_mini_map', _default: true},

  {name: 'music.show_game_music', _default: true},
  {name: 'music.volume_muted', _default: false},

  {name: 'mini_map.zoom', _default: 1},
  {name: 'mini_map.width', _default: 300},
  {name: 'mini_map.height', _default: 200},

  {name: 'renderer.trees', _default: true},
  {name: 'renderer.buildings', _default: true},
  {name: 'renderer.building_animations', _default: true},
  {name: 'renderer.building_effects', _default: true},
  {name: 'renderer.planes', _default: true},

  {name: 'bookmarks.points_of_interest', _default: true},
  {name: 'bookmarks.towns', _default: true},
  {name: 'bookmarks.mausoleums', _default: true},
  {name: 'bookmarks.corporation', _default: true}
]

export default class Options
  constructor: () ->
    @vue_state_counter = 0 # vue doesn't track state of maps, using version counter instead
    @options_saved = {}
    @options_current = {}

    @load_state()

  load_state: () ->
    for option in OPTIONS
      saved_value = localStorage.getItem(option.name)
      if saved_value?
        if (typeof option._default is 'number' and isFinite option._default)
          saved_value = parseInt(saved_value)
        else if typeof option._default is 'boolean'
          saved_value = saved_value == 'true'
      @options_saved[option.name] = @options_current[option.name] = if saved_value? then saved_value else option._default
    @vue_state_counter += 1

  reset_state: () ->
    for option in OPTIONS
      localStorage.removeItem(option.name)
      @options_current[option.name] = option._default
    @vue_state_counter += 1

  save_state: () ->
    for option in OPTIONS
      localStorage.setItem(option.name, @options_current[option.name].toString())
      @options_saved[option.name] = @options_current[option.name]
    @vue_state_counter += 1

  can_reset: () ->
    matches_default = true
    for option in OPTIONS
      matches_default = false unless @options_current[option.name] == option._default
    !matches_default

  is_dirty: ->
    matches_saved = true
    for option in OPTIONS
      matches_saved = false unless @options_current[option.name] == @options_saved[option.name]
    !matches_saved


  option: (name) ->
    @options_current[name]

  set_and_save_option: (name, value) ->
    @options_saved[name] = @options_current[name] = value
    localStorage.setItem(name, value.toString())
    @vue_state_counter += 1

  toggle: (name) ->
    @options_current[name] = !@options_current[name]
    @vue_state_counter += 1
