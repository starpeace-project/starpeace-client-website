import Library from '~/plugins/starpeace-client/state/core/library/library.js'
import TextureAtlasCache from '~/plugins/starpeace-client/state/core/texture-atlas-cache.js';

export default class PlaneLibrary extends Library {
  texture_cache: TextureAtlasCache;
  metadata_by_id: Record<string, any>;

  constructor () {
    super();

    this.texture_cache = new TextureAtlasCache();
    this.metadata_by_id = {};
  }

  has_metadata (): boolean {
    return Object.keys(this.metadata_by_id).length > 0;
  }
  has_assets (): boolean {
    return this.has_metadata() && this.texture_cache.has_assets();
  }

  load_plane_metadata (plane_metadata: Array<any>): void {
    for (const plane of plane_metadata) {
      this.metadata_by_id[plane.id] = plane;
    }
    this.notify_listeners();
  }

  load_required_atlases (atlases: any): void {
    this.texture_cache.set_required_atlases(atlases);
  }

  load_atlas (atlas_key: string, atlas: any): void {
    this.texture_cache.load_atlas(atlas_key, atlas);
    this.notify_listeners();
  }

  metadata_for_id (id: string): any {
    return this.metadata_by_id[id];
  }
}
