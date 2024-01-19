import { type Sprite as PixiSprite, type Texture } from 'pixi.js';

import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.js';

export default class SpriteOverlay extends Sprite {
  texture: Texture;
  colorTint: number;

  constructor (texture: Texture, colorTint: number) {
    super();

    this.texture = texture;
    this.colorTint = colorTint;
  }

  width (viewport: any): number {
    return viewport.tile_width - 0.5;
  }
  height (viewport: any): number {
    return viewport.tile_height - 0.5;
  }

  render (sprite: PixiSprite, parentZorder: number, oversizedParent: boolean, canvas: any, viewport: any): void {
    const width = this.width(viewport) + (oversizedParent ? 1 : 0);
    const height = this.height(viewport) + (oversizedParent ? 1 : 0);

    sprite.visible = true;
    sprite.alpha = 0.5;
    sprite.x = canvas.x - (width - viewport.tile_width) * .5;
    sprite.y = canvas.y - (height - viewport.tile_height);
    sprite.width = width;
    sprite.height = height;
    sprite.tint = this.colorTint;
    sprite.zIndex = (parentZorder > 0 ? parentZorder : (sprite.y + sprite.height - viewport.tile_height)) + 1;
  }
}
