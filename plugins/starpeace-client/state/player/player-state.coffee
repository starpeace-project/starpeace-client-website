
import moment from 'moment'
import Vue from 'vue'

import EventListener from '~/plugins/starpeace-client/state/event-listener.coffee'

import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class PlayerState
  constructor: () ->
    @event_listener = new EventListener()
    @reset_state()

  reset_state: () ->
    @planet_visa_type = null
    @planet_id = null

    @corporation_id = null
    @company_id = null

    @mail_by_id_as_of = null
    @mail_by_id = null

  has_data: () -> @mail_by_id?

  subscribe_planet_id_listener: (listener_callback) -> @event_listener.subscribe('player.planet_id', listener_callback)
  notify_planet_id_listeners: () -> @event_listener.notify_listeners('player.planet_id')

  subscribe_corporation_id_listener: (listener_callback) -> @event_listener.subscribe('player.corporation_id', listener_callback)
  notify_corporation_id_listeners: () -> @event_listener.notify_listeners('player.corporation_id')

  subscribe_mail_metadata_listener: (listener_callback) -> @event_listener.subscribe('player.mail_metadata', listener_callback)
  notify_mail_metadata_listeners: () -> @event_listener.notify_listeners('player.mail_metadata')


  set_planet_id: (planet_id) ->
    @planet_id = planet_id
    Logger.debug "proceeding with planet <#{planet_id}>"
    @notify_planet_id_listeners()

  set_corporation_id: (corporation_id) ->
    @corporation_id = corporation_id
    Logger.debug "proceeding with corporation <#{corporation_id}>"
    @notify_corporation_id_listeners()

  set_company_id: (company_id) ->
    @company_id = company_id


  set_mail_metadata: (mail_metadata) ->
    @mail_by_id = {}
    Vue.set(@mail_by_id, item.id, item) for item in (mail_metadata || [])
    @mail_by_id_as_of = moment()
    @notify_mail_metadata_listeners()
