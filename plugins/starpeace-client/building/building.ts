import { DateTime } from 'luxon';

export default class Building {
  id: string;
  tycoonId: string;
  corporationId: string;
  companyId: string;
  definitionId: string;
  townId: string;
  name: string | undefined | null;
  mapX: number;
  mapY: number;
  stage: number;
  constructionStartedAt: DateTime;
  constructionFinishedAt: DateTime | undefined;

  constructor (id: string, tycoonId: string, corporationId: string, companyId: string, definitionId: string, townId: string, name: string | undefined | null, mapX: number, mapY: number, stage: number, constructionStartedAt: DateTime, constructionFinishedAt: DateTime | undefined) {
    this.id = id;
    this.tycoonId = tycoonId;
    this.corporationId = corporationId;
    this.companyId = companyId;
    this.definitionId = definitionId;
    this.townId = townId;
    this.name = name;
    this.mapX = mapX;
    this.mapY = mapY;
    this.stage = stage;
    this.constructionStartedAt = constructionStartedAt;
    this.constructionFinishedAt = constructionFinishedAt;
  }

  get tycoon_id () { return this.tycoonId; }
  get corporation_id () { return this.corporationId; }
  get company_id () { return this.companyId; }
  get definition_id () { return this.definitionId; }
  get town_id () { return this.townId; }
  get map_x () { return this.mapX; }
  get map_y () { return this.mapY; }

  static fromJson (json: any): Building {
    return new Building(
      json.id,
      json.tycoonId,
      json.corporationId,
      json.companyId,
      json.definitionId,
      json.townId,
      json.name,
      json.mapX,
      json.mapY,
      json.stage ?? 0,
      DateTime.fromISO(json.constructionStartedAt),
      json.constructionFinishedAt ? DateTime.fromISO(json.constructionFinishedAt) : undefined
    );
  }
}


