import _ from 'lodash';

import GalaxyConfiguration from '../../galaxy/galaxy-configuration';
import GalaxyOptions from './galaxy-options';

const AUTH_GALAXY_HASH = 'galaxy.hash';
const AUTH_GALAXY_JWT = 'galaxy.jwt';
const AUTH_GALAXY_USERNAME = 'galaxy.username';
const AUTH_GALAXY_TOKEN = 'galaxy.token';

function localStorageToggle (key: string, value: string | undefined): void {
  if (value?.length) {
    localStorage.setItem(key, value);
  }
  else {
    localStorage.removeItem(key);
  }
}

export default class AuthenticationOptions {
  galaxyOptions: GalaxyOptions;

  galaxyId: string | undefined = undefined;
  galaxyJwt: string | undefined = undefined;
  galaxyUsername: string | undefined = undefined;
  galaxyToken: string | undefined = undefined;

  constructor (galaxyOptions: GalaxyOptions) {
    this.galaxyOptions = galaxyOptions;
  }

  loadFromStorage () {
    const hash = localStorage.getItem(AUTH_GALAXY_HASH) ?? undefined;
    const galaxy = GalaxyConfiguration.fromHash(hash);
    if (galaxy && this.galaxyOptions.configurationById[galaxy.id]?.hash === hash) {
      this.galaxyId = galaxy.id;
      this.galaxyJwt = localStorage.getItem(AUTH_GALAXY_JWT) ?? undefined;
      this.galaxyUsername = localStorage.getItem(AUTH_GALAXY_USERNAME) ?? undefined;
      this.galaxyToken = localStorage.getItem(AUTH_GALAXY_TOKEN) ?? undefined;
    }
    else {
      const c = galaxy ? this.galaxyOptions.configurationById[galaxy.id] : undefined;
      this.clear_authorization_state();
    }
  }

  setAuthorization (galaxyId: string, jwtToken: string | undefined, username: string | undefined, refreshToken: string | undefined) {
    this.galaxyId = galaxyId;
    this.galaxyJwt = jwtToken ?? undefined;
    this.galaxyUsername = username ?? undefined;
    this.galaxyToken = refreshToken ?? undefined;
    localStorageToggle(AUTH_GALAXY_HASH, this.galaxyOptions.configurationById[galaxyId].hash);
    localStorageToggle(AUTH_GALAXY_JWT, this.galaxyJwt);
    localStorageToggle(AUTH_GALAXY_USERNAME, this.galaxyUsername);
    localStorageToggle(AUTH_GALAXY_TOKEN, this.galaxyToken);
  }

  clear_authorization_state () {
    this.galaxyId = undefined;
    this.galaxyJwt = undefined;
    this.galaxyJwt = undefined;
    this.galaxyToken = undefined;
    localStorage.removeItem(AUTH_GALAXY_HASH);
    localStorage.removeItem(AUTH_GALAXY_JWT);
    localStorage.removeItem(AUTH_GALAXY_USERNAME);
    localStorage.removeItem(AUTH_GALAXY_TOKEN);
  }

}
