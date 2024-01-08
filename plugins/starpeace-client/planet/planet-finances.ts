
export interface TownFinance {
  id: string;
  cash: number;
}

export interface CorporationFinance {
  id: string;
  cash: number;
  cashflow: number;
}

export interface CompanyFinance {
  id: string;
  cashflow: number;
}

export interface BuildingFinance {
  id: string;
  cashflow: number;
}

export default class PlanetFinances {
  towns: Array<TownFinance>;
  corporations: Array<CorporationFinance>;
  companies: Array<CompanyFinance>;
  buildings: Array<BuildingFinance>;

  constructor (towns: Array<TownFinance>, corporations: Array<CorporationFinance>, companies: Array<CompanyFinance>, buildings: Array<BuildingFinance>) {
    this.towns = towns;
    this.corporations = corporations;
    this.companies = companies;
    this.buildings = buildings;
  }

  static fromJson (json: any): PlanetFinances {
    return new PlanetFinances(
      json.towns ?? [],
      json.corporations ?? [],
      json.companies ?? [],
      json.buildings ?? []
    );
  }
}
