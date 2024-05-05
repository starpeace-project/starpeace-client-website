import Library from '~/plugins/starpeace-client/state/core/library/library'

export default class MapLibrary extends Library {
  texture_by_map_id: Record<string, any> = {};
  towns_texture_by_map_id: Record<string, any> = {};

  constructor () {
    super();
  }

  has_assets (mapId: string): boolean {
    return !!this.texture_by_map_id[mapId] && !!this.towns_texture_by_map_id[mapId];
  }

  texture_for_id (mapId: string): any {
    return this.texture_by_map_id[mapId];
  }
  load_map_texture (mapId: string, texture: any): void {
    this.texture_by_map_id[mapId] = texture;
    this.notify_listeners();
  }

  towns_texture_for_id (mapId: string): any | undefined {
    return this.towns_texture_by_map_id[mapId];
  }
  load_map_towns_texture (mapId: string, texture: any): void {
    this.towns_texture_by_map_id[mapId] = texture;
    this.notify_listeners();
  }
}
