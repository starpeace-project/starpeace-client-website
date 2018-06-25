
import moment from 'moment'

class TimeUtils

  @within_minutes: (time, minutes) ->
    time? && moment().subtract(minutes, 'minutes').isBefore(time)

export default TimeUtils
