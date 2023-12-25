import ViewPayload from '~/plugins/starpeace-client/api/events/types/view-payload.js';
import PlanetPayload from '~/plugins/starpeace-client/api/events/types/planet-payload.js';
import CorporationPayload from '~/plugins/starpeace-client/api/events/types/corporation-payload.js';


export default class InitializePayload {
  view: ViewPayload;
  planet: PlanetPayload;
  corporation: CorporationPayload | undefined;

  constructor (view: ViewPayload, planet: PlanetPayload, corporation: CorporationPayload | undefined) {
    this.view = view;;
    this.planet = planet;
    this.corporation = corporation;
  }

  toJson (): any {
    return {
      v: this.view.toJson(),
      p: this.planet.toJson(),
      c: this.corporation?.toJson()
    };
  }

  static fromJson (json: any): InitializePayload {
    return new InitializePayload(
      ViewPayload.fromJson(json.v),
      PlanetPayload.fromJson(json.p),
      json.c ? CorporationPayload.fromJson(json.c) : undefined
    );
  }
}
