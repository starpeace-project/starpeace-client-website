import _ from 'lodash';

import SandboxApiAdapter from './sandbox-api-adapter';

export interface CorporationIdentifier {
  id: string;
  name: string;
  planetId: string;
}

export interface GetTycoonCorporationsResponse {
  identifiers: CorporationIdentifier[];
}

export interface GetTycoonResponse {
  id: string;
  username: string;
  name: string;
}

export default class SandboxApiTycoon {

  static configure (adapter: SandboxApiAdapter, sandbox: any): void {

    adapter.get('tycoons/(.+?)/corporation-ids', (config: any, tycoonId: string): GetTycoonCorporationsResponse => {
      if (!sandbox.sandbox_data?.corporation_identifiers_by_tycoon_id?.[tycoonId]) {
        throw new Error('404');
      }
      return {
        identifiers: _.cloneDeep(sandbox.sandbox_data.corporation_identifiers_by_tycoon_id[tycoonId])
      };
    });

    adapter.get('tycoons/(.+)', (config: any, tycoonId: string): GetTycoonResponse => {
      if (!sandbox.sandbox_data?.tycoon_by_id?.[tycoonId]) {
        throw new Error('404');
      }
      return {
        id: sandbox.sandbox_data.tycoon_by_id[tycoonId].id,
        username: sandbox.sandbox_data.tycoon_by_id[tycoonId].username,
        name: sandbox.sandbox_data.tycoon_by_id[tycoonId].name
      };
    });

  }
}
