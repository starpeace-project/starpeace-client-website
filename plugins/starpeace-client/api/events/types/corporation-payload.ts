import { DateTime } from 'luxon';

import CompanyPayload from '~/plugins/starpeace-client/api/events/types/company-payload.js';

export default class CorporationPayload {
  lastMailAt: DateTime | undefined;
  cash: number;
  cashflow: number;
  companies: Array<CompanyPayload>;

  constructor (lastMailAt: DateTime | undefined, cash: number, cashflow: number, companies: Array<CompanyPayload>) {
    this.lastMailAt = lastMailAt;
    this.cash = cash;
    this.cashflow = cashflow;
    this.companies = companies;
  }

  toJson (): any {
    return {
      m: this.lastMailAt?.toSeconds(),
      c: this.cash,
      f: this.cashflow,
      o: this.companies.length ? this.companies.map(c => c.toJson()) : undefined
    };
  }

  static fromJson (json: any): CorporationPayload {
    return new CorporationPayload(
      json.m ? DateTime.fromSeconds(json.m) : undefined,
      json.c ?? 0,
      json.f ?? 0,
      (json.o ?? []).map(CompanyPayload.fromJson)
    );
  }
}
