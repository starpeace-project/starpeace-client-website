import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class AjaxState
  constructor: () ->
    @reset_state()

  reset_state: () ->
    if @ajax_requests > 0
      # FIXME: TODO: add better support
      Logger.info "Resetting ajax state with unfinished requests"

    @invalid_session_counter = 0
    @invalid_session_as_of = null

    @invalid_connection_counter = 0
    @invalid_connection_as_of = null

    @ajax_requests = 0
    @request_mutex = {}

  start_ajax: () -> @ajax_requests += 1
  finish_ajax: () -> @ajax_requests -= 1 if @ajax_requests > 0

  is_locked: (type, key) -> !!@request_mutex[type]?[key]

  lock: (type, key, locked_promise) ->
    @request_mutex[type] = {} unless @request_mutex[type]?
    @request_mutex[type][key] = locked_promise || true
    @start_ajax()

  unlock: (type, key) ->
    @request_mutex[type][key] = false if @request_mutex[type]?[key]?
    @finish_ajax()

  locked: (type, key, callback) ->
    locked_promise = @request_mutex[type]?[key]
    return await locked_promise if locked_promise

    promise = callback()
    @lock(type, key, promise)
    try
      result = await promise
      @unlock(type, key)
      result
    catch err
      @unlock(type, key)
      throw err
