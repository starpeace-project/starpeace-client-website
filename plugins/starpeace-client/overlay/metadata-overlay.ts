
export default class MetadataOverlay {
  id: string;
  atlas_key: string;
  frames: Array<any>;

  constructor (id: string, atlas_key: string, frames: Array<any>) {
    this.id = id;
    this.atlas_key = atlas_key;
    this.frames = frames;
  }

  static from_json (json: any): MetadataOverlay {
    return new MetadataOverlay(
      json.id,
      json.atlas,
      json.frames
    );
  }
}
