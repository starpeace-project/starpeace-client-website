import _ from 'lodash';

import EventListener from '~/plugins/starpeace-client/state/event-listener.js';
import GalaxyOptions from './galaxy-options';
import AuthenticationOptions from './authentication-options';


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

const DEFAULT_LANGUAGE = LANGUAGE_FROM_CODE(window?.navigator?.language) ?? 'EN';

const OPTIONS_VERSION = 2;
const OPTIONS = [
  { name: 'general.show_header', type: 'boolean', initial: true },
  { name: 'general.show_fps', type: 'boolean', initial: true },
  { name: 'general.show_mini_map', type: 'boolean', initial: true },
  { name: 'general.language', type: 'string', initial: DEFAULT_LANGUAGE },

  { name: 'music.show_game_music', type: 'boolean', initial: true },
  { name: 'music.volume_muted', type: 'boolean', initial: false },

  { name: 'mini_map.zoom', type: 'number', initial: 1 },
  { name: 'mini_map.width', type: 'number', initial: 300 },
  { name: 'mini_map.height', type: 'number', initial: 200 },

  { name: 'renderer.trees', type: 'boolean', initial: true },
  { name: 'renderer.buildings', type: 'boolean', initial: true },
  { name: 'renderer.building_animations', type: 'boolean', initial: true },
  { name: 'renderer.building_effects', type: 'boolean', initial: true },
  { name: 'renderer.building_anti_alias', type: 'boolean', initial: false },
  { name: 'renderer.planes', type: 'boolean', initial: true },
  { name: 'renderer.webgpu', type: 'boolean', initial: false },

  { name: 'bookmarks.points_of_interest', type: 'boolean', initial: true },
  { name: 'bookmarks.capital', type: 'boolean', initial: true },
  { name: 'bookmarks.towns', type: 'boolean', initial: true },
  { name: 'bookmarks.mausoleums', type: 'boolean', initial: true },
  { name: 'bookmarks.corporation', type: 'boolean', initial: true }
];

export default class Options {
  event_listener: EventListener = new EventListener();

  optionsSaved: Record<string, any> = {};
  optionsActive: Record<string, any> = {};

  galaxy: GalaxyOptions;;
  authentication: AuthenticationOptions;

  constructor () {
    this.galaxy = new GalaxyOptions();
    this.authentication = new AuthenticationOptions(this.galaxy);
  }

  initialize () {
    this.authentication.loadFromStorage();
    this.load();
  }

  subscribe_galaxies_listener (listener_callback: any): void {
    this.galaxy.subscribe_galaxies_listener(listener_callback);
  }
  subscribe_options_listener (listener_callback: any): void {
    this.event_listener.subscribe('options', listener_callback);
  }
  notifyOptionsListeners (changedOptions: string[]): void {
    this.event_listener.notify_listeners('options', { changedOptions: new Set(changedOptions) });
  }

  loadVersion (): number {
    return parseInt(localStorage.getItem('options.version') ?? '0');
  }
  saveVersion (): void {
    localStorage.setItem('options.version', OPTIONS_VERSION.toString());
  }

  load () {
    const version = this.loadVersion();
    const shouldReset = version < OPTIONS_VERSION;

    const changedOptions: string[] = [];
    for (const option of OPTIONS) {
      let initialValue: any | undefined = shouldReset ? undefined : localStorage.getItem(option.name);
      let value: any | undefined = initialValue;

      if (value !== undefined) {
        try {
          if (option.type === 'boolean') {
            value = value === 'true';
          }
          else if (option.type === 'number') {
            value = parseInt(value);
          }
        }
        catch (err) {
          console.warn("Failed to parse option value", err);
          value = option.initial;
        }
      }
      else {
        value = option.initial;
      }

      if (value !== initialValue) {
        changedOptions.push(option.name);
      }
      this.optionsSaved[option.name] = this.optionsActive[option.name] = value;
    }
    this.notifyOptionsListeners(changedOptions);
  }

  reset (): void {
    const changedOptions: string[] = [];
    for (const option of OPTIONS) {
      if (this.optionsActive[option.name] !== option.initial) {
        changedOptions.push(option.name);
      }
      localStorage.removeItem(option.name);
      this.optionsActive[option.name] = option.initial;
    }
    this.saveVersion();
    this.notifyOptionsListeners(changedOptions);
  }

  save (): void {
    const changedOptions: string[] = [];
    for (const option of OPTIONS) {
      if (this.optionsSaved[option.name] !== this.optionsActive[option.name]) {
        changedOptions.push(option.name);
      }
      localStorage.setItem(option.name, this.optionsActive[option.name].toString());
      this.optionsSaved[option.name] = this.optionsActive[option.name];
    }
    this.saveVersion();
    this.notifyOptionsListeners(changedOptions);
  }

  canReset (): boolean {
    let matches = true;
    for (const option of OPTIONS) {
      if (this.optionsActive[option.name] !== option.initial) {
        matches = false;
      }
    }
    return !matches;
  }

  isDirty (): boolean {
    let matches = true;
    for (const option of OPTIONS) {
      if (this.optionsActive[option.name] !== this.optionsSaved[option.name]) {
        matches = false;
      }
    }
    return !matches;
  }

  language (): string {
    return this.optionsActive['general.language'];
  }
  setLanguage (code: string): void {
    this.setAndSaveOption('general.language', LANGUAGES.indexOf(code) >= 0 ? code : 'EN');
  }

  option (name: string): any {
    return this.optionsActive[name];
  }

  setAndSaveOption (name: string, value: any) {
    this.optionsSaved[name] = this.optionsActive[name] = value;
    localStorage.setItem(name, value.toString());
    this.saveVersion();
    this.notifyOptionsListeners([name]);
  }

  toggle (name: string): void {
    this.optionsActive[name] = !this.optionsActive[name];
    this.notifyOptionsListeners([name]);
  }

  getMiniMapZoom (): number {
    const zoom = this.option('mini_map.zoom');
    return _.isNumber(zoom) ? Math.min(2, Math.max(0.25, zoom)) : 0.25;
  }
}
