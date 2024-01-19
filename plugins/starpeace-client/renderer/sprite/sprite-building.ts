import { Polygon, type Sprite as PixiSprite, type Texture } from 'pixi.js';

import CompositePolygon from '~/plugins/pixi/composite-polygon'
import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.js'
import SpriteEffect from '~/plugins/starpeace-client/renderer/sprite/sprite-effect';
import SpriteSign from '~/plugins/starpeace-client/renderer/sprite/sprite-sign';

export default class SpriteBuilding extends Sprite {
  textures: Texture[];

  isAnimated: boolean;
  isSelected: boolean;
  isFiltered: boolean;

  imageMetadata: any;

  effects: SpriteEffect[];
  signs: SpriteSign[];

  hitAreaParts: any[];

  constructor (textures: Texture[], isAnimated: boolean, isSelected: boolean, isFiltered: boolean, imageMetadata: any, effects: SpriteEffect[], signs: SpriteSign[]) {
    super();

    this.textures = textures;

    this.isAnimated = isAnimated;
    this.isSelected = isSelected;
    this.isFiltered = isFiltered;

    this.imageMetadata = imageMetadata;
    this.effects = effects;
    this.signs = signs;

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
    sprite.alpha = this.isFiltered ? 0.5 : 1;
    sprite.x = canvas.x - (width - viewport.tile_width) * .5;
    sprite.y = canvas.y - (height - viewport.tile_height);
    sprite.width = width;
    sprite.height = height;
    sprite.tint = 0xFFFFFF;
    sprite.zIndex = sprite.y + sprite.height - Math.round(.5 * this.imageMetadata.h * viewport.tile_height);
  }
}
