import { type RgbaColor } from 'colord';
import { type Sprite as PixiSprite, type Texture } from 'pixi.js';

import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.js'

export default class SpriteConcrete extends Sprite {
  texture: Texture;

  isFlat: boolean;
  isPlatform: boolean;
  zoneTint: RgbaColor | undefined;

  constructor (texture: Texture, isFlat: boolean, isPlatform: boolean, zoneTint: number | undefined) {
    super();

    this.texture = texture;
    this.isFlat = isFlat;
    this.isPlatform = isPlatform;
    this.zoneTint = zoneTint !== undefined ? Sprite.adjustTint(zoneTint, 0.5) : undefined;
  }

  width (viewport: any): number {
    return viewport.tile_width + 1;
  }
  height (viewport: any): number {
    return Math.ceil(this.texture.height * (viewport.tile_width / this.texture.width)) + 1;
  }

  render (sprite: PixiSprite, canvas: any, viewport: any): void {
    const width = this.width(viewport);
    const height = this.height(viewport);
    const offsetY = this.isPlatform ? Math.round(viewport.tile_size_y(.2)) : 0;

    sprite.visible = true;
    sprite.alpha = 1;
    sprite.x = canvas.x - (width - viewport.tile_width);
    sprite.y = canvas.y - (height - viewport.tile_height) + offsetY;
    sprite.width = width;
    sprite.height = height;
    sprite.tint = this.zoneTint ?? 0xFFFFFF;
    //sprite.zIndex = (canvas.y - .5 * viewport.tile_height) - (this.isPlatform ? .25 * viewport.tile_height : 0);
    sprite.zIndex = sprite.y + sprite.height - Math.round(.5 * viewport.tile_height) - (this.isPlatform ? .25 * viewport.tile_height : 0);
  }
}
