import Planet from '~/plugins/starpeace-client/planet/planet.js'
import Tycoon from '~/plugins/starpeace-client/tycoon/tycoon.js'


export class VisaSettings {
  issue: boolean;
  create: boolean;

  constructor (issue: boolean, create: boolean) {
    this.issue = issue;
    this.create = create;
  }

  static fromJson (json: any): VisaSettings {
    if (json === true) {
      return new VisaSettings(true, true);
    }
    return new VisaSettings(
      json?.issue === true,
      json?.create === true
    );
  }
}

export class VisasSettings {
  visitor: VisaSettings;
  tycoon: VisaSettings;

  constructor (visitor: VisaSettings, tycoon: VisaSettings) {
    this.visitor = visitor;
    this.tycoon = tycoon;
  }

  static fromJson (json: any): VisasSettings {
    return new VisasSettings(
      VisaSettings.fromJson(json?.visitor),
      VisaSettings.fromJson(json?.tycoon)
    )
  }
}

export class ServerSettings {
  authentication: string;
  streamEncoding: string;

  constructor (authentication: string, streamEncoding: string) {
    this.authentication = authentication;
    this.streamEncoding = streamEncoding;
  }

  static fromJson (json: any): ServerSettings {
    return new ServerSettings(
      json?.authentication ?? 'password',
      json?.streamEncoding ?? 'raw'
    )
  }
}


export default class Galaxy {
  id: string;
  name: string;

  visas: VisasSettings;
  settings: ServerSettings;

  tycoon: Tycoon | undefined | null;
  planets: Array<Planet>;

  constructor (id: string, name: string, visas: VisasSettings, settings: ServerSettings, tycoon: Tycoon | undefined | null, planets: Array<Planet>) {
    this.id = id;
    this.name = name;
    this.visas = visas;
    this.settings = settings;
    this.tycoon = tycoon;
    this.planets = planets;
  }

  get planetCount (): number {
    return this.planets.length;
  }
  get onlineCount (): number {
    return this.planets.map((p: Planet) => p.onlineCount).reduce((sum, val) => sum + val, 0);
  }

  get visitorIssueEnabled (): boolean {
    return this.visas.visitor.issue;
  }
  get tycoonIssueEnabled (): boolean {
    return this.visas.tycoon.issue;
  }
  get tycoonCreateEnabled (): boolean {
    return this.visas.tycoon.create;
  }

  static fromJson (json: any): Galaxy {
    return new Galaxy(
      json.id,
      json.name,
      VisasSettings.fromJson(json.visas),
      ServerSettings.fromJson(json.settings),
      !!json.tycoon ? Tycoon.fromJson(json.tycoon) : null,
      (json.planets ?? []).map(Planet.from_json)
    );
  }
}
