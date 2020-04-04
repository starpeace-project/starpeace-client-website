
import moment from 'moment'
import Vue from 'vue'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class AjaxState
  constructor: () ->
    @reset_state()

  reset_state: () ->
    if @ajax_requests > 0
      # FIXME: TODO: add better support
      Logger.info "resetting ajax state with unfinished requests"

    @invalid_session_counter = 0
    @invalid_session_as_of = null

    @ajax_requests = 0
    @request_mutex = {}

  start_ajax: () -> @ajax_requests += 1
  finish_ajax: () -> @ajax_requests -= 1 if @ajax_requests > 0

  is_locked: (type, key) -> @request_mutex[type]?[key] || false

  lock: (type, key) ->
    Vue.set(@request_mutex, type, {}) unless @request_mutex[type]?
    Vue.set(@request_mutex[type], key, true)
    @start_ajax()

  unlock: (type, key) ->
    Vue.set(@request_mutex[type], key, false) if @request_mutex[type]?[key]?
    @finish_ajax()


  with_lock: (type, key, done_callback, error_callback) ->
    @lock(type, key)
    {
      done: () =>
        @unlock(type, key)
        done_callback()
      error: () =>
        @unlock(type, key)
        error_callback()
    }
