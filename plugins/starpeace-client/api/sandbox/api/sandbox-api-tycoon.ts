import _ from 'lodash';

import SandboxApiAdapter from './sandbox-api-adapter';
import Utils from '~/plugins/starpeace-client/utils/utils';

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
      return {
        identifiers: _.cloneDeep(sandbox.sandbox_data.corporation.corporationIdentifiersByTycoonId?.[tycoonId] ?? [])
      };
    });

    adapter.get('tycoons/(.+)', (config: any, tycoonId: string): GetTycoonResponse => {
      if (!sandbox.sandbox_data?.corporation.tycoonById?.[tycoonId]) {
        return {
          id: tycoonId,
          username: "Unknown " + Utils.uuid(),
          name: "Name " + Utils.uuid()
        };
      }
      return {
        id: sandbox.sandbox_data.corporation.tycoonById[tycoonId].id,
        username: sandbox.sandbox_data.corporation.tycoonById[tycoonId].username,
        name: sandbox.sandbox_data.corporation.tycoonById[tycoonId].name
      };
    });

  }
}
