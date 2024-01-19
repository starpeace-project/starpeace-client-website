
export default class MetadataPlane {
  id: string;
  atlasKey: string;
  frames: any[];
  w: number;
  h: number;

  constructor (id: string, atlas: string, frames: any[], w: number, h: number) {
    this.id = id;
    this.atlasKey = atlas;
    this.frames = frames;
    this.w = w;
    this.h = h;
  }

  get atlas_key (): string {
    return this.atlasKey;
  }

  static fromJson (json: any): MetadataPlane {
    return new MetadataPlane(
      json.id,
      json.atlas,
      json.frames,
      json.w,
      json.h
    );
  }
}
