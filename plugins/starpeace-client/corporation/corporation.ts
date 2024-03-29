import { DateTime } from 'luxon';

import Company from '~/plugins/starpeace-client/company/company';

export default class Corporation {
  id: string;
  tycoon_id: string;
  planet_id: string;
  name: string;
  levelId: string;

  buildingCount: number;

  cashAsOf: DateTime;
  cash: number;
  cashflow: number;

  prestige: number;

  companies: Company[];

  constructor (id: string, tycoon_id: string, planet_id: string, name: string, levelId: string, buildingCount: number,
        cashAsOf: DateTime, cash: number, cashflow: number, prestige: number, companies: Company[]) {
    this.id = id;
    this.tycoon_id = tycoon_id;
    this.planet_id = planet_id;
    this.name = name;
    this.levelId = levelId;
    this.buildingCount = buildingCount;
    this.cashAsOf = cashAsOf;
    this.cash = cash;
    this.cashflow = cashflow;
    this.prestige = prestige;
    this.companies = companies;
  }

  get building_count (): number {
    return this.buildingCount;
  }

  static from_json (json: any): Corporation {
    return new Corporation(
      json.id,
      json.tycoonId,
      json.planetId,
      json.name,
      json.levelId,
      json.buildingCount ?? 0,
      DateTime.fromISO(json.cashAsOf),
      json.cash ?? 0,
      json.cashflow ?? 0,
      json.prestige ?? 0,
      (json.companies || []).map(Company.from_json)
    );
  }
}
