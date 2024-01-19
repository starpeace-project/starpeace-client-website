
export default class MetadataEffect {
  id: string;
  atlasKey: string;
  frames: any[];
  sX: number;
  sY: number;

  constructor (id: string, atlasKey: string, frames: any[], sX: number, sY: number) {
    this.id = id;
    this.atlasKey = atlasKey;
    this.frames = frames;
    this.sX = sX;
    this.sY = sY;
  }

  get atlas_key (): string {
    return this.atlasKey;
  }
  get s_x (): number {
    return this.sX;
  }
  get s_y (): number {
    return this.sY;
  }

  static fromJson (json: any): MetadataEffect {
    return new MetadataEffect(
      json.id,
      json.atlas,
      json.frames ?? [],
      json.s_x,
      json.s_y
    );
  }
}
