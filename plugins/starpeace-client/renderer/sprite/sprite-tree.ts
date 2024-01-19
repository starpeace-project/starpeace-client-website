import { type RgbaColor } from 'colord';
import { type Sprite as PixiSprite, type Texture } from 'pixi.js';

import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.js';

const BUFFER_X = 0.5;
const BUFFER_Y = 0.5;

export default class SpriteTree extends Sprite {
  texture: Texture;
  hasData: boolean;
  zoneTint: RgbaColor | undefined;

  constructor (texture: Texture, hasData: boolean, zoneTint: number | undefined) {
    super();

    this.texture = texture;
    this.hasData = hasData;
    this.zoneTint = zoneTint !== undefined ? Sprite.adjustTint(zoneTint, 0.5) : undefined;
  }

  width (viewport: any): number {
    return viewport.tile_width + BUFFER_X;
  }
  height (viewport: any): number {
    return Math.ceil(this.texture.height * (viewport.tile_width / this.texture.width)) + BUFFER_Y;
  }

  render (sprite: PixiSprite, canvas: any, viewport: any): void {
    const width = this.width(viewport);
    const height = this.height(viewport);

    sprite.visible = true;
    sprite.alpha = 1;
    sprite.x = canvas.x - (width - viewport.tile_width);
    sprite.y = canvas.y - (height - viewport.tile_height);
    sprite.width = width;
    sprite.height = height;
    sprite.tint = this.hasData ? (this.zoneTint ?? 0xFFFFFF) : 0x555555;
    //sprite.zIndex = canvas.y + .5 * viewport.tile_height
    sprite.zIndex = sprite.y + sprite.height - Math.round(.5 * viewport.tile_height);
  }
}
