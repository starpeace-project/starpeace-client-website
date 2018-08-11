
import moment from 'moment'

export default class TimeUtils

  @within_minutes: (time, minutes) ->
    time? && moment().subtract(minutes, 'minutes').isBefore(time)
