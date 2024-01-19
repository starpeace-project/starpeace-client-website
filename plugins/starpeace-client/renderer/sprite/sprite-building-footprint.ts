import { type Sprite as PixiSprite, type Texture } from 'pixi.js';

import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.js'

export default class SpriteBuildingFootprint extends Sprite {
  texture: Texture;
  imageMetadata: any;
  zoneColor: number;

  constructor (texture: Texture, imageMetadata: any, zoneColor: number) {
    super();

    this.texture = texture;
    this.imageMetadata = imageMetadata;
    this.zoneColor = zoneColor;
  }

  width (viewport: any): number {
    return this.imageMetadata.w * viewport.tile_width - 0.25;
  }
  height (viewport: any): number {
    return Math.ceil(this.texture.height * (this.width(viewport) / this.texture.width)) - 0.25;
  }

  render (sprite: PixiSprite, canvas: any, viewport: any): void {
    const width = this.width(viewport);
    const height = this.height(viewport);

    sprite.visible = true;
    sprite.alpha = 1;
    sprite.x = canvas.x - (width - viewport.tile_width) * .5;
    sprite.y = canvas.y - (height - viewport.tile_height);
    sprite.width = width;
    sprite.height = height;
    sprite.tint = this.zoneColor;
  }
}
