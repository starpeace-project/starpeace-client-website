import Corporation from '~/plugins/starpeace-client/corporation/corporation';
import CorporationIdentifier from '~/plugins/starpeace-client/corporation/corporation-identifier';
import CorporationLoanOffer from './corporation-loan-offer';
import CorporationLoanPayment from './corporation-loan-payment';
import CorporationPrestigeHistory from './corporation-prestige-history';
import CorporationRanking from './corporation-ranking';
import CorporationStrategy from '~/plugins/starpeace-client/corporation/corporation-strategy';

export default class CorporationManager {
  apiClient: any;
  ajaxState: any;
  clientState: any;

  constructor (apiClient: any, ajaxState: any, clientState: any) {
    this.apiClient = apiClient;
    this.ajaxState = ajaxState;
    this.clientState = clientState;
  }

  async load_identifiers_by_tycoon (tycoonId: string): Promise<CorporationIdentifier[]> {
    if (!tycoonId) {
      throw Error();
    }
    const identifiers: CorporationIdentifier[] | null = this.clientState.core.corporation_cache.identifiers_for_tycoon_id(tycoonId);
    if (identifiers) {
      return Promise.resolve(identifiers);
    }

    return await this.ajaxState.locked('tycoon_corporations', tycoonId, async () => {
      const identifiers: CorporationIdentifier[] = await this.apiClient.corporationIdentifiersForTycoonId(tycoonId);
      this.clientState.core.corporation_cache.load_identifiers_for_tycoon_id(tycoonId, identifiers, this.clientState.identity.galaxy_tycoon_id !== tycoonId);
      return identifiers;
    });
  }


  async load_by_corporation (corporationId: string): Promise<Corporation> {
    if (!this.clientState.has_session() || !corporationId) {
      throw Error();
    }
    const corporation = this.clientState.core.corporation_cache.metadata_for_id(corporationId);
    if (!!corporation) {
      return corporation;
    }

    return await this.ajaxState.locked('corporation_metadata', corporationId, async () => {
      const corporationJson: any = await this.apiClient.corporation_for_id(corporationId);
      const corporation: Corporation = Corporation.from_json(corporationJson);
      this.clientState.core.corporation_cache.load_corporation(corporation);
      this.clientState.core.company_cache.loadCompaniesMetadata(corporation.companies);
      return corporation;
    });
  }

  async create (corporationName: string): Promise<Corporation> {
    if (!this.clientState.has_session() || !corporationName) throw Error();
    return await this.ajaxState.locked('corporation_create', 'ALL', async () => {
      const corporation: Corporation = Corporation.from_json(await this.apiClient.create_corporation(corporationName));
      this.clientState.core.corporation_cache.load_corporation(corporation);
      this.clientState.core.company_cache.loadCompaniesMetadata(corporation.companies);
      return corporation;
    });
  }

  async load_rankings_by_corporation (corporationId: string): Promise<CorporationRanking[]> {
    if (!this.clientState.has_session() || !corporationId) throw Error();
    const cachedRankings: CorporationRanking[] = this.clientState.core.corporation_cache.rankings_for_id(corporationId);
    if (cachedRankings) return cachedRankings;

    return await this.ajaxState.locked('corporation_rankings', corporationId, async () => {
      const json: any[] = await this.apiClient.corporation_rankings_for_id(corporationId);
      const rankings: CorporationRanking[] = json.map(CorporationRanking.fromJson);
      this.clientState.core.corporation_cache.load_rankings(corporationId, rankings);
      return rankings;
    });
  }

  async load_prestige_history_by_corporation (corporationId: string): Promise<CorporationPrestigeHistory[]> {
    if (!this.clientState.has_session() || !corporationId) throw Error();
    const cachedHistories: CorporationPrestigeHistory[] = this.clientState.core.corporation_cache.prestige_history_for_id(corporationId);
    if (cachedHistories) return cachedHistories;

    return await this.ajaxState.locked('corporation_prestige_history', corporationId, async () => {
      const json: any[] = await this.apiClient.corporation_prestige_history_for_id(corporationId);
      const histories: CorporationPrestigeHistory[] = json.map(CorporationPrestigeHistory.fromJson);
      this.clientState.core.corporation_cache.load_prestige_history(corporationId, histories);
      return histories;
    });
  }

  async load_loan_payments_by_corporation (corporationId: string): Promise<CorporationLoanPayment[]> {
    if (!this.clientState.has_session() || !corporationId) throw Error();
    const cachedPayments: CorporationLoanPayment[] = this.clientState.core.corporation_cache.loan_payments_for_id(corporationId);
    if (cachedPayments) return cachedPayments;

    return await this.ajaxState.locked('corporation_loan_payments', corporationId, async () => {
      const json: any[] = await this.apiClient.corporation_loan_payments_for_id(corporationId);
      const payments: CorporationLoanPayment[] = json.map(CorporationLoanPayment.fromJson);
      this.clientState.core.corporation_cache.load_loan_payments(corporationId, payments);
      return payments;
    });
  }
  async load_loan_offers_by_corporation (corporationId: string): Promise<CorporationLoanOffer[]> {
    if (!this.clientState.has_session() || !corporationId) throw Error();
    const cachedOffers: CorporationLoanOffer[] = this.clientState.core.corporation_cache.loan_offers_for_id(corporationId);
    if (cachedOffers) return cachedOffers;

    return await this.ajaxState.locked('corporation_loan_offers', corporationId, async () => {
      const json: any[] = await this.apiClient.corporation_loan_offers_for_id(corporationId);
      const offers: CorporationLoanOffer[] = json.map(CorporationLoanOffer.fromJson);
      this.clientState.core.corporation_cache.load_loan_offers(corporationId, offers);
      return offers;
    });
  }

  async load_strategies_by_corporation (corporationId: string): Promise<CorporationStrategy[]> {
    if (!this.clientState.has_session() || !corporationId) throw Error();
    const cachedStrategies: CorporationStrategy[] = this.clientState.core.corporation_cache.strategies_for_id(corporationId);
    if (cachedStrategies) return cachedStrategies;

    return await this.ajaxState.locked('corporation_strategies', corporationId, async () => {
      const json: any[] = await this.apiClient.corporation_strategies_for_id(corporationId);
      const strategies: CorporationStrategy[] = json.map(CorporationStrategy.fromJson);
      this.clientState.core.corporation_cache.load_strategies(corporationId, strategies);
      return strategies;
    });
  }
}
