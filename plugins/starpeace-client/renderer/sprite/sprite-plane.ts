import { type Sprite as PixiSprite, type Texture } from 'pixi.js';

import Sprite from '~/plugins/starpeace-client/renderer/sprite/sprite.js';


export default class SpritePlane extends Sprite {
  textures: Texture[];

  flightPlan: any;

  currentMapX: number;
  currentMapY: number;

  lastShown: number = -1;
  isDone: boolean = false;

  // TODO: work on removing
  sprite: PixiSprite | undefined;

  constructor (textures: Texture[], flightPlan: any) {
    super();

    this.textures = textures;
    this.flightPlan = flightPlan;
    this.currentMapX = flightPlan.source_map_x;
    this.currentMapY = flightPlan.source_map_y;
  }

  width (viewport: any): number {
    return viewport.with_scale(this.textures[0].width);
  }
  height (viewport: any): number {
    return viewport.with_scale(this.textures[0].height);
  }

  get isAtTarget (): boolean {
    const diffX = this.currentMapX - this.flightPlan.target_map_x;
    const diffY = this.currentMapY - this.flightPlan.target_map_y;

    switch (this.flightPlan.direction) {
      case 'se':
        return diffX >= 0 && diffY >= 0;
      case 'nw':
        return diffX <= 0 && diffY <= 0;

      case 'sw':
        return diffX <= 0 && diffY >= 0;
      case 'ne':
        return diffX <= 0 && diffY <= 0;

      case 'e':
        return diffX >= 0 && diffY <= 0;
      case 'n':
        return diffX <= 0 && diffY <= 0;

      case 's':
        return diffX >= 0 && diffY >= 0;
      case 'w':
        return diffX <= 0 && diffY >= 0;
    }
    return false;
  }

  render (sprite: PixiSprite, viewport: any): void {
    if (!sprite || this.isDone) {
      return;
    }

    if (!sprite?.texture) {
      // texture fails to load sometimes TODO: why?
      this.isDone = true;
      return;
    }

    const viewCenter = viewport.top_left()
    const iso = viewport.map_to_iso(viewport.with_scale(this.currentMapX), viewport.with_scale(this.currentMapY));
    const canvas = viewport.iso_to_canvas(iso.i_exact, iso.j_exact, viewCenter);

    const width = this.width(viewport);
    const height = this.height(viewport);

    const isVisible = (canvas.x > -width && canvas.x <= viewport.canvas_width) && (canvas.y > -height && canvas.y <= viewport.canvas_height);
    const currentTime = new Date().getTime();
    if (!isVisible && (this.isAtTarget || this.lastShown > 0 && (currentTime - this.lastShown) > 3000)) {
      this.isDone = true;
      return;
    }

    sprite.visible = isVisible;
    sprite.x = canvas.x - width * 0.5;
    sprite.y = canvas.y;
    sprite.width = width;
    sprite.height = height;

    if (isVisible) {
      this.lastShown = currentTime;
    }

    this.currentMapX += this.flightPlan.velocity.x;
    this.currentMapY += this.flightPlan.velocity.y;
  }
}
