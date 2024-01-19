import { type RgbaColor } from 'colord';
import { type Sprite as PixiSprite, type Texture } from 'pixi.js';

import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.js';

export default class SpriteRoad extends Sprite {
  texture: Texture;

  isBridge: boolean;
  isOverWater: boolean;
  zoneTint: RgbaColor | undefined;

  constructor (texture: Texture, isBridge: boolean, isOverWater: boolean, zoneTint: number | undefined) {
    super();

    this.texture = texture;
    this.isBridge = isBridge;
    this.isOverWater = isOverWater;
    this.zoneTint = zoneTint !== undefined ? Sprite.adjustTint(zoneTint, 0.5) : undefined;
  }

  width (viewport: any): number {
    return viewport.tile_width + 1;
  }
  height (viewport: any): number {
    if (this.isBridge) {
      return Math.ceil(this.texture.height * (viewport.tile_width / this.texture.width));
    }
    return viewport.tile_height + 1;
  }

  render (sprite: PixiSprite, canvas: any, viewport: any): void {
    const width = this.width(viewport);
    const height = this.height(viewport);

    // TODO: does .5625 work better?
    const offsetY = !this.isBridge && this.isOverWater ? Math.round(viewport.tile_size_y(.375)) : 0;

    sprite.visible = true;
    sprite.alpha = 1;
    sprite.x = canvas.x - (width - viewport.tile_width);
    sprite.y = canvas.y - (height - viewport.tile_height) - offsetY;
    sprite.width = width;
    sprite.height = height;
    sprite.tint = (this.zoneTint ?? 0xFFFFFF);
    //sprite.zIndex = (canvas.y - .5 * viewport.tile_height)# + (if @is_over_water || @is_bridge then viewport.tile_height else 0)
    sprite.zIndex = sprite.y + sprite.height + offsetY - Math.round(.5 * viewport.tile_height);// - (if @is_platform then .25 * viewport.tile_height else 0);
  }
}
