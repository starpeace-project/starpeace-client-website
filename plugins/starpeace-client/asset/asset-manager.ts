import { Assets } from '@pixi/assets';

import Logger from '~/plugins/starpeace-client/logger'
import AjaxState from '~/plugins/starpeace-client/state/ajax-state';

export default class AssetManager {
  static CDN_URL: string = 'https://cdn.starpeace.io';
  static CDN_VERSION: string = '6d8ed62d91142c61f84c52efa4f5ae0c';

  ajaxState: AjaxState;
  loading: boolean;
  key_callbacks: Record<string, (resource: any) => any>;
  loaded_keys: Set<string>;

  constructor (ajaxState: AjaxState) {
    Assets.init({
      basePath: `${AssetManager.CDN_URL}/${AssetManager.CDN_VERSION}`
    });

    this.ajaxState = ajaxState;
    this.loading = false;
    this.key_callbacks = {};
    this.loaded_keys = new Set();
  }

  planet_animation_url (planet: any): string {
    return `${AssetManager.CDN_URL}/${AssetManager.CDN_VERSION}/map.${planet.map_id}.animation.gif`;
  }

  queue (key: string, asset_url: string, callback: (resource: any) => any) {
    if (this.loaded_keys.has(key)) {
      Logger.debug(`attempted to load same key more than once: ${key}`);
      return callback(Assets.get(key));
    }

    Assets.add({ alias: key, src: asset_url })
    this.key_callbacks[key] = callback;
  }

  async load_queued () {
    const pending_keys = Object.keys(this.key_callbacks);
    if (!pending_keys.length || this.loading) {
      return;
    }

    this.loading = true;
    this.ajaxState.start_ajax();
    try {
      const resources = await Assets.load(pending_keys, (progress) => console.debug('Asset loading progress', progress));

      for (const key of pending_keys) {
        if (resources[key]) {
          this.key_callbacks[key](resources[key]);
          this.loaded_keys.add(key);
          delete this.key_callbacks[key];
        }
      }

      this.ajaxState.finish_ajax();
      this.loading = false;

      if (Object.keys(this.key_callbacks).length) {
        setTimeout(() => this.load_queued(), 250);
      }
    }
    catch (err) {
      console.error(err);
      this.loading = false;
    }
  }

  queue_and_load_atlases (atlases: Array<string>, callback: (path: string, resource: any) => any): void {
    for (const path of atlases) {
      this.queue(path, path, (resource) => callback(path, resource));
    }
    this.load_queued();
  }
}
