import _ from 'lodash';
import { AnimatedSprite, type Container, Sprite as PixiSprite, Texture } from 'pixi.js'

import Logger from '~/plugins/starpeace-client/logger'
import Utils from '~/plugins/starpeace-client/utils/utils'

const SPRITE_BUFFER = 100000;

export default class LayerCache {
  id: string = Utils.uuid();
  container: Container;

  maxSize: number;
  count: number = 0;
  pool: any[] = new Array(SPRITE_BUFFER);

  isAnimated: boolean;
  pointerEvents: boolean;

  constructor (container: Container, maxSize: number, isAnimated: boolean, pointerEvents: boolean) {
    this.container = container;
    this.maxSize = maxSize;
    this.isAnimated = isAnimated;
    this.pointerEvents = pointerEvents;
  }

  /**
   * Resets and hides any unused sprites from pool
   */
  clearCache (renderMetrics: any): void {
    const count = renderMetrics[this.id] ?? 0;
    if (count >= this.count) {
      return;
    }

    for (let index = count; index < this.count; index++) {
      if (!this.pool[index]) {
        break;
      }

      this.pool[index].eventMode = 'none';
      this.pool[index].visible = false;
      this.pool[index].hitArea = undefined;
      this.pool[index].x = -1000
      this.pool[index].y = -1000
      this.pool[index].click_callback = undefined;
    }
  }

  sprite (countByLayer: any, options: any): AnimatedSprite | PixiSprite {
    if (!countByLayer[this.id]) {
      countByLayer[this.id] = 0;
    }

    const textures: Texture[] = _.compact(options.textures ? options.textures : [options.texture]);
    if (!textures.length) {
      Logger.warn('No textures for sprite, using empty texture');
      textures.push(Texture.EMPTY);
    }

    let sprite = undefined;
    if (countByLayer[this.id] < this.count) {
      sprite = this.pool[countByLayer[this.id]];

      if (this.isAnimated) {
        sprite.textures = textures;
      }
      else {
        sprite.texture = textures[0];
      }
    }
    else {
      if (this.maxSize > 0 && this.count >= this.maxSize) {
        throw "maximum number sprites reached";
      }

      this.count += 1;
      sprite = this.pool[countByLayer[this.id]] = this.isAnimated ? new AnimatedSprite(textures) : new PixiSprite(textures[0]);

      if (this.pointerEvents) {
        sprite.on('pointerdown', (event) => {
          const extendedSprite = event.currentTarget as any;
          if (!extendedSprite.click_callback) {
            return;
          }

          extendedSprite.event_pointer_down_x = Math.round(event.data?.global?.x ?? 0);
          extendedSprite.event_pointer_down_y = Math.round(event.data?.global?.y ?? 0);
        });
        sprite.addEventListener('pointerup', (event) => {
          const extendedSprite = event.currentTarget as any;
          if (!extendedSprite.click_callback) {
            return true;
          }

          const deltaX = Math.round(event.data?.global?.x ?? 0) - (extendedSprite.event_pointer_down_x ?? 0);
          const deltaY = Math.round(event.data?.global?.y ?? 0) - (extendedSprite.event_pointer_down_y ?? 0);
          if (deltaX > 0 || deltaY > 0) {
            return true;
          }

          if (extendedSprite.click_callback(event.data?.button == 0, event.data?.button == 2)) {
            event.data?.originalEvent?.preventDefault();
            event.data?.originalEvent?.stopPropagation();
            event.stopPropagation();
          }
          return false;
        });
      }

      this.container.addChild(sprite);
    }

    countByLayer[this.id] += 1;

    if (this.pointerEvents && options.click_callback) {
      sprite.eventMode = 'static';
      sprite.interactiveChildren = false;
      sprite.hitArea = options.hitArea ? options.hitArea : undefined;
      sprite.click_callback = options.click_callback;
    }
    else {
      sprite.eventMode = 'none';
      sprite.hitArea = undefined;
      sprite.click_callback = undefined;
    }

    if (this.isAnimated) {
      sprite.animationSpeed = options.speed ? options.speed : .2;
      sprite.gotoAndPlay(Math.floor(new Date().getTime() / 200) % textures.length);
    }

    return sprite;
  }
}
