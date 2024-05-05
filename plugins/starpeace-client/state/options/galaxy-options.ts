import _ from 'lodash';
import { reactive } from 'vue';

import EventListener from '~/plugins/starpeace-client/state/event-listener.js';
import Utils from '~/plugins/starpeace-client/utils/utils.js';
import Logger from '~/plugins/starpeace-client/logger.js'
import GalaxyConfiguration from '../../galaxy/galaxy-configuration';


const GALAXIES_VERSION = 1;
const GALAXIES_DEFAULT = [
  new GalaxyConfiguration('browser-sandbox', 'http', 'sandbox-galaxy.starpeace.io', 19160),
  new GalaxyConfiguration('api-us-east-1', 'https', 'api-us-east-1.starpeace.io', 443)
];
const GALAXIES_DEFAULT_IDS = new Set(GALAXIES_DEFAULT.map(g => g.id));


export default class GalaxyOptions {
  event_listener: EventListener = new EventListener();

  configurationById: Record<string, GalaxyConfiguration>;

  constructor () {
    this.configurationById = this.loadFromStorage();
  }

  subscribe_galaxies_listener (listener_callback: any): void {
    this.event_listener.subscribe('options.galaxies', listener_callback);
  }
  notify_galaxies_listeners (): void {
    this.event_listener.notify_listeners('options.galaxies');
  }

  loadVersion (): number {
    return parseInt(localStorage.getItem('options.galaxy.version') ?? '0');
  }
  saveVersion (): void {
    localStorage.setItem('options.galaxy.version', GALAXIES_VERSION.toString());
  }

  getGalaxies (): Array<GalaxyConfiguration> {
    return Object.values(this.configurationById);
  }

  loadFromStorage (): Record<string, any> {
    const configurationById: Record<string, GalaxyConfiguration> = {};
    for (const galaxy of GALAXIES_DEFAULT) {
      configurationById[galaxy.id] = galaxy;
    }

    const version = this.loadVersion();
    const raw_galaxies = version < GALAXIES_VERSION ? [] : JSON.parse(localStorage.getItem('galaxies') ?? "[]");
    if (Array.isArray(raw_galaxies)) {
      for (const galaxy of raw_galaxies) {
        if (Array.isArray(galaxy) && galaxy.length == 4) {
          if (!_.isString(galaxy[1]) || _.trim(galaxy[1]).length == 0) {
            console.debug("Galaxy in storage is missing protocol");
            continue;
          }
          if (!_.isString(galaxy[2]) || _.trim(galaxy[2]).length == 0) {
            console.debug("Galaxy in storage is missing domain");
            continue;
          }
          const port = _.isString(galaxy[3]) ? parseInt(galaxy[3]) : galaxy[3];
          if (!_.isNumber(port) || port <= 0) {
            console.debug("Galaxy in storage is missing port");
            continue;
          }

          const id = galaxy[0] ?? Utils.uuid();
          if (configurationById[id] && !GALAXIES_DEFAULT_IDS.has(id)) {
            Logger.warn("duplicate galaxy in storage, will ignore");
          }
          else {
            configurationById[id] = new GalaxyConfiguration(id, galaxy[1], galaxy[2], port);
          }
        }
      }
    }
    return reactive(configurationById);
  }

  save_galaxies_to_storage (): void {
    const galaxies = [];
    for (const galaxy of Object.values(this.configurationById)) {
      galaxies.push([galaxy.id, galaxy.protocol, galaxy.host, galaxy.port]);
    }
    localStorage.setItem('galaxies', JSON.stringify(galaxies));
    this.saveVersion();
    this.notify_galaxies_listeners();
  }

  change_galaxy_id (fromGalaxyId: string, targetGalaxyId: string): void {
    if (!this.configurationById[targetGalaxyId]) {
      this.configurationById[targetGalaxyId] = this.configurationById[fromGalaxyId];
      this.configurationById[targetGalaxyId].id = targetGalaxyId;
      delete this.configurationById[fromGalaxyId];
    }
    this.save_galaxies_to_storage();
  }

  add_galaxy (api_protocol: string, api_url: string, api_port: number): any {
    const galaxy = new GalaxyConfiguration(Utils.uuid(), api_protocol, api_url, api_port);
    this.configurationById[galaxy.id] = galaxy;
    this.save_galaxies_to_storage();
    return galaxy;
  }
  removeGalaxy (id: string): void {
    delete this.configurationById[id];
    this.save_galaxies_to_storage();
  }

}
