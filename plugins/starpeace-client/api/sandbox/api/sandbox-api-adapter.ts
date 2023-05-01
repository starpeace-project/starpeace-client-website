import MockAdapter from 'axios-mock-adapter';

const BASE_HOSTNAME = 'sandbox-galaxy.starpeace.io';
const BASE_PORT = 19160;
const BASE_URL = `http://${BASE_HOSTNAME}:${BASE_PORT}`;

export default class SandboxApiAdapter {
  adapter: MockAdapter;

  constructor (adapter: MockAdapter) {
    this.adapter = adapter;
  }

  static mockRequest (path: string, callback: Function, requestCallback: (requestCallback: RegExp) => any) {
    const url_regex: RegExp = new RegExp(`${BASE_URL}/${path}`);
    requestCallback(url_regex).reply((config: any) => {
      const match = url_regex.exec(config.url);
      const params: any = config?.data ? JSON.parse(config.data) : config?.params ?? {};
      return [200, callback(config, ...(match?.slice(1) || []), params)];
    });
  }

  delete (path: string, callback: Function) {
    return SandboxApiAdapter.mockRequest(path, callback, (url_regex) => this.adapter.onDelete(url_regex));
  }
  get (path: string, callback: Function) {
    return SandboxApiAdapter.mockRequest(path, callback, (url_regex) => this.adapter.onGet(url_regex));
  }
  patch (path: string, callback: Function) {
    return SandboxApiAdapter.mockRequest(path, callback, (url_regex) => this.adapter.onPatch(url_regex));
  }
  put (path: string, callback: Function) {
    return SandboxApiAdapter.mockRequest(path, callback, (url_regex) => this.adapter.onPut(url_regex));
  }
  post (path: string, callback: Function) {
    return SandboxApiAdapter.mockRequest(path, callback, (url_regex) => this.adapter.onPost(url_regex));
  }

}
