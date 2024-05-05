
export default class TextureAtlasCache {
  required_atlases: Array<string> | undefined = undefined;
  loaded_atlases: Record<string, any> = {};

  textures_by_item_id: Record<string, any> = {};

  reset_state (): void {
    this.required_atlases = undefined;
    this.loaded_atlases = {};

    this.textures_by_item_id = {};
  }

  has_assets (): boolean {
    return !!this.required_atlases && this.required_atlases.length === Object.keys(this.loaded_atlases).length;
  }

  set_required_atlases (required_atlases: Array<string>): void {
    if (!Array.isArray(required_atlases)) {
      throw "Expected array of atlases";
    }
    this.required_atlases = required_atlases;
  }

  load_atlas (atlas_key: string, atlas: any): void {
    this.loaded_atlases[atlas_key] = atlas;
  }

}
