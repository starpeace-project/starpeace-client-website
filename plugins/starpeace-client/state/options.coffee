import _ from 'lodash'
import { reactive } from 'vue';

import EventListener from '~/plugins/starpeace-client/state/event-listener'
import Utils from '~/plugins/starpeace-client/utils/utils.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

LANGUAGES = ['DE', 'EN', 'ES', 'FR', 'IT', 'PT']
LANGUAGE_FROM_CODE = (code) ->
  return 'EN' unless code?
  code = code.split('-')[0].toUpperCase() if code.indexOf('-') >= 0
  if LANGUAGES.indexOf(code) >= 0 then code else 'EN'

DEFAULT_LANGAUGE = 'EN'
DEFAULT_LANGUAGE = LANGUAGE_FROM_CODE(window?.navigator?.userLanguage || window?.navigator?.language)

AUTH_GALAXY_HASH = 'galaxy.hash'
AUTH_GALAXY_JWT = 'galaxy.jwt'
AUTH_GALAXY_TOKEN = 'galaxy.token'

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

    @galaxies_by_id = @load_galaxies_from_storage()

    @galaxy_id = null
    @galaxy_jwt = null
    @galaxy_token = null

  initialize: () ->
    @load_authorization_state()
    @load_state()

  subscribe_galaxies_listener: (listener_callback) -> @event_listener.subscribe('options.galaxies', listener_callback)
  notify_galaxies_listeners: () -> @event_listener.notify_listeners('options.galaxies')
  subscribe_options_listener: (listener_callback) -> @event_listener.subscribe('options', listener_callback)
  notify_options_listeners: () -> @event_listener.notify_listeners('options')

  get_galaxies: () -> _.values(@galaxies_by_id)

  load_galaxies_from_storage: () ->
    galaxies_by_id = {}
    galaxies_by_id['browser-sandbox'] = {
      id: 'browser-sandbox'
      api_protocol: 'http'
      api_url: 'sandbox-galaxy.starpeace.io'
      api_port: 19160
    }

    raw_galaxies = JSON.parse(localStorage.getItem('galaxies') || "[]")
    if Array.isArray(raw_galaxies)
      for galaxy in raw_galaxies
        if Array.isArray(galaxy) && galaxy.length == 4 && galaxy[1]?.length && galaxy[2]?.length && galaxy[3]?.length
          id = galaxy[0] || Utils.uuid()
          if galaxies_by_id[id]?
            Logger.warn("duplicate galaxy in storage, will ignore") unless id == 'browser-sandbox'
          else
            galaxies_by_id[id] = {
              id: id
              api_protocol: galaxy[1]
              api_url: galaxy[2]
              api_port: galaxy[3]
            }
    reactive(galaxies_by_id)

  save_galaxies_to_storage: () ->
    galaxies = []
    galaxies.push [galaxy.id, galaxy.api_protocol, galaxy.api_url, galaxy.api_port] for galaxy_id,galaxy of @galaxies_by_id
    localStorage.setItem('galaxies', JSON.stringify(galaxies))
    @notify_galaxies_listeners()

  change_galaxy_id: (old_galaxy_id, new_galaxy_id) ->
    if @galaxies_by_id[new_galaxy_id]?
      Logger.warn("galaxy id in use, unable to update existing")
    else
      galaxy = @galaxies_by_id[old_galaxy_id]
      delete @galaxies_by_id[old_galaxy_id]
      @galaxies_by_id[new_galaxy_id] = galaxy
    @save_galaxies_to_storage()

  add_galaxy: (api_protocol, api_url, api_port) ->
    galaxy = {
      id: Utils.uuid()
      api_protocol: api_protocol
      api_url: api_url
      api_port: api_port
    }
    @galaxies_by_id[galaxy.id] = galaxy
    @save_galaxies_to_storage()
    galaxy
  remove_galaxy: (id) ->
    delete @galaxies_by_id[id]
    @save_galaxies_to_storage()


  galaxy_to_hash: (galaxy) -> btoa("#{galaxy.id}|#{galaxy.api_protocol}|#{galaxy.api_url}|#{galaxy.api_port}")
  galaxy_from_hash: (hash) ->
    hash_parts = atob(hash).split('|')
    if hash_parts.length == 4
      return {
        id: hash_parts[0]
        api_protocol: hash_parts[1]
        api_url: hash_parts[2]
        api_port: hash_parts[3]
      }
    false

  load_authorization_state: () ->
    hash = localStorage.getItem(AUTH_GALAXY_HASH)
    hash_galaxy = @galaxy_from_hash(hash)
    if hash_galaxy && @galaxies_by_id[hash_galaxy.id]? && @galaxy_to_hash(@galaxies_by_id[hash_galaxy.id]) == hash
      @galaxy_id = hash_galaxy.id
      @galaxy_jwt = localStorage.getItem(AUTH_GALAXY_JWT)
      @galaxy_token = localStorage.getItem(AUTH_GALAXY_TOKEN)
    else
      @clear_authorization_state()

  set_authorization_state: (galaxy_id, auth_token, refresh_token) ->
    return unless @galaxies_by_id[galaxy_id]?
    @galaxy_id = galaxy_id
    @galaxy_jwt = auth_token
    @galaxy_token = refresh_token

    localStorage.setItem(AUTH_GALAXY_HASH, @galaxy_to_hash(@galaxies_by_id[@galaxy_id]))
    if @galaxy_jwt?.length
      localStorage.setItem(AUTH_GALAXY_JWT, @galaxy_jwt)
    else
      localStorage.removeItem(AUTH_GALAXY_JWT)
    if @galaxy_token?.length
      localStorage.setItem(AUTH_GALAXY_TOKEN, @galaxy_token)
    else
      localStorage.removeItem(AUTH_GALAXY_TOKEN)

  clear_authorization_state: () ->
    @galaxy_id = null
    @galaxy_jwt = null
    @galaxy_token = null
    localStorage.removeItem(AUTH_GALAXY_HASH)
    localStorage.removeItem(AUTH_GALAXY_JWT)
    localStorage.removeItem(AUTH_GALAXY_TOKEN)


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

  get_mini_map_zoom: () ->
    zoom = @option('mini_map.zoom')
    if _.isNumber(zoom) then Math.min(2, Math.max(0.25, zoom)) else 0.25
