import _ from 'lodash'
import axios, { type AxiosInstance } from 'axios'

import SandboxConfiguration from '~/plugins/starpeace-client/api/sandbox/sandbox-configuration.coffee'
import ClientState from '../state/client-state';
import BuildingConnection from '../building/details/building-connection';


export default class ApiClient {
  client_state: ClientState;
  mockConfiguration: SandboxConfiguration;
  client: AxiosInstance;

  constructor (clientState: ClientState) {
    this.client_state = clientState;
    this.mockConfiguration = new SandboxConfiguration(axios);
    axios.defaults.withCredentials = true;
    this.client = axios.create();
  }

  galaxyUrl (galaxyId: string | null = null): string {
    const galaxy_config = this.client_state.core.galaxy_cache.galaxy_configuration(galaxyId ?? this.client_state.identity.galaxy_id);

    if (!galaxy_config?.api_protocol ?? !galaxy_config?.api_url ?? !galaxy_config?.api_port) {
      throw Error(`no configuration for galaxy ${galaxyId}`);
    }
    return `${galaxy_config.api_protocol}://${galaxy_config.api_url}:${galaxy_config.api_port}`;
  }

  galaxyAuth (options: any, galaxyId: string | null = null): any {
    const headers: Record<string, string> = { };

    if (this.client_state.options.galaxy_id == (galaxyId ?? this.client_state.identity.galaxy_id) && this.client_state.options.galaxy_jwt?.length) {
      headers.Authorization = `JWT ${this.client_state.options.galaxy_jwt}`;
    }
    if (this.client_state.player.planet_id?.length) {
      headers.PlanetId = this.client_state.player.planet_id;
    }
    if (this.client_state.player.planet_visa_id?.length) {
      headers.VisaId = this.client_state.player.planet_visa_id;
    }

    return _.assign(options, { headers: headers });
  }

  async handleRequest (requestPromise: Promise<any>, transformResult: (value: any) => any): Promise<any> {
    try {
      const response = await requestPromise;
      return transformResult(response.data);
    }
    catch (err: any) {
      if (!err.status || err.response?.status < 400 && err.response?.status >= 500) {
        this.client_state.handle_connection_error();
      }
      if (err.response?.status === 401 ?? err.response?.status === 403) {
        this.client_state.handle_authorization_error();
      }
      throw err;
    }
  }

  delete (path: string, parameters: any, transformResult: (value: any) => any): Promise<any> {
    return this.handleRequest(this.client.delete(`${this.galaxyUrl()}/${path}`, this.galaxyAuth(parameters)), transformResult);
  }
  get (path: string, query: Record<string, string>, transformResult: (value: any) => any): Promise<any> {
    return this.handleRequest(this.client.get(`${this.galaxyUrl()}/${path}`, this.galaxyAuth({ params: (query ?? {}) })), transformResult);
  }
  getBinary (path: string, query: Record<string, string>, transformResult: (value: any) => any): Promise<any> {
    return this.handleRequest(this.client.get(`${this.galaxyUrl()}/${path}`, this.galaxyAuth({ responseType: 'arraybuffer', params: (query ?? {}) })), transformResult);
  }
  post (path: string, parameters: any, transformResult: (value: any) => any): Promise<any> {
    return this.handleRequest(this.client.post(`${this.galaxyUrl()}/${path}`, parameters, this.galaxyAuth({})), transformResult);
  }
  put (path: string, parameters: any, transformResult: (value: any) => any): Promise<any> {
    return this.handleRequest(this.client.put(`${this.galaxyUrl()}/${path}`, parameters, this.galaxyAuth({})), transformResult);
  }
  patch (path: string, parameters: any, transformResult: (value: any) => any): Promise<any> {
    return this.handleRequest(this.client.patch(`${this.galaxyUrl()}/${path}`, parameters, this.galaxyAuth({})), transformResult);
  }

  async galaxy_metadata (galaxyId: string): Promise<any> {
    try {
      const result = await this.client.get(`${this.galaxyUrl(galaxyId)}/galaxy/metadata`, this.galaxyAuth({}, galaxyId));
      return result.data;
    }
    catch (err) {
      throw err;
    }
  }

  async galaxy_create (galaxyId: string, username: string, password: string, rememberMe: boolean): Promise<any> {
    try {
      const response = await this.client.post(`${this.galaxyUrl(galaxyId)}/galaxy/create`, {
        username: username,
        password: password,
        rememberMe: rememberMe
      });
      return response.data;
    }
    catch (err) {
      throw err;
    }
  }
  async galaxy_login (galaxyId: string, username: string, password: string, rememberMe: boolean): Promise<any> {
    try {
      const response = await this.client.post(`${this.galaxyUrl(galaxyId)}/galaxy/login`, {
        username: username,
        password: password,
        rememberMe: rememberMe
      });
      return response.data;
    }
    catch (err) {
      throw err;
    }
  }
  async galaxy_logout (galaxyId: string) {
    try {
      const response = await this.client.post(`${this.galaxyUrl(galaxyId)}/galaxy/logout`, {}, this.galaxyAuth({}, galaxyId));
      return response.data;
    }
    catch (err) {
      throw err;
    }
  }

  async register_visa (galaxyId: string, visaType: string) {
    try {
      const response = await this.client.post(`${this.galaxyUrl(galaxyId)}/visa`, {
        identityType: visaType
      }, this.galaxyAuth({}, galaxyId));
      return response.data;
    }
    catch (err) {
      throw err;
    }
  }


  buildings_for_planet (chunkX: number, chunkY: number): Promise<any[]> {
    return this.get('buildings', {
      chunkX: chunkX.toString(),
      chunkY: chunkY.toString()
    }, (result) => result ?? []);
  }
  building_for_id (buildingId: string) {
    return this.get(`buildings/${buildingId}`, {}, (result) => result);
  }
  building_details_for_id (buildingId: string) {
    return this.get(`buildings/${buildingId}/details`, {}, (result) => result);
  }
  update_building_details (buildingId: string, settings: any) {
    return this.patch(`buildings/${buildingId}/details`, settings, (result) => result);
  }
  construct_building (companyId: string, definitionId: string, name: string, mapX: number, mapY: number) {
    return this.post('buildings', {
      companyId: companyId,
      definitionId: definitionId,
      name: name,
      mapX: mapX,
      mapY: mapY,
    }, (result) => result);
  }
  demolish_building (buildingId: string): any {
    return this.post(`buildings/${buildingId}/demolish`, {}, (result) => result);
  }
  clone_building (buildingId: string, cloneOptionIds: Array<string>): any {
    return this.post(`buildings/${buildingId}/clone`, {
      cloneOptionIds: cloneOptionIds
    }, (result) => result);
  }
  async buildingConnectionsForId (buildingId: string, type: string, resourceId: string): Promise<BuildingConnection[]> {
    return this.get(`buildings/${buildingId}/connections`, { type, resourceId }, (result) => (result?.connections ?? []).map(BuildingConnection.fromJson));
  }

  building_metadata_for_planet () {
    return this.get('metadata/buildings', {}, (result) => result ?? {});
  }
  core_metadata_for_planet () {
    return this.get('metadata/core', {}, (result) => result ?? {});
  }
  invention_metadata_for_planet () {
    return this.get('metadata/inventions', {}, (result) => result ?? {});
  }

  details_for_planet () {
    return this.get('details', {}, (result) => result ?? []);
  }
  online_tycoons_for_planet () {
    return this.get('online', {}, (result) => result ?? []);
  }
  rankings_for_planet (rankingTypeId: string) {
    return this.get(`rankings/${rankingTypeId}`, {}, (result) => result ?? []);
  }
  search_corporations_for_planet (query: string, startsWithQuery: string) {
    return this.get('search/corporations', { query, startsWithQuery }, (result) => result ?? []);
  }
  search_tycoons_for_planet (query: string, startsWithQuery: string) {
    return this.get('search/tycoons', { query, startsWithQuery }, (result) => result ?? []);
  }
  towns_for_planet () {
    return this.get('towns', {}, (result) => result);
  }
  buildings_for_town (townId: string, industryCategoryId: string, industryTypeId: string) {
    return this.get(`towns/${townId}/buildings`, { industryCategoryId, industryTypeId }, (result) => result ?? []);
  }
  companies_for_town (townId: string) {
    return this.get(`towns/${townId}/companies`, {}, (result) => result ?? []);
  }
  details_for_town (townId: string) {
    return this.get(`towns/${townId}/details`, {}, (result) => result ?? []);
  }

  overlay_data_for_planet (type: string, chunkX: number, chunkY: number) {
    return this.getBinary(`overlay/${type}`, {
        chunkX: chunkX.toString(),
        chunkY: chunkY.toString()
      }, (result) => result ? new Uint8Array(result) : null);
  }

  road_data_for_planet (chunkX: number, chunkY: number) {
    return this.getBinary('roads', {
      chunkX: chunkX.toString(),
      chunkY: chunkY.toString()
    }, (result) => result ? new Uint8Array(result) : null);
  }

  tycoon_for_id (tycoonId: string) {
    return this.get(`tycoons/${tycoonId}`, {}, (result) => result);
  }
  corporation_identifiers_for_tycoon_id (tycoonId: string) {
    return this.get(`tycoons/${tycoonId}/corporation-ids`, {}, (result) => result?.identifiers ?? []);
  }

  create_corporation (corporationName: string) {
    return this.post('corporations', { name: corporationName }, (result) => result);
  }
  corporation_for_id (corporationId: string) {
    return this.get(`corporations/${corporationId}`, {}, (result) => result);
  }

  corporation_rankings_for_id (corporationId: string) {
    return this.get(`corporations/${corporationId}/rankings`, {}, (result) => result ?? []);
  }
  corporation_prestige_history_for_id (corporationId: string) {
    return this.get(`corporations/${corporationId}/prestige-history`, {}, (result) => result ?? []);
  }
  corporation_strategies_for_id (corporationId: string) {
    return this.get(`corporations/${corporationId}/strategies`, {}, (result) => result ?? []);
  }

  corporation_loan_payments_for_id (corporationId: string) {
    return this.get(`corporations/${corporationId}/loan-payments`, {}, (result) => result ?? []);
  }
  corporation_loan_offers_for_id (corporationId: string) {
    return this.get(`corporations/${corporationId}/loan-offers`, {}, (result) => result ?? []);
  }


  bookmarks_for_corporation (corporationId: string) {
    return this.get(`corporations/${corporationId}/bookmarks`, {}, (result) => result ?? []);
  }
  create_corporation_bookmark (corporationId: string, type: string, parentId: string, order: number, name: string, extra_params={}) {
    return this.post(`corporations/${corporationId}/bookmarks`, _.merge({
        type: type,
        parentId: parentId,
        order: order,
        name: name
      }, extra_params), (result) => result);
  }
  update_corporation_bookmarks (corporationId: string, bookmarkDeltas: any[]) {
    return this.patch(`corporations/${corporationId}/bookmarks`, {
        deltas: bookmarkDeltas
      }, (result) => result);
  }

  mail_for_corporation (corporationId: string) {
    return this.get(`corporations/${corporationId}/mail`, {}, (result) => result ?? [])
  }
  send_mail (corporationId: string, to: string, subject: string, body: string) {
    return this.post(`corporations/${corporationId}/mail`, {
        to: to,
        subject: subject,
        body: body
      }, (result) => result);
  }
  mark_mail_read (corporationId: string, mailId: string) {
    return this.put(`corporations/${corporationId}/mail/${mailId}/mark-read`, {}, (result) => result);
  }
  delete_mail (corporationId: string, mailId: string) {
    return this.delete(`corporations/${corporationId}/mail/${mailId}`, {}, (result) => result);
  }


  create_company (companyName: string, sealId: string) {
    return this.post('companies', { name: companyName, sealId: sealId }, (result) => result);
  }
  company_for_id (companyId: string) {
    return this.get(`companies/${companyId}`, {}, (result) => result);
  }
  buildings_for_company (companyId: string) {
    return this.get(`companies/${companyId}/buildings`, {}, (result) => result ?? []);
  }
  inventions_for_company (companyId: string) {
    return this.get(`companies/${companyId}/inventions`, {}, (result) => result ?? []);
  }
  queue_company_invention (companyId: string, inventionId: string) {
    return this.put(`companies/${companyId}/inventions/${inventionId}`, {}, (result) => result);
  }
  sell_company_invention (companyId: string, inventionId: string) {
    return this.delete(`companies/${companyId}/inventions/${inventionId}`, {}, (result) => result);
  }
}
