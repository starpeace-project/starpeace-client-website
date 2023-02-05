import _ from 'lodash';
import { DateTime }  from 'luxon';

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
    @as_of = DateTime.now()


  @within_minutes: (time, minutes) ->
    time? && DateTime.now() < time.plus({ minutes: minutes })
