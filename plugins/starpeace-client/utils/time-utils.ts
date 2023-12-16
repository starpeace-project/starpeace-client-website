import { DateTime } from 'luxon';

export default class TimeUtils {
  static within_minutes (time: DateTime, minutes: number): boolean {
    return !!time && DateTime.now() < time.plus({ minutes: minutes });
  }
}

