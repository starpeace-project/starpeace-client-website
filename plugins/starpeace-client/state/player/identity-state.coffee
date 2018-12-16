
import moment from 'moment'
import Vue from 'vue'

import EventListener from '~/plugins/starpeace-client/state/event-listener.coffee'
import Identity from '~/plugins/starpeace-client/identity/identity.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class IdentityState
  constructor: () ->
    @event_listener = new EventListener()
    @reset_state()

  reset_state: () ->
    @visa_type = null
    @identity = null

  subscribe_visa_type_listener: (listener_callback) -> @event_listener.subscribe('identity.visa_type', listener_callback)
  notify_visa_type_listeners: () -> @event_listener.notify_listeners('identity.visa_type')

  subscribe_identity_listener: (listener_callback) -> @event_listener.subscribe('identity.identity', listener_callback)
  notify_identity_listeners: () -> @event_listener.notify_listeners('identity.identity')


  set_visa_type: (visa_type) ->
    @visa_type = visa_type
    @notify_visa_type_listeners()

  set_identity: (identity) ->
    @identity = identity
    @notify_identity_listeners()
