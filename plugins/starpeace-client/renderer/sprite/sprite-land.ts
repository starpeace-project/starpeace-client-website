import { type RgbaColor } from 'colord';
import { type Sprite as PixiSprite, type Texture } from 'pixi.js';

import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.js'

export default class SpriteLand extends Sprite {
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
    return viewport.tile_width + 1;
  }
  height (viewport: any): number {
    return viewport.tile_height + 1;
  }

  render (sprite: PixiSprite, canvas: any, viewport: any) {
    const width = this.width(viewport);
    const height = this.height(viewport);

    sprite.visible = true;
    sprite.alpha = 1;
    sprite.x = canvas.x - (width - viewport.tile_width);
    sprite.y = canvas.y - (height - viewport.tile_height);
    sprite.width = width + 1;
    sprite.height = height + 1;
    sprite.tint = this.hasData ? (this.zoneTint ?? 0xFFFFFF) : 0x555555;
  }
}
