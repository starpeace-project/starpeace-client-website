
import CompanyInventions from '~/plugins/starpeace-client/invention/company-inventions'

import ApiClient from '~/plugins/starpeace-client/api/api-client'
import ClientState from '~/plugins/starpeace-client/state/client-state';
import AjaxState from '~/plugins/starpeace-client/state/ajax-state';

export default class InventionManager {
  api: ApiClient;
  asset_manager: any;

  ajaxState: AjaxState;
  clientState: ClientState;

  constructor (api: ApiClient, asset_manager: any, ajaxState: AjaxState, clientState: ClientState) {
    this.api = api;
    this.asset_manager = asset_manager;
    this.ajaxState = ajaxState;
    this.clientState = clientState;
  }

  initialize (): void {
    this.clientState.core.invention_library.initialize(this.clientState.core.building_library, this.clientState.core.planet_library);
  }

  async loadByCompany (companyId: string, skipCache: boolean = false): Promise<CompanyInventions> {
    if (!this.clientState.has_session() || !companyId) {
      throw Error();
    }

    const summary = this.clientState.corporation.inventions_metadata_by_company_id[companyId];
    if (!!summary && !skipCache) {
      return summary;
    }

    return await this.ajaxState.locked('player.inventions_metadata', companyId, async () => {
      const summary = CompanyInventions.fromJson(await this.api.inventions_for_company(companyId));
      this.clientState.corporation.update_company_inventions_metadata(companyId, summary);
      return summary;
    });
  }

  async sellInvention (companyId: string, inventionId: string): Promise<CompanyInventions> {
    if (!this.clientState.has_session() || !companyId || !inventionId) {
      throw Error();
    }
    return await this.ajaxState.locked('player.sell_invention', companyId, async () => {
      const summary = CompanyInventions.fromJson(await this.api.sell_company_invention(companyId, inventionId));
      this.clientState.corporation.update_company_inventions_metadata(companyId, summary);
      return summary;
    });
  }

  async queueInvention (companyId: string, inventionId: string): Promise<CompanyInventions> {
    if (!this.clientState.has_session() || !companyId || !inventionId) {
      throw Error();
    }
    return await this.ajaxState.locked('player.queue_invention', companyId, async () => {
      const summary = CompanyInventions.fromJson(await this.api.queue_company_invention(companyId, inventionId));
      this.clientState.corporation.update_company_inventions_metadata(companyId, summary);
      return summary;
    });
  }
}
