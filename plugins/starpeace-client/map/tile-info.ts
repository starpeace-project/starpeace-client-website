import Building from "../building/building";

export default class TileInfo {
  isPositionWithinMap: boolean = false;
  isChunkDataLoaded: boolean = false;

  land: any | undefined;
  building: Building | undefined;
  concrete: any | undefined;
  overlay: any | undefined;
  road: any | undefined;
  tree: any | undefined;
  zone: any | undefined;

  constructor (isPositionWithinMap: boolean, isChunkDataLoaded: boolean, land: any | undefined, building: Building | undefined, concrete: any | undefined, overlay: any | undefined, road: any | undefined, tree: any | undefined, zone: any | undefined) {
    this.isPositionWithinMap = isPositionWithinMap;
    this.isChunkDataLoaded = isChunkDataLoaded;

    this.land = land;
    this.building = building;
    this.concrete = concrete;
    this.overlay = overlay;
    this.road = road;
    this.tree = tree;
    this.zone = zone;
  }
}