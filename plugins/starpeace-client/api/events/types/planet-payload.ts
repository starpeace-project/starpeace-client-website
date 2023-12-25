import { DateTime } from 'luxon';

export default class PlanetPayload {
  time: DateTime;
  season: string;

  constructor (time: DateTime, season: string) {
    this.time = time;
    this.season = season;
  }

  toJson (): any {
    return {
      t: this.time.toSeconds(),
      s: this.season
    };
  }

  static fromJson (json: any): PlanetPayload {
    return new PlanetPayload(
      DateTime.fromSeconds(json.t),
      json.s
    );
  }
}
