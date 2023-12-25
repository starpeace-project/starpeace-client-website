import _ from 'lodash';

import GalaxyConfiguration from '../../galaxy/galaxy-configuration';
import GalaxyOptions from './galaxy-options';

const AUTH_GALAXY_HASH = 'galaxy.hash';
const AUTH_GALAXY_JWT = 'galaxy.jwt';
const AUTH_GALAXY_TOKEN = 'galaxy.token';

export default class AuthenticationOptions {
  galaxyOptions: GalaxyOptions;

  galaxyId: string | undefined = undefined;
  galaxyJwt: string | undefined = undefined;
  galaxyToken: string | undefined = undefined;

  constructor (galaxyOptions: GalaxyOptions) {
    this.galaxyOptions = galaxyOptions;
  }

  static galaxyFromHash (hash: any): GalaxyConfiguration | undefined {
    const hash_parts = atob(hash).split('|');
    if (hash_parts.length == 4) {
      return new GalaxyConfiguration(hash_parts[0], hash_parts[1], hash_parts[2], parseInt(hash_parts[3]));
    }
    return undefined;
  }

  hashFromGalaxy (galaxyId: string): string {
    const galaxy = this.galaxyOptions.configurationById[galaxyId];
    return btoa(`${galaxy.id}|${galaxy.protocol}|${galaxy.host}|${galaxy.port}`);
  }

  loadFromStorage () {
    const hash = localStorage.getItem(AUTH_GALAXY_HASH);
    const galaxy = AuthenticationOptions.galaxyFromHash(hash);
    if (galaxy && this.galaxyOptions.configurationById[galaxy.id] && this.hashFromGalaxy(galaxy.id) == hash) {
      this.galaxyId = galaxy.id;
      this.galaxyJwt = localStorage.getItem(AUTH_GALAXY_JWT) ?? undefined;
      this.galaxyToken = localStorage.getItem(AUTH_GALAXY_TOKEN) ?? undefined;
    }
    else {
      this.clear_authorization_state();
    }
  }

  setAuthorization (galaxyId: string, jwtToken: string | null, refreshToken: string | null) {
    this.galaxyId = galaxyId;
    this.galaxyJwt = jwtToken ?? undefined;
    this.galaxyToken = refreshToken ?? undefined;

    localStorage.setItem(AUTH_GALAXY_HASH, this.hashFromGalaxy(this.galaxyId));
    if (this.galaxyJwt?.length) {
      localStorage.setItem(AUTH_GALAXY_JWT, this.galaxyJwt);
    }
    else {
      localStorage.removeItem(AUTH_GALAXY_JWT)
    }
    if (this.galaxyToken?.length) {
      localStorage.setItem(AUTH_GALAXY_TOKEN, this.galaxyToken);
    }
    else {
      localStorage.removeItem(AUTH_GALAXY_TOKEN);
    }
  }

  clear_authorization_state () {
    this.galaxyId = undefined;
    this.galaxyJwt = undefined;
    this.galaxyToken = undefined;
    localStorage.removeItem(AUTH_GALAXY_HASH);
    localStorage.removeItem(AUTH_GALAXY_JWT);
    localStorage.removeItem(AUTH_GALAXY_TOKEN);
  }

}
