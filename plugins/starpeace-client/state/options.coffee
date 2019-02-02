
import EventListener from '~/plugins/starpeace-client/state/event-listener.coffee'
import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

LANGUAGES = ['DE', 'EN', 'ES', 'FR', 'IT', 'PT']
LANGUAGE_FROM_CODE = (code) ->
  return 'EN' unless code?
  code = code.split('-')[0].toUpperCase() if code.indexOf('-') >= 0
  if LANGUAGES.indexOf(code) >= 0 then code else 'EN'

DEFAULT_LANGAUGE = 'EN'
DEFAULT_LANGUAGE = LANGUAGE_FROM_CODE(window?.navigator?.userLanguage || window?.navigator?.language)

OPTIONS = [
  {name: 'general.show_header', _default: true},
  {name: 'general.show_fps', _default: true},
  {name: 'general.show_mini_map', _default: true},
  {name: 'general.language', _default: DEFAULT_LANGAUGE},

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
  {name: 'bookmarks.capital', _default: true},
  {name: 'bookmarks.towns', _default: true},
  {name: 'bookmarks.mausoleums', _default: true},
  {name: 'bookmarks.corporation', _default: true}
]

export default class Options
  constructor: () ->
    @event_listener = new EventListener()

    @options_saved = {}
    @options_current = {}

    @galaxies = @load_galaxies_from_storage()

    @load_state()


  subscribe_galaxies_listener: (listener_callback) -> @event_listener.subscribe('options.galaxies', listener_callback)
  notify_galaxies_listeners: () -> @event_listener.notify_listeners('options.galaxies')
  subscribe_options_listener: (listener_callback) -> @event_listener.subscribe('options', listener_callback)
  notify_options_listeners: () -> @event_listener.notify_listeners('options')

  load_galaxies_from_storage: () ->
    galaxies = []
    raw_galaxies = JSON.parse(localStorage.getItem('galaxies') || "[]")
    if Array.isArray(raw_galaxies)
      for galaxy in raw_galaxies
        if Array.isArray(galaxy) && galaxy.length == 4
          galaxies.push {
            id: galaxy[0]
            api_protocol: galaxy[1]
            api_url: galaxy[2]
            api_port: galaxy[3]
          }
    unless galaxies.length
      galaxies.push {
        id: 'temporary-browser-sandbox'
        api_protocol: 'http'
        api_url: 'sandbox-galaxy.starpeace.io'
        api_port: 19160
      }
    galaxies
  save_galaxies_to_storage: () ->
    galaxies = []
    for galaxy in @galaxies
      galaxies.push [galaxy.id, galaxy.api_protocol, galaxy.api_url, galaxy.api_port]
    localStorage.setItem('galaxies', JSON.stringify(galaxies))
    @notify_galaxies_listeners()

  change_galaxy_id: (old_galaxy_id, new_galaxy_id) ->
    for galaxy in @galaxies
      galaxy.id = new_galaxy_id if galaxy.id == old_galaxy_id
    @save_galaxies_to_storage()
  add_galaxy: (api_protocol, api_url, api_port) ->
    galaxy = {
      id: Utils.uuid()
      api_protocol: api_protocol
      api_url: api_url
      api_port: api_port
    }
    @galaxies.push galaxy
    @save_galaxies_to_storage()
    galaxy
  remove_galaxy: (id) ->
    @galaxies = _.reject(@galaxies, (galaxy) -> galaxy.id == id)
    @save_galaxies_to_storage()

  get_galaxies: () -> @galaxies


  load_state: () ->
    for option in OPTIONS
      saved_value = localStorage.getItem(option.name)
      if saved_value?
        if (typeof option._default == 'number' && isFinite option._default)
          saved_value = parseInt(saved_value)
        else if typeof option._default is 'boolean'
          saved_value = saved_value == 'true'
      @options_saved[option.name] = @options_current[option.name] = if saved_value? then saved_value else option._default
    @notify_options_listeners()

  reset_state: () ->
    for option in OPTIONS
      localStorage.removeItem(option.name)
      @options_current[option.name] = option._default
    @notify_options_listeners()

  save_state: () ->
    for option in OPTIONS
      localStorage.setItem(option.name, @options_current[option.name].toString())
      @options_saved[option.name] = @options_current[option.name]
    @notify_options_listeners()

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

  language: () -> @options_current['general.language']
  set_language: (code) -> @set_and_save_option('general.language', if LANGUAGES.indexOf(code) >= 0 then code else 'EN')

  option: (name) ->
    @options_current[name]

  set_and_save_option: (name, value) ->
    @options_saved[name] = @options_current[name] = value
    localStorage.setItem(name, value.toString())
    @notify_options_listeners()

  toggle: (name) ->
    @options_current[name] = !@options_current[name]
    @notify_options_listeners()
