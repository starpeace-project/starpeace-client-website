
import moment from 'moment'
import Vue from 'vue'

import EventListener from '~/plugins/starpeace-client/state/event-listener.coffee'

export default class SessionState
  constructor: () ->
    @event_listener = new EventListener()
    @reset_state()

  subscribe_session_token_listener: (listener_callback) -> @event_listener.subscribe('session.session_token', listener_callback)
  notify_session_token_listeners: () -> @event_listener.notify_listeners('session.session_token')

  reset_state: () ->
    @session_expired = false
    @session_token_request = null
    @session_token_as_of = null
    @session_token = null

    @tycoon_id = null

    @invalid_session_counter = 0
    @invalid_session_as_of = null

  set_session_info: (session_info) ->
    @session_token = session_info.session_token
    @tycoon_id = session_info.tycoon_id if session_info.tycoon_id?.length

    @notify_session_token_listeners()
