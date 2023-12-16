import _ from 'lodash';
import { v4 as uuidv4 } from 'uuid';

import SandboxApiAdapter from './sandbox-api-adapter';

export interface LoginResponse {
  id: string;
  username: string;
  name: string;
  accessToken: string | null;
}

export default class SandboxApiGalaxy {

  static configure (adapter: SandboxApiAdapter, sandbox: any): void {

    adapter.get('galaxy/metadata', (config: any): any => {
      return _.cloneDeep(sandbox.sandbox_data.galaxy_metadata);
    });

    adapter.post('galaxy/login', (config: any, params: any): LoginResponse => {
      if (params.username == 'test' && params.password == 'test' && sandbox.sandbox_data.corporation.tycoonById['tycoon-id-1']) {
        const access_token: string = uuidv4();
        const tycoonId: string = 'tycoon-id-1';
        sandbox.sandbox_data.access_tokens[access_token] = {
          tycoon_id: tycoonId,
          created_at: new Date().getTime()
        };

        return {
          id: sandbox.sandbox_data.corporation.tycoonById[tycoonId].id,
          username: sandbox.sandbox_data.corporation.tycoonById[tycoonId].username,
          name: sandbox.sandbox_data.corporation.tycoonById[tycoonId].name,
          accessToken: access_token
        };
      }
      else {
        throw new Error('401');
      }
    });

    adapter.post('galaxy/logout', (config: any, params: any) => {
      return {};
    });

  }
}
