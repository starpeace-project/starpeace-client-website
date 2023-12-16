import _ from 'lodash';
import { reactive } from 'vue';

import EventListener from '~/plugins/starpeace-client/state/event-listener.js';
import Utils from '~/plugins/starpeace-client/utils/utils.js';
import Logger from '~/plugins/starpeace-client/logger.js'

const LANGUAGES = ['DE', 'EN', 'ES', 'FR', 'IT', 'PT'];
const LANGUAGE_FROM_CODE = (code: string | undefined | null) => {
  if (!code) {
    return 'EN';
  }
  if (code.indexOf('-') >= 0) {
    code = code.split('-')[0].toUpperCase();
  }
  return LANGUAGES.indexOf(code) >= 0 ? code : 'EN';
}

const DEFAULT_LANGAUGE = 'EN';
const DEFAULT_LANGUAGE = LANGUAGE_FROM_CODE(window?.navigator?.language);

const AUTH_GALAXY_HASH = 'galaxy.hash';
const AUTH_GALAXY_JWT = 'galaxy.jwt';
const AUTH_GALAXY_TOKEN = 'galaxy.token';

const OPTIONS = [
  {name: 'general.show_header', _default: true},
  {name: 'general.show_fps', _default: true},
  {name: 'general.show_mini_map', _default: true},
  {name: 'general.language', _default: DEFAULT_LANGAUGE},

  {name: 'music.show_game_music', _default: true},
  {name: 'music.volume_muted', _default: false},

  {name: 'mini_map.zoom', _default: 1},
  {name: 'mini_map.width', _default: 300},
  {name: 'mini_map.height', _default: 200},

  {name: 'renderer.trees', _default: true},
  {name: 'renderer.buildings', _default: true},
  {name: 'renderer.building_animations', _default: true},
  {name: 'renderer.building_effects', _default: true},
  {name: 'renderer.planes', _default: true},

  {name: 'bookmarks.points_of_interest', _default: true},
  {name: 'bookmarks.capital', _default: true},
  {name: 'bookmarks.towns', _default: true},
  {name: 'bookmarks.mausoleums', _default: true},
  {name: 'bookmarks.corporation', _default: true}
];

export default class Options {
  event_listener: EventListener = new EventListener();

  options_saved: Record<string, any> = {};
  options_current: Record<string, any> = {};

  galaxies_by_id: Record<string, any>;

  galaxy_id: string | null = null;
  galaxy_jwt: string | null = null;
  galaxy_token: string | null = null;

  constructor () {
    this.galaxies_by_id = this.load_galaxies_from_storage();
  }

  initialize () {
    this.load_authorization_state();
    this.load_state();
  }

  subscribe_galaxies_listener (listener_callback: any): void {
    this.event_listener.subscribe('options.galaxies', listener_callback);
  }
  notify_galaxies_listeners (): void {
    this.event_listener.notify_listeners('options.galaxies');
  }
  subscribe_options_listener (listener_callback: any): void {
    this.event_listener.subscribe('options', listener_callback);
  }
  notify_options_listeners (): void {
    this.event_listener.notify_listeners('options');
  }

  get_galaxies (): Array<any> {
    return Object.values(this.galaxies_by_id);
  }

  load_galaxies_from_storage (): Record<string, any> {
    const galaxies_by_id: Record<string, any> = {};
    galaxies_by_id['browser-sandbox'] = {
      id: 'browser-sandbox',
      api_protocol: 'http',
      api_url: 'sandbox-galaxy.starpeace.io',
      api_port: 19160
    };

    const raw_galaxies = JSON.parse(localStorage.getItem('galaxies') ?? "[]");
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
          if (galaxies_by_id[id] && id !== 'browser-sandbox') {
            Logger.warn("duplicate galaxy in storage, will ignore");
          }
          else
            galaxies_by_id[id] = {
              id: id,
              api_protocol: galaxy[1],
              api_url: galaxy[2],
              api_port: port
            }
        }
      }
    }
    return reactive(galaxies_by_id);
  }

  save_galaxies_to_storage (): void {
    const galaxies = [];
    for (const [galaxy_id, galaxy] of Object.entries(this.galaxies_by_id)) {
      if (galaxy_id !== galaxy.id) {
        console.debug("Galaxy has a different ID");
      }
      galaxies.push([galaxy.id, galaxy.api_protocol, galaxy.api_url, galaxy.api_port]);
    }
    localStorage.setItem('galaxies', JSON.stringify(galaxies));
    this.notify_galaxies_listeners();
  }

  change_galaxy_id (old_galaxy_id: string, new_galaxy_id: string): void {
    if (this.galaxies_by_id[new_galaxy_id]) {
      Logger.warn("galaxy id in use, unable to update existing");
    }
    else {
      const galaxy = this.galaxies_by_id[old_galaxy_id];
      delete this.galaxies_by_id[old_galaxy_id];
      this.galaxies_by_id[new_galaxy_id] = galaxy;
    }
    this.save_galaxies_to_storage();
  }

  add_galaxy (api_protocol: string, api_url: string, api_port: number): any {
    const galaxy = {
      id: Utils.uuid(),
      api_protocol: api_protocol,
      api_url: api_url,
      api_port: api_port
    }
    this.galaxies_by_id[galaxy.id] = galaxy;
    this.save_galaxies_to_storage();
    return galaxy;
  }
  remove_galaxy (id: string): void {
    delete this.galaxies_by_id[id];
    this.save_galaxies_to_storage();
  }

  galaxy_to_hash (galaxy: any): string {
    return btoa(`${galaxy.id}|${galaxy.api_protocol}|${galaxy.api_url}|${galaxy.api_port}`);
  }
  galaxy_from_hash (hash: any): any {
    const hash_parts = atob(hash).split('|');
    if (hash_parts.length == 4) {
      return {
        id: hash_parts[0],
        api_protocol: hash_parts[1],
        api_url: hash_parts[2],
        api_port: parseInt(hash_parts[3])
      }
    }
    return false;
  }

  load_authorization_state () {
    const hash = localStorage.getItem(AUTH_GALAXY_HASH);
    const hash_galaxy = this.galaxy_from_hash(hash);
    if (hash_galaxy && this.galaxies_by_id[hash_galaxy.id] && this.galaxy_to_hash(this.galaxies_by_id[hash_galaxy.id]) == hash) {
      this.galaxy_id = hash_galaxy.id;
      this.galaxy_jwt = localStorage.getItem(AUTH_GALAXY_JWT);
      this.galaxy_token = localStorage.getItem(AUTH_GALAXY_TOKEN);
    }
    else {
      this.clear_authorization_state();
    }
  }

  set_authorization_state (galaxy_id: string, auth_token: string | null, refresh_token: string | null) {
    if (!this.galaxies_by_id[galaxy_id]) {
      return;
    }

    this.galaxy_id = galaxy_id;
    this.galaxy_jwt = auth_token;
    this.galaxy_token = refresh_token;

    localStorage.setItem(AUTH_GALAXY_HASH, this.galaxy_to_hash(this.galaxies_by_id[this.galaxy_id]));
    if (this.galaxy_jwt?.length) {
      localStorage.setItem(AUTH_GALAXY_JWT, this.galaxy_jwt);
    }
    else {
      localStorage.removeItem(AUTH_GALAXY_JWT)
    }
    if (this.galaxy_token?.length) {
      localStorage.setItem(AUTH_GALAXY_TOKEN, this.galaxy_token);
    }
    else {
      localStorage.removeItem(AUTH_GALAXY_TOKEN);
    }
  }

  clear_authorization_state () {
    this.galaxy_id = null;
    this.galaxy_jwt = null;
    this.galaxy_token = null;
    localStorage.removeItem(AUTH_GALAXY_HASH);
    localStorage.removeItem(AUTH_GALAXY_JWT);
    localStorage.removeItem(AUTH_GALAXY_TOKEN);
  }


  load_state () {
    for (const option of OPTIONS) {
      let saved_value: any = localStorage.getItem(option.name) ?? option._default;
      if (typeof option._default === 'number' && isFinite(option._default as number)) {
        saved_value = parseInt(saved_value);
      }
      else if (typeof option._default === 'boolean') {
        saved_value = saved_value === 'true';
      }
      this.options_saved[option.name] = this.options_current[option.name] = saved_value;
    }
    this.notify_options_listeners();
  }

  reset_state (): void {
    for (const option of OPTIONS) {
      localStorage.removeItem(option.name);
      this.options_current[option.name] = option._default;
    }
    this.notify_options_listeners();
  }

  save_state (): void {
    for (const option of OPTIONS) {
      localStorage.setItem(option.name, this.options_current[option.name].toString());
      this.options_saved[option.name] = this.options_current[option.name];
    }
    this.notify_options_listeners();
  }

  can_reset (): boolean {
    let matches_default = true;
    for (const option of OPTIONS) {
      if (!this.options_current[option.name] === option._default) {
        matches_default = false;
      }
    }
    return !matches_default;
  }

  is_dirty (): boolean {
    let matches_saved = true;
    for (const option of OPTIONS) {
      if (this.options_current[option.name] !== this.options_saved[option.name]) {
        matches_saved = false;
      }
    }
    return !matches_saved;
  }

  language (): string {
    return this.options_current['general.language'];
  }
  set_language (code: string): void {
    this.set_and_save_option('general.language', LANGUAGES.indexOf(code) >= 0 ? code : 'EN');
  }

  option (name): any {
    return this.options_current[name];
  }

  set_and_save_option (name: string, value: any) {
    this.options_saved[name] = this.options_current[name] = value;
    localStorage.setItem(name, value.toString());
    this.notify_options_listeners();
  }

  toggle (name): void {
    this.options_current[name] = !this.options_current[name];
    this.notify_options_listeners();
  }

  get_mini_map_zoom (): number {
    const zoom = this.option('mini_map.zoom');
    return _.isNumber(zoom) ? Math.min(2, Math.max(0.25, zoom)) : 0.25;
  }
}
