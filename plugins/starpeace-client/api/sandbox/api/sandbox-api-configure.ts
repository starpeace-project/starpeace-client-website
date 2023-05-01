import { AxiosInstance } from 'axios';
import MockAdapter from 'axios-mock-adapter';

import SandboxApiAdapter from '~/plugins/starpeace-client/api/sandbox/api/sandbox-api-adapter';
import SandboxApiCorporation from '~/plugins/starpeace-client/api/sandbox/api/sandbox-api-corporation';
import SandboxApiGalaxy from '~/plugins/starpeace-client/api/sandbox/api/sandbox-api-galaxy';
import SandboxApiTycoon from '~/plugins/starpeace-client/api/sandbox/api/sandbox-api-tycoon';
import SandboxApiVisa from '~/plugins/starpeace-client/api/sandbox/api/sandbox-api-visa';


export default class SandboxApiConfigure {

  static configure (mockAdapter: MockAdapter, sandbox: any): void {
    const adapter: SandboxApiAdapter = new SandboxApiAdapter(mockAdapter);

    SandboxApiGalaxy.configure(adapter, sandbox);
    SandboxApiVisa.configure(adapter, sandbox);
    SandboxApiTycoon.configure(adapter, sandbox);
    SandboxApiCorporation.configure(adapter, sandbox);

  }

}
