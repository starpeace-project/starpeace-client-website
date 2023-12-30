import _ from 'lodash';
import { DateTime } from 'luxon';

import BOOKMARKS_METADATA from '~/plugins/starpeace-client/api/sandbox/data/mock-bookmarks-metadata.json'
import MAIL from '~/plugins/starpeace-client/api/sandbox/data/mock-mail.json'
import TYCOON_METADATA from '~/plugins/starpeace-client/api/sandbox/data/mock-tycoon-metadata.json'

import PLANET_1_TYCOON_1_INVENTIONS from '~/plugins/starpeace-client/api/sandbox/data/mock-planet-1-tycoon-1-inventions.json'

interface CorporationIdentifier {
  id: string;
  name: string;
  planetId: string;
}

interface CompanyInfo {
  id: string;
  name: string;
  sealId: string;
  tycoonId: string;
  corporationId: string;
  planetId: string;
}

export class Cashflow {
  lastMailAt: DateTime | undefined;
  cash: number;
  companiesById: Record<string, CompanyCashflow>;

  constructor (lastMailAt: DateTime | undefined, cash: number, companiesById: Record<string, CompanyCashflow>) {
    this.lastMailAt = lastMailAt;
    this.cash = cash;
    this.companiesById = companiesById;
  }

  cashflow (): number {
    return Object.values(this.companiesById).reduce((sum, company) => sum + company.cashflow, 0);
  }

  incrementCash (): void {
    const daily = 24 * this.cashflow();
    this.cash = this.cash + daily;
  }
}

export class CompanyCashflow {
  id: string;
  cashflow: number;
  originalCashflow: number;

  constructor (id: string, cashflow: number, originalCashflow: number) {
    this.id = id;
    this.cashflow = cashflow;
    this.originalCashflow = originalCashflow;
  }

  adjustCashflow (delta: number) {
    this.cashflow = this.originalCashflow + (Math.floor(Math.random() * 500) - 50) * 1000 + delta;
  }
}

interface Strategy {
  id: string;
  corporationId: string;
  policy: string;
  otherTycoonId: string;
  otherTycoonName: string;
  otherCorporationId: string;
  otherCorporationName: string;
  otherPolicy: string;
}

export default class SandboxCorporation {
  tycoonById: Record<string, any>;
  corporationIdentifiersByTycoonId: Record<string, Array<CorporationIdentifier>>;

  corporationById: Record<string, any>;
  bookmarksByCorporationId: Record<string, any>;
  mailByCorporationId: Record<string, any>;
  strategiesByCorporationId: Record<string, Array<Strategy>>;
  cashflowByCorporationId: Record<string, Cashflow>;

  infoByCompanyId: Record<string, CompanyInfo>;
  inventionsByCompanyId: Record<string, any>

  constructor (tycoonById: Record<string, any>, corporationIdentifiersByTycoonId: Record<string, Array<CorporationIdentifier>>, corporationById: Record<string, any>, bookmarksByCorporationId: Record<string, any>, mailByCorporationId: Record<string, any>, strategiesByCorporationId: Record<string, Array<Strategy>>, cashflowByCorporationId: Record<string, Cashflow>, infoByCompanyId: Record<string, CompanyInfo>, inventionsByCompanyId: Record<string, any>) {
    this.tycoonById = tycoonById;
    this.corporationIdentifiersByTycoonId = corporationIdentifiersByTycoonId;
    this.corporationById = corporationById;
    this.bookmarksByCorporationId = bookmarksByCorporationId;
    this.mailByCorporationId = mailByCorporationId;
    this.strategiesByCorporationId = strategiesByCorporationId;
    this.cashflowByCorporationId = cashflowByCorporationId;
    this.infoByCompanyId = infoByCompanyId;
    this.inventionsByCompanyId = inventionsByCompanyId;
  }

  addCompany (planetId: string, building: any): void {
    if (!this.infoByCompanyId[building.companyId]) {
      this.infoByCompanyId[building.companyId] = {
        id: building.companyId,
        name: 'Random Company ' + Math.round(Math.random() * 100),
        sealId: 'DIS',
        tycoonId: building.tycoonId,
        corporationId: building.corporationId,
        planetId: planetId
      }
    }
  }

  static createCashflows (mailByCorporationId: Record<string, any>): Record<string, Cashflow> {
    const cashflowByCorporationId: Record<string, Cashflow> = {};
    for (const tycoon of Object.values(TYCOON_METADATA)) {
      for (const corporation of tycoon.corporations) {
        const mailAt = _.first(_.orderBy(mailByCorporationId[corporation.id], ['sentAt'], ['desc']))?.sentAt;
        const cash = corporation.cash ?? 0;
        const cashflowByCompanyId: Record<string, CompanyCashflow> = {};
        for (const company of corporation.companies) {
          cashflowByCompanyId[company.id] = new CompanyCashflow(company.id, 0, 0);
        }
        cashflowByCorporationId[corporation.id] = new Cashflow(mailAt ? DateTime.fromISO(mailAt) : undefined, cash / 4, cashflowByCompanyId);
      }
    }
    return cashflowByCorporationId;
  }

  static createCompanyInfos (): Record<string, CompanyInfo> {
    const infoByCompanyId: Record<string, CompanyInfo> = {};
    for (const [tycoonId, tycoon] of Object.entries(TYCOON_METADATA)) {
      for (const corporation of tycoon.corporations) {
        for (const company of corporation.companies) {
          infoByCompanyId[company.id] = {
            id: company.id,
            name: company.name,
            sealId: company.sealId,
            tycoonId: tycoonId,
            corporationId: corporation.id,
            planetId: corporation.planetId
          }
        }
      }
    }
    return infoByCompanyId;
  }

  static createStrategies (corporationId: string): Record<string, Array<Strategy>> {
    return {
      [corporationId]: [
        {
          id: 's-id-1',
          corporationId: corporationId,
          policy: 'NONE',
          otherTycoonId: 'tycoon-id-2',
          otherTycoonName: 'Other Tycoon',
          otherCorporationId: 'corp-id-4',
          otherCorporationName: 'Corporation Other',
          otherPolicy: 'PRIORITIZE'
        }, {
          id: 's-id-2',
          corporationId: corporationId,
          policy: 'PRIORITIZE',
          otherTycoonId: 'tycoon-id-3',
          otherTycoonName: 'Other Tycoon 2',
          otherCorporationId: 'corp-id-5',
          otherCorporationName: 'Corporation Other 2',
          otherPolicy: 'PRIORITIZE'
        }, {
          id: 's-id-3',
          corporationId: corporationId,
          policy: 'EMBARGO',
          otherTycoonId: 'tycoon-id-4',
          otherTycoonName: 'Other Tycoon 3',
          otherCorporationId: 'corp-id-6',
          otherCorporationName: 'Corporation Other 3',
          otherPolicy: 'NONE'
        }, {
          id: 's-id-4',
          corporationId: corporationId,
          policy: 'NONE',
          otherTycoonId: 'tycoon-id-5',
          otherTycoonName: 'Other Tycoon 4',
          otherCorporationId: 'corp-id-7',
          otherCorporationName: 'Corporation Other 4',
          otherPolicy: 'EMBARGO'
        }
      ]
    }
  }

  static create (): SandboxCorporation {
    const corporationIdentifiersByTycoonId: Record<string, Array<CorporationIdentifier>> = {};
    const corporationById: Record<string, any> = {};
    for (const [tycoonId, tycoon] of Object.entries(TYCOON_METADATA)) {
      corporationIdentifiersByTycoonId[tycoonId] = [];
      for (const corporation of tycoon.corporations) {
        corporationIdentifiersByTycoonId[tycoonId].push({
          id: corporation.id,
          name: corporation.name,
          planetId: corporation.planetId
        });
        corporationById[corporation.id] = corporation;
      }
    }

    return new SandboxCorporation(
      TYCOON_METADATA,
      corporationIdentifiersByTycoonId,
      corporationById,
      BOOKMARKS_METADATA,
      MAIL,
      SandboxCorporation.createStrategies('corp-id-1'),
      SandboxCorporation.createCashflows(MAIL),
      SandboxCorporation.createCompanyInfos(),
      PLANET_1_TYCOON_1_INVENTIONS
    );
  }
}
