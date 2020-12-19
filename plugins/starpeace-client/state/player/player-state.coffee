
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
    @planet_id = null
    @planet_visa_type = null
    @planet_visa_id = null

    @corporation_id = null
    @company_id = null

    @last_mail_at = null
    @mail_by_id = null
    @selected_mail_id = null

    @mail_compose_mode = false
    @mail_compose_to = ''
    @mail_compose_subject = ''
    @mail_compose_body = ''

  has_data: () ->
    @mail_by_id?

  subscribe_planet_visa_type_listener: (listener_callback) -> @event_listener.subscribe('player.visa_type', listener_callback)
  notify_planet_visa_type_listeners: () -> @event_listener.notify_listeners('player.visa_type')

  subscribe_planet_visa_id_listener: (listener_callback) -> @event_listener.subscribe('player.planet_visa_id', listener_callback)
  notify_planet_visa_id_listeners: () -> @event_listener.notify_listeners('player.planet_visa_id')

  subscribe_corporation_id_listener: (listener_callback) -> @event_listener.subscribe('player.corporation_id', listener_callback)
  notify_corporation_id_listeners: () -> @event_listener.notify_listeners('player.corporation_id')

  subscribe_mail_listener: (listener_callback) -> @event_listener.subscribe('player.mail', listener_callback)
  notify_mail_listeners: () -> @event_listener.notify_listeners('player.mail')

  set_planet_visa_type: (planet_id, visa_type) ->
    @planet_id = planet_id
    @planet_visa_type = visa_type
    @corporation_id = null
    Logger.debug "proceeding with planet <#{planet_id}> and visa <#{visa_type}>"
    @notify_planet_visa_type_listeners()

  set_planet_corporation_id: (corporation_id) ->
    @corporation_id = corporation_id
    Logger.debug "proceeding with corporation <#{corporation_id}>"
    @notify_corporation_id_listeners()

  set_planet_visa_id: (visa_id) ->
    @planet_visa_id = visa_id
    @notify_planet_visa_id_listeners()

  set_company_id: (company_id) ->
    @company_id = company_id


  set_mail: (mails) ->
    @mail_by_id = {} unless @mail_by_id?
    if Array.isArray(mails)
      Vue.set(@mail_by_id, mail.id, mail) for mail in mails
    else
      Vue.set(@mail_by_id, mails.id, mails)
    @notify_mail_listeners()

  remove_mail: (mail_id) ->
    @selected_mail_id = null if @selected_mail_id == mail_id
    Vue.delete(@mail_by_id, mail_id) if @mail_by_id[mail_id]?
    @notify_mail_listeners()

  start_compose: (to_corporations=[]) ->
    @mail_compose_mode = true
  end_compose: () ->
    @mail_compose_mode = false
    @mail_compose_to = ''
    @mail_compose_subject = ''
    @mail_compose_body = ''
