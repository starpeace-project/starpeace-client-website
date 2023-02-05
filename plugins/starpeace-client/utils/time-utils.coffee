import { DateTime } from 'luxon';

export default class TimeUtils

  @within_minutes: (time, minutes) ->
    time? && DateTime.now() < time.plus({ minutes: minutes })
