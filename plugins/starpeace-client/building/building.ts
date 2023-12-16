import { DateTime } from 'luxon';

export default class Building {
  id: string;

  tycoonId: string;
  corporationId: string;
  companyId: string;

  definitionId: string;
  townId: string;
  name: string | undefined;

  mapX: number;
  mapY: number;

  level: number;
  upgrading: boolean;
  constructionStartedAt: DateTime | undefined;
  constructionFinishedAt: DateTime | undefined;

  condemnedAt: DateTime | undefined;

  constructor (id: string, tycoonId: string, corporationId: string, companyId: string, definitionId: string, townId: string, name: string | undefined, mapX: number, mapY: number, level: number, upgrading: boolean, constructionStartedAt: DateTime | undefined, constructionFinishedAt: DateTime | undefined, condemnedAt: DateTime | undefined) {
    this.id = id;
    this.tycoonId = tycoonId;
    this.corporationId = corporationId;
    this.companyId = companyId;
    this.definitionId = definitionId;
    this.townId = townId;
    this.name = name;
    this.mapX = mapX;
    this.mapY = mapY;
    this.level = level;
    this.upgrading = upgrading;
    this.constructionStartedAt = constructionStartedAt;
    this.constructionFinishedAt = constructionFinishedAt;
    this.condemnedAt = condemnedAt;
  }

  get constructed (): boolean {
    return !!this.constructionFinishedAt;
  }

  get isIfel (): boolean {
    return this.tycoonId === 'IFEL' || this.companyId === 'IFEL';
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
      json.level ?? 0,
      json.upgrading ?? false,
      json.constructionStartedAt ? DateTime.fromISO(json.constructionStartedAt) : undefined,
      json.constructionFinishedAt ? DateTime.fromISO(json.constructionFinishedAt) : undefined,
      json.condemnedAt ? DateTime.fromISO(json.condemnedAt) : undefined
    );
  }
}


