import BuildingPayload from '~/plugins/starpeace-client/api/events/types/building-payload.js';
import CorporationPayload from '~/plugins/starpeace-client/api/events/types/corporation-payload.js';
import PlanetPayload from '~/plugins/starpeace-client/api/events/types/planet-payload.js';


export default class SimulationPayload {
  planet: PlanetPayload;
  corporation: CorporationPayload | undefined;
  selectedBuilding: BuildingPayload | undefined;
  buildingEvents: Array<any> | undefined;
  issuedVisas: Array<any> | undefined;

  constructor (planet: PlanetPayload, corporation: CorporationPayload | undefined, selectedBuilding: BuildingPayload | undefined, buildingEvents: Array<any> | undefined, issuedVisas: Array<any> | undefined) {
    this.planet = planet;
    this.corporation = corporation;
    this.selectedBuilding = selectedBuilding;
    this.buildingEvents = buildingEvents;
    this.issuedVisas = issuedVisas;
  }

  toJson (): any {
    return {
      p: this.planet.toJson(),
      c: this.corporation?.toJson(),
      s: this.selectedBuilding?.toJson(),
      b: this.buildingEvents?.length ? this.buildingEvents : undefined,
      v: this.issuedVisas?.length ? this.issuedVisas : undefined,
    };
  }

  static fromJson (json: any): SimulationPayload {
    return new SimulationPayload(
      PlanetPayload.fromJson(json.p),
      json.c ? CorporationPayload.fromJson(json.c) : undefined,
      json.s ? BuildingPayload.fromJson(json.s) : undefined,
      json.b ?? [],
      json.v ?? []
    );
  }
}
