
export default class CorporationIdentifier {
  id: string;
  name: string;
  planetId: string;

  constructor (id: string, name: string, planetId: string) {
    this.id = id;
    this.name = name;
    this.planetId = planetId;
  }

  static fromJson (json: any): CorporationIdentifier {
    return new CorporationIdentifier(
      json.id,
      json.name,
      json.planetId
    );
  }
}
