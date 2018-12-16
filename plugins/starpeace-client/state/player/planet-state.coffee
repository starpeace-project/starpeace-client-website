
import moment from 'moment'
import Vue from 'vue'

import EventListener from '~/plugins/starpeace-client/state/event-listener.coffee'

export default class PlanetState
  constructor: () ->
    @event_listener = new EventListener()
    @reset_state()

  reset_state: () ->
    @game_map = null
    @details = null
    @details_as_of = null

    @events_as_of = null

    @current_date = null
    @current_season = null

    @tycoons_online = []

  subscribe_map_data_listener: (listener_callback) -> @event_listener.subscribe('player.map_data', listener_callback)
  notify_map_data_listeners: (chunk_event) -> @event_listener.notify_listeners('player.map_data', chunk_event)

  subscribe_planet_details_listener: (listener_callback) -> @event_listener.subscribe('player.planet_details', listener_callback)
  notify_planet_details_listeners: () -> @event_listener.notify_listeners('player.planet_details')

  has_data: () -> @details?

  load_game_map: (game_map) ->
    @game_map = game_map
    # FIXME: TODO: may want to notify

  load_planet_details: (details) ->
    @details = details
    @details_as_of = moment()
    @notify_planet_details_listeners()
