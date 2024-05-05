import Library from '~/plugins/starpeace-client/state/core/library/library'
import TextureAtlasCache from '~/plugins/starpeace-client/state/core/texture-atlas-cache'

export default class SignLibrary extends Library {
  texture_cache: TextureAtlasCache = new TextureAtlasCache();
  metadata_by_id: Record<string, any> = {};

  constructor () {
    super();
  }

  has_metadata (): boolean {
    return Object.keys(this.metadata_by_id).length > 0;
  }
  has_assets (): boolean {
    return this.has_metadata() && this.texture_cache.has_assets();
  }

  load_sign_metadata (signMetadata: Array<any>): void {
    for (const sign of signMetadata) {
      this.metadata_by_id[sign.id] = sign;
      this.notify_listeners();
    }
  }

  load_required_atlases (atlases: Array<string>) {
    this.texture_cache.set_required_atlases(atlases);
  }

  load_atlas (atlasKey: string, atlas: any): void {
    this.texture_cache.load_atlas(atlasKey, atlas);
    this.notify_listeners();
  }
}
