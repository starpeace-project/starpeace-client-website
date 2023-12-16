import Planet from '~/plugins/starpeace-client/planet/planet.js'
import Tycoon from '~/plugins/starpeace-client/tycoon/tycoon.js'

export default class Galaxy {
  id: string;
  name: string;

  visitor_enabled: boolean;
  tycoon_enabled: boolean;
  tycoon_creation_enabled: boolean;
  tycoon_authentication: string;

  tycoon: Tycoon | undefined | null;
  planets: Array<Planet>;

  as_of: Date = new Date();

  constructor (id: string, name: string, visitor_enabled: boolean, tycoon_enabled: boolean, tycoon_creation_enabled: boolean, tycoon_authentication: string, tycoon: Tycoon | undefined | null, planets: Array<Planet>) {
    this.id = id;
    this.name = name;
    this.visitor_enabled = visitor_enabled;
    this.tycoon_enabled = tycoon_enabled;
    this.tycoon_creation_enabled = tycoon_creation_enabled;
    this.tycoon_authentication = tycoon_authentication;
    this.tycoon = tycoon;
    this.planets = planets;
  }

  get planet_count (): number {
    return this.planets.length;
  }
  get online_count (): number {
    return this.planets.map((p: Planet) => p.online_count).reduce((sum, val) => sum + val, 0);
  }

  static from_json (json: any): Galaxy {
    return new Galaxy(
      json.id,
      json.name,
      json.visitorEnabled ?? false,
      json.tycoonEnabled ?? false,
      json.tycoonCreationEnabled ?? false,
      json.tycoonAuthentication ?? 'password',
      !!json.tycoon ? Tycoon.from_json(json.tycoon) : null,
      (json.planets ?? []).map(Planet.from_json)
    );
  }
}
