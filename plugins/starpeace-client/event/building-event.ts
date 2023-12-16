import { type DateTime } from 'luxon';

import ChunkMap from '~/plugins/starpeace-client/map/chunk/chunk-map';

export type BuildingEventType = 'ADD' | 'UPDATE' | 'DELETE';

export class BuildingNewsEvent {
  tycoonName: string;
  companyName: string;

  townId: string;
  definitionId: string;

  planetTime: DateTime;
  buildingId: string;
  mapX: number;
  mapY: number;

  count: number = 1;

  constructor (tycoonName: string, companyName: string, townId: string, definitionId: string, planetTime: DateTime, buildingId: string, mapX: number, mapY: number) {
    this.tycoonName = tycoonName;
    this.companyName = companyName;
    this.townId = townId;
    this.definitionId = definitionId;
    this.planetTime = planetTime;
    this.buildingId = buildingId;
    this.mapX = mapX;
    this.mapY = mapY;
  }

  canMerge (other: BuildingNewsEvent): boolean {
    return this.tycoonName == other.tycoonName && this.companyName == other.companyName && this.townId == other.townId && this.definitionId == other.definitionId;
  }

  static from (event: BuildingEvent): BuildingNewsEvent {
    return new BuildingNewsEvent(
      event.tycoonName,
      event.companyName,
      event.townId,
      event.definitionId,
      event.planetTime,
      event.id,
      event.mapX,
      event.mapY
    );
  }
}

export default class BuildingEvent {
  planetTime: DateTime;
  type: BuildingEventType;

  id: string;
  definitionId: string;
  townId: string;
  tycoonName: string;
  companyName: string;

  mapX: number;
  mapY: number;

  constructor (planetTime: DateTime, type: BuildingEventType, id: string, definitionId: string, townId: string, tycoonName: string, companyName: string, mapX: number, mapY: number) {
    this.planetTime = planetTime;
    this.type = type;
    this.id = id;
    this.definitionId = definitionId;
    this.townId = townId;
    this.tycoonName = tycoonName;
    this.companyName = companyName;
    this.mapX = mapX;
    this.mapY = mapY;
  }

  get chunkX (): number {
    return this.mapX / ChunkMap.CHUNK_HEIGHT;
  }

  get chunkY (): number {
    return this.mapY / ChunkMap.CHUNK_HEIGHT;
  }
}
