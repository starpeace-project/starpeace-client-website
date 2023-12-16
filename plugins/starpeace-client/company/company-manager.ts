import Company from '~/plugins/starpeace-client/company/company';

export default class CompanyManager {
  api: any;
  ajax_state: any;
  client_state: any;

  constructor (api: any, ajax_state: any, client_state: any) {
    this.api = api;
    this.ajax_state = ajax_state;
    this.client_state = client_state;
  }

  async create (company_name: string, seal_id: string): Promise<Company> {
    const corporation_id = this.client_state.player.corporation_id;
    if (!this.client_state.has_session() || !corporation_id || !company_name?.length || !seal_id) {
      throw Error();
    }
    return await this.ajax_state.locked('company_create', corporation_id, async () => {
      const company = Company.from_json(await this.api.create_company(company_name, seal_id));
      this.client_state.core.company_cache.load_companies_metadata(company);
      this.client_state.core.corporation_cache.add_corporation_company(corporation_id, company);
      this.client_state.corporation.add_company_id(company.id);
      return company;
    });
  }

  async load_by_company (company_id: string): Promise<Company> {
    if (!this.client_state.has_session() || !company_id) {
      throw Error();
    }
    const company = this.client_state.core.company_cache.metadata_for_id(company_id);
    if (!!company) {
      return company;
    }
    return await this.ajax_state.locked('company_metadata', company_id, async () => {
      const company = Company.from_json(await this.api.company_for_id(company_id));
      this.client_state.core.company_cache.load_companies_metadata(company);
      return company;
    });
  }
}
