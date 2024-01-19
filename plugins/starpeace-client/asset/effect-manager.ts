
import MetadataEffect from '~/plugins/starpeace-client/asset/metadata-effect.js'

import type AssetManager from '~/plugins/starpeace-client/asset/asset-manager.js';
import type AjaxState from '~/plugins/starpeace-client/state/ajax-state.js';
import type ClientState from '~/plugins/starpeace-client/state/client-state.js';


export default class EffectManager {
  assetManager: AssetManager;

  ajaxState: AjaxState;
  clientState: ClientState;

  constructor (assetManager: AssetManager, ajaxState: AjaxState, clientState: ClientState) {
    this.assetManager = assetManager;
    this.ajaxState = ajaxState;
    this.clientState = clientState;
  }

  queue_asset_load (): void {
    if (this.clientState.core.effect_library.has_assets() || this.ajaxState.is_locked('assets.effects_metadata', 'ALL')) {
      return;
    }

    this.ajaxState.lock('assets.effects_metadata', 'ALL');
    this.assetManager.queue('metadata.effect', './effect.metadata.json', (resource) => {
      const effectMetadata: MetadataEffect[] = [];
      for (const [key, json] of Object.entries(resource.effects ?? {})) {
        // FIXME: TODO: add ID to json, change from map to array
        if (!(json as any).id) {
          (json as any).id = key;
        }
        effectMetadata.push(MetadataEffect.fromJson(json));
      }

      this.clientState.core.effect_library.load_effect_metadata(effectMetadata);
      this.clientState.core.effect_library.load_required_atlases(resource.atlas);

      this.assetManager.queue_and_load_atlases(resource.atlas ?? [], (atlasPath, atlas) => this.clientState.core.effect_library.load_atlas(atlasPath, atlas));
      this.ajaxState.unlock('assets.effects_metadata', 'ALL');
    });
  }
}
