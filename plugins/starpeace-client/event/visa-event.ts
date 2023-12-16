import { DateTime } from "luxon";

export class VisaNewsEvent {
  tycoonName: string | undefined;
  corporationName: string | undefined;

  planetTime: DateTime;
  planetName: string;

  constructor (tycoonName: string | undefined, corporationName: string | undefined, planetTime: DateTime, planetName: string) {
    this.tycoonName = tycoonName;
    this.corporationName = corporationName;
    this.planetTime = planetTime;
    this.planetName = planetName;
  }

  static from (event: VisaEvent, planetName: string): VisaNewsEvent {
    return new VisaNewsEvent(
      event.tycoonName,
      event.corporationName,
      event.planetTime,
      planetName
    );
  }
}

export default class VisaEvent {
  planetTime: DateTime;
  tycoonName: string | undefined;
  corporationName: string | undefined;

  constructor (planetTime: DateTime, tycoonName: string | undefined, corporationName: string | undefined) {
    this.planetTime = planetTime;
    this.tycoonName = tycoonName;
    this.corporationName = corporationName;
  }
}
