import _ from 'lodash';

import SandboxApiAdapter from './sandbox-api-adapter';


export interface CreateVisaResponse {
  id: string;
  identityType: string;
  corporationId: string | null;
}

export default class SandboxApiVisa {

  static configure (adapter: SandboxApiAdapter, sandbox: any): void {

    adapter.post('visa', (config: any, params: any): CreateVisaResponse => {
      const planetId: string = config.headers['PlanetId'];
      if (params.identityType == 'visitor' || params.identityType == 'tycoon') {
        let tycoonId: string | null = null;
        let corporationId: string | null = null;
        const access_token: string | null = config.headers['Authorization']?.split(' ')?.[1];
        if (params.identityType == 'tycoon' && access_token) {
          tycoonId = sandbox.sandbox_data.access_tokens[access_token].tycoon_id;
          corporationId = _.values(sandbox.sandbox_data.corporation.corporationById).find((corporation) => corporation.planetId == planetId && corporation.tycoonId == tycoonId)?.id;
        }

        const visa = {
          id: sandbox.register_session(params.identityType),
          identityType: params.identityType,
          corporationId: corporationId
        };
        sandbox.visasById[visa.id] = _.cloneDeep(visa);
        return visa;
      }
      else {
        throw new Error('400');
      }
    });

  }

}
