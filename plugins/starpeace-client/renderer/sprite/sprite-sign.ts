import { type Sprite as PixiSprite, type Texture } from 'pixi.js';

import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.js';

export default class SpriteSign extends Sprite {
  textures: Texture[];
  info: any;
  metadata: any;

  constructor (textures: Texture[], info: any, metadata: any) {
    super();

    this.textures = textures;
    this.info = info;
    this.metadata = metadata;
  }

  width (viewport: any): number {
    return viewport.with_scale(this.textures[0].width) + 1;
  }
  height (viewport: any): number {
    return Math.ceil(this.textures[0].height * (this.width(viewport) / this.textures[0].width)) + 1;
  }

  render (sprite: PixiSprite, parentSprite: PixiSprite, canvas: any, viewport: any): void {
    const parentX = Math.round(parentSprite.width * this.info.x);
    const parentY = Math.round(parentSprite.height * this.info.y);
    const xOffset = Math.floor(viewport.with_scale(this.metadata.s_x));
    const yOffset = Math.floor(viewport.with_scale(this.metadata.s_y));
    const width = this.width(viewport);
    const height = this.height(viewport);

    sprite.visible = true;
    sprite.alpha = parentSprite.alpha;
    sprite.x = parentSprite.x + parentX - xOffset;
    sprite.y = parentSprite.y + parentY - yOffset;
    sprite.width = width;
    sprite.height = height;
    sprite.tint = 0xFFFFFF;
    sprite.zIndex = parentSprite.zIndex + 1;
  }
}
