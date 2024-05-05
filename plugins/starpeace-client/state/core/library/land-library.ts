import Library from '~/plugins/starpeace-client/state/core/library/library'
import TextureAtlasCache from '~/plugins/starpeace-client/state/core/texture-atlas-cache'

export default class LandLibrary extends Library {
  texture_cache_by_planet_type: Record<string, TextureAtlasCache> = {};
  metadata_by_planet_type: Record<string, any> = {};

  constructor () {
    super();
  }

  has_metadata (planetType: string): boolean {
    return !!this.metadata_by_planet_type[planetType];
  }
  has_assets (planetType: string): boolean {
    return this.has_metadata(planetType) && this.texture_cache(planetType).has_assets();
  }

  texture_cache (planetType: string): TextureAtlasCache {
    if (!this.texture_cache_by_planet_type[planetType]) {
      this.texture_cache_by_planet_type[planetType] = new TextureAtlasCache();
    }
    return this.texture_cache_by_planet_type[planetType];
  }

  load_land_metadata (landMetadata: any) {
    this.metadata_by_planet_type[landMetadata.planet_type] = landMetadata;
    this.notify_listeners();
  }

  load_required_atlases (planetType: string, atlases: Array<string>) {
    this.texture_cache(planetType).set_required_atlases(atlases);
  }

  load_atlas (planetType: string, atlasKey: string, atlas: any): void {
    this.texture_cache(planetType).load_atlas(atlasKey, atlas);
    this.notify_listeners();
  }

  metadata_for_planet_type (planet_type: string): any | undefined {
    return this.metadata_by_planet_type[planet_type];
  }
}
