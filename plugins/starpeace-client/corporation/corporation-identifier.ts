import { DateTime } from 'luxon';

export default class CorporationIdentifier {
  id: string;
  name: string;
  planetId: string;
  lastPlayedAt: DateTime;

  constructor (id: string, name: string, planetId: string, lastPlayedAt: DateTime) {
    this.id = id;
    this.name = name;
    this.planetId = planetId;
    this.lastPlayedAt = lastPlayedAt;
  }

  static fromJson (json: any): CorporationIdentifier {
    return new CorporationIdentifier(
      json.id,
      json.name,
      json.planetId,
      json.lastPlayedAt ? DateTime.fromISO(json.lastPlayedAt) : DateTime.now()
    );
  }
}
