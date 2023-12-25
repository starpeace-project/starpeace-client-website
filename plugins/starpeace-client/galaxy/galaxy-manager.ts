
import Galaxy from '~/plugins/starpeace-client/galaxy/galaxy'
import Tycoon from '~/plugins/starpeace-client/tycoon/tycoon'

import AjaxState from '~/plugins/starpeace-client/state/ajax-state';
import ApiClient from '~/plugins/starpeace-client/api/api-client';
import ClientState from '~/plugins/starpeace-client/state/client-state';


export default class GalaxyManager {
  api: ApiClient;
  ajaxState: AjaxState;
  clientState: ClientState;

  constructor (api: ApiClient, ajaxState: AjaxState, clientState: ClientState) {
    this.api = api;
    this.ajaxState = ajaxState;
    this.clientState = clientState;
  }

  async load_metadata (galaxyId: string): Promise<Galaxy> {
    if (!galaxyId) {
      throw Error();
    }
    return await this.ajaxState.locked('galaxy_metadata', galaxyId, async () => {
      const galaxy = Galaxy.fromJson(await this.api.galaxy_metadata(galaxyId));
      this.clientState.core.galaxy_cache.loadGalaxyMetadata(galaxy.id, galaxy);
      return galaxy;
    });
  }

  async create (galaxyId: string, username: string, password: string, rememberMe: boolean): Promise<Tycoon> {
    if (!galaxyId) {
      throw Error();
    }
    return await this.ajaxState.locked('create', galaxyId, async () => {
      const tycoonJson = await this.api.galaxy_create(galaxyId, username, password, rememberMe);
      if (!tycoonJson.accessToken) {
        throw Error('NO_AUTH_TOKEN');
      }

      const tycoon = Tycoon.fromJson(tycoonJson);
      this.clientState.options.authentication.setAuthorization(galaxyId, tycoonJson.accessToken, tycoonJson.refreshToken);
      return tycoon;
    })
  }

  async login (galaxyId: string, username: string, password: string, rememberMe: boolean): Promise<Tycoon> {
    if (!galaxyId || !username || !password) {
      throw Error();
    }
    return await this.ajaxState.locked('login', galaxyId, async () => {
      const tycoonJson = await this.api.galaxyLogin(galaxyId, username, password, rememberMe);
      if (!tycoonJson.accessToken) {
        throw Error('NO_AUTH_TOKEN');
      }

      const tycoon = Tycoon.fromJson(tycoonJson)
      this.clientState.options.authentication.setAuthorization(galaxyId, tycoonJson.accessToken, tycoonJson.refreshToken);
      return tycoon;
    });
  }

  async loginToken (galaxyId: string, token: string): Promise<Tycoon> {
    if (!galaxyId || !token) {
      throw Error();
    }
    return await this.ajaxState.locked('login', galaxyId, async () => {
      const tycoonJson = await this.api.galaxyLoginToken(galaxyId, token);
      if (!tycoonJson.accessToken) {
        throw Error('NO_AUTH_TOKEN');
      }

      const tycoon = Tycoon.fromJson(tycoonJson)
      this.clientState.options.authentication.setAuthorization(galaxyId, tycoonJson.accessToken, tycoonJson.refreshToken);
      return tycoon;
    });
  }

  async logout (galaxyId: string): Promise<void> {
    if (!galaxyId) {
      throw Error();
    }
    return await this.ajaxState.locked('logout', galaxyId, async () => {
      await this.api.galaxy_logout(galaxyId);
      this.clientState.options.authentication.clear_authorization_state()
      // TODO: better handle errors; error_response?.data?.message
    });
  }
}
