import Cache from '~/plugins/starpeace-client/state/core/cache/cache';

import type Company from '~/plugins/starpeace-client/company/company';

export default class CompanyCache extends Cache {
  companyMetadataById: Record<string, Company>;

  constructor () {
    super();
    this.companyMetadataById = markRaw({}); // TODO: cache?
  }

  resetPlanet (): void {
    this.companyMetadataById = {};
  }

  loadCompaniesMetadata (companies: Array<Company> | Company): void {
    if (Array.isArray(companies)) {
      for (const metadata of companies) {
        this.companyMetadataById[metadata.id] = metadata;
      }
    }
    else {
      this.companyMetadataById[companies.id] = companies;
    }
  }

  metadataForId (companyId: string): Company | undefined {
    return this.companyMetadataById[companyId];
  }

}