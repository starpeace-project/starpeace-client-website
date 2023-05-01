import { markRaw } from 'vue';
import { DateTime } from 'luxon';
import TinyCache from 'tinycache';

import Cache from '~/plugins/starpeace-client/state/core/cache/cache'
import Corporation from '~/plugins/starpeace-client/corporation/corporation';
import CorporationIdentifier from '~/plugins/starpeace-client/corporation/corporation-identifier';
import CorporationLoanOffer from '~/plugins/starpeace-client/corporation/corporation-loan-offer';
import CorporationLoanPayment from '~/plugins/starpeace-client/corporation/corporation-loan-payment';
import CorporationPrestigeHistory from '~/plugins/starpeace-client/corporation/corporation-prestige-history';
import CorporationRanking from '~/plugins/starpeace-client/corporation/corporation-ranking';
import CorporationStrategy from '~/plugins/starpeace-client/corporation/corporation-strategy';
import Company from '~/plugins/starpeace-client/company/company';

export default class CorporationCache extends Cache {
  corporation_metadata_by_id: TinyCache;
  identifiers_by_tycoon_id: TinyCache;
  rankings_by_corporation_id: TinyCache;
  prestige_history_by_corporation_id: TinyCache;
  loan_payments_by_corporation_id: TinyCache;
  loan_offers_by_corporation_id: TinyCache;
  strategies_by_corporation_id: TinyCache;

  constructor () {
    super();
    this.corporation_metadata_by_id = markRaw(new TinyCache());
    this.identifiers_by_tycoon_id = markRaw(new TinyCache());
    this.rankings_by_corporation_id = markRaw(new TinyCache());
    this.prestige_history_by_corporation_id = markRaw(new TinyCache());
    this.loan_payments_by_corporation_id = markRaw(new TinyCache());
    this.loan_offers_by_corporation_id = markRaw(new TinyCache());
    this.strategies_by_corporation_id = markRaw(new TinyCache());
  }

  reset_multiverse () {
    this.corporation_metadata_by_id.clear();
    this.identifiers_by_tycoon_id.clear();
    this.rankings_by_corporation_id.clear();
    this.prestige_history_by_corporation_id.clear();
    this.loan_payments_by_corporation_id.clear();
    this.loan_offers_by_corporation_id.clear();
    this.strategies_by_corporation_id.clear();
  }

  subscribe_corporation_metadata_listener (listener_callback: Function) {
    this.event_listener.subscribe('corporation_cache.metadata', listener_callback);
  }
  notify_corporation_metadata_listeners () {
    this.event_listener.notify_listeners('corporation_cache.metadata');
  }

  metadata_for_id (corporation_id: string): Corporation | null {
    return this.corporation_metadata_by_id.get(corporation_id);
  }
  load_corporation (corporation: Corporation): void {
    this.corporation_metadata_by_id.put(corporation.id, corporation, Cache.FIVE_MINUTES);
    this.notify_corporation_metadata_listeners();
  }

  identifiers_for_tycoon_id (tycoon_id: string): CorporationIdentifier[] | null {
    return this.identifiers_by_tycoon_id.get(tycoon_id);
  }
  load_identifiers_for_tycoon_id (tycoon_id: string, identifiers: CorporationIdentifier[], withTimeout: boolean): void {
    if (withTimeout) {
      this.identifiers_by_tycoon_id.put(tycoon_id, identifiers, Cache.FIVE_MINUTES);
    }
    else {
      this.identifiers_by_tycoon_id.put(tycoon_id, identifiers);
    }
    this.notify_corporation_metadata_listeners();
  }

  rankings_for_id (corporation_id: string): CorporationRanking[] | null {
    return this.rankings_by_corporation_id.get(corporation_id);
  }
  load_rankings (corporation_id: string, rankings: CorporationRanking[]) {
    this.rankings_by_corporation_id.put(corporation_id, rankings, Cache.FIVE_MINUTES)
  }

  prestige_history_for_id (corporation_id: string): CorporationPrestigeHistory[] | null {
    return this.prestige_history_by_corporation_id.get(corporation_id);
  }
  load_prestige_history (corporation_id: string, histories: CorporationPrestigeHistory[]) {
    this.prestige_history_by_corporation_id.put(corporation_id, histories, Cache.FIVE_MINUTES)
  }

  loan_payments_for_id (corporation_id: string): CorporationLoanPayment[] | null {
    return this.loan_payments_by_corporation_id.get(corporation_id);
  }
  load_loan_payments (corporation_id: string, payments: CorporationLoanPayment[]) {
    this.loan_payments_by_corporation_id.put(corporation_id, payments, Cache.FIVE_MINUTES)
  }
  loan_offers_for_id (corporation_id: string): CorporationLoanOffer[] | null {
    return this.loan_offers_by_corporation_id.get(corporation_id);
  }
  load_loan_offers (corporation_id: string, offers: CorporationLoanOffer[]) {
    this.loan_offers_by_corporation_id.put(corporation_id, offers, Cache.FIVE_MINUTES)
  }

  strategies_for_id (corporation_id: string): CorporationStrategy[] | null {
    return this.strategies_by_corporation_id.get(corporation_id);
  }
  load_strategies (corporation_id: string, strategies: CorporationStrategy[]) {
    this.strategies_by_corporation_id.put(corporation_id, strategies, Cache.FIVE_MINUTES)
  }

  add_corporation_company (corporation_id: string, company: Company): void {
    if (this.corporation_metadata_by_id.get(corporation_id)) {
      this.corporation_metadata_by_id.get(corporation_id).companies.push(company);
    }
  }

  update_cashflow (corporation_id: string, time: DateTime, cash: number, cash_current_year: number, cashflow: number) {
    const corporation: Corporation | null = this.metadata_for_id(corporation_id);
    if (corporation) {
      corporation.cashAsOf = time;
      corporation.cash = cash;
      corporation.cashCurrentYear = cash_current_year;
    }
  }
}
