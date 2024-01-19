import { Polygon, type Sprite as PixiSprite, type Texture } from 'pixi.js';

import CompositePolygon from '~/plugins/pixi/composite-polygon'
import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.js'

export default class SpriteBuildingConstruction extends Sprite {
  textures: Texture[];

  isAnimated: boolean;
  isValid: boolean;

  imageMetadata: any;

  hitAreaParts: any[];

  constructor (textures: Texture[], isAnimated: boolean, isValid: boolean, imageMetadata: any) {
    super()

    this.textures = textures;

    this.isAnimated = isAnimated;
    this.isValid = isValid;

    this.imageMetadata = imageMetadata;

    this.hitAreaParts = this.imageMetadata.hit_area ?? [];
  }

  width (viewport: any): number {
    return this.imageMetadata.w * viewport.tile_width + 1;
  }
  height (viewport: any): number {
    return Math.ceil(this.textures[0].height * (this.width(viewport) / this.textures[0].width)) + 1;
  }

  hitArea (_viewport: any): Polygon | undefined {
    if (this.hitAreaParts.length > 0) {
      // FIXME: TODO: can this be cached in constructor?
      return new CompositePolygon(this.hitAreaParts.map((vertices) => new Polygon(vertices.map((vertex: any) => [vertex.x, vertex.y]).flat())));
    }
    return undefined;
  }

  render (sprite: PixiSprite, canvas: any, viewport: any): void {
    const width = this.width(viewport);
    const height = this.height(viewport);

    sprite.visible = true;
    sprite.alpha = 0.7;
    sprite.x = canvas.x - (width - viewport.tile_width) * .5;
    sprite.y = canvas.y - (height - viewport.tile_height);
    sprite.width = width;
    sprite.height = height;
    sprite.tint = this.isValid ? 0x00FF00 : 0xFF0000;
    sprite.zIndex = sprite.y + sprite.height - Math.round(.5 * this.imageMetadata.h * viewport.tile_height);
  }
}
