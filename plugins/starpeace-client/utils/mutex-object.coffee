
import moment from 'moment'

import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'

export default class MutexObject
  constructor: () ->
    @locked = false
    @as_of = null
    @value = null

    @listeners = []

  has_value: () -> @value?

  attach_listener: (listener) ->
    @listener.push listener if _.isFunction(listener)

  attempt_lock: () ->
    return false if @locked
    @locked = true
    true
  release_lock: () -> @locked = false if @locked

  update: (value) ->
    @value = value
    @as_of = moment()


  @within_minutes: (time, minutes) ->
    time? && moment().subtract(minutes, 'minutes').isBefore(time)
