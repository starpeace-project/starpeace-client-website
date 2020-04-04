
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
    @galaxy_id = null
    @galaxy_visa_type = null
    @galaxy_tycoon = null

  subscribe_visa_type_listener: (listener_callback) -> @event_listener.subscribe('identity.visa_type', listener_callback)
  notify_visa_type_listeners: () -> @event_listener.notify_listeners('identity.visa_type')

  set_visa: (galaxy_id, visa_type, tycoon) ->
    @galaxy_id = galaxy_id
    @galaxy_visa_type = visa_type
    @galaxy_tycoon = tycoon
    @notify_visa_type_listeners()
