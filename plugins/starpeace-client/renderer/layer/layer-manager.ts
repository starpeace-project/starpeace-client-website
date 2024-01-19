import { type AnimatedSprite, Container, Graphics, type Sprite as PixiSprite, Text, TextStyle } from 'pixi.js'

import LayerCache from '~/plugins/starpeace-client/renderer/layer/layer-cache.js'
import TileItem from '~/plugins/starpeace-client/renderer/item/tile-item.js';

import ClientState from '~/plugins/starpeace-client/state/client-state';


export default class LayerManager {
  static MAX_PARTICLES = 65536;

  clientState: ClientState;

  containers: Array<Container>;
  sprite_caches: Array<LayerCache>;

  land_container: Container;
  land_sprite_cache: LayerCache;

  concrete_container: Container;
  concrete_sprite_cache: LayerCache;

  road_container: Container;
  road_sprite_cache: LayerCache;

  foundation_container: Container;
  foundation_sprite_cache: LayerCache;

  with_height_container: Container;
  with_height_static_sprite_cache: LayerCache;
  with_height_animated_sprite_cache: LayerCache;

  overlay_container: Container
  overlay_sprite_cache: LayerCache;

  plane_container: Container
  plane_sprite_cache: LayerCache;

  building_graphics_background: Graphics;
  building_graphics_foreground: Graphics;

  building_text_style: TextStyle;
  building_text: Text;

  constructor (clientState: ClientState) {
    this.clientState = clientState;
    this.land_container = new Container({
      isRenderGroup: true,
      eventMode: 'none',
      interactive: false,
      interactiveChildren: false
    });
    this.land_sprite_cache = new LayerCache(this.land_container, LayerManager.MAX_PARTICLES, false, false);

    this.concrete_container = new Container({
      isRenderGroup: true,
      eventMode: 'none',
      interactive: false,
      interactiveChildren: false
    });
    this.concrete_sprite_cache = new LayerCache(this.concrete_container, LayerManager.MAX_PARTICLES, false, false);

    this.road_container = new Container({
      isRenderGroup: true,
      eventMode: 'none',
      interactive: false,
      interactiveChildren: false
    });
    this.road_sprite_cache = new LayerCache(this.road_container, LayerManager.MAX_PARTICLES, false, false);

    this.foundation_container = new Container({
      isRenderGroup: true,
      eventMode: 'none',
      interactive: false,
      interactiveChildren: false
    });
    this.foundation_sprite_cache = new LayerCache(this.foundation_container, LayerManager.MAX_PARTICLES, false, false);

    this.with_height_container = new Container({
      isRenderGroup: true,
      // eventMode: 'auto',
      interactive: false,
      interactiveChildren: true,
      sortableChildren: true
    });
    this.with_height_static_sprite_cache = new LayerCache(this.with_height_container, 0, false, true);
    this.with_height_animated_sprite_cache = new LayerCache(this.with_height_container, 0, true, true);

    this.overlay_container = new Container({
      isRenderGroup: true,
      eventMode: 'none',
      interactive: false,
      interactiveChildren: false
    });
    this.overlay_sprite_cache = new LayerCache(this.overlay_container, LayerManager.MAX_PARTICLES, false, false);

    this.plane_container = new Container({
      isRenderGroup: true,
      eventMode: 'none',
      interactive: false,
      interactiveChildren: false,
    });
    this.plane_sprite_cache = new LayerCache(this.plane_container, 0, true, false);

    this.building_graphics_background = new Graphics();
    this.building_graphics_background.visible = false;
    this.building_graphics_background.setStrokeStyle({
      width: 2,
      color: 0x00FF00
    });
    this.building_graphics_foreground = new Graphics();
    this.building_graphics_foreground.visible = false;
    this.building_graphics_foreground.setStrokeStyle({
      width: 2,
      color: 0x00FF00
    });

    this.with_height_container.addChild(this.building_graphics_background);
    this.with_height_container.addChild(this.building_graphics_foreground);

    this.building_text_style = new TextStyle({
        align: 'center',
        fontFamily: 'Open Sans',
        fontSize: 26,
        fontWeight: 'bold',
        fill: 0xFFFF00,
        stroke: {
          color: '#000000',
          width: 4
        },
        dropShadow: {
          alpha: 0,
          angle: 0,
          blur: 0,
          color: '#000000',
          distance: 2
        }
    });
    this.building_text = new Text({ text: '', style: this.building_text_style, renderMode: 'canvas' });
    this.building_text.anchor.set(0.5, 1);
    this.building_text.visible = false;
    this.with_height_container.addChild(this.building_text);

    this.containers = [this.land_container, this.concrete_container, this.road_container, this.foundation_container, this.with_height_container, this.overlay_container, this.plane_container]
    this.sprite_caches = [this.land_sprite_cache, this.concrete_sprite_cache, this.road_sprite_cache, this.foundation_sprite_cache, this.with_height_static_sprite_cache, this.with_height_animated_sprite_cache, this.overlay_sprite_cache]
  }

  destroy () {
    for (const container of this.containers) {
      container.destroy({ children: true, texture: false });
    }
  }

  remove_from_stage (stage: Container) {
    for (const container of this.containers) {
      stage.removeChild(container);
    }
  }

  add_to_stage (stage: Container): void {
    for (const container of this.containers) {
      stage.addChild(container);
    }
  }

  clear_cache_sprites (countByLayer: any): void {
    for (const cache of this.sprite_caches) {
      cache.clearCache(countByLayer);
    }
  }

  clear_cache_plane_sprites (countByLayer: any): void {
    this.plane_sprite_cache.clearCache(countByLayer)
  }

  plane_sprite_with (countByLayer: any, textures: any): AnimatedSprite | PixiSprite {
    return this.plane_sprite_cache.sprite(countByLayer, { textures })
  }


  render_building_selection (viewport: any, building_sprite: any, building_image_metadata: any, building_label: any): void {
    this.building_graphics_background.clear();
    this.building_graphics_foreground.clear();

    const offset_y = viewport.tile_height * 0.75;

    this.building_graphics_background.x = building_sprite.x;
    this.building_graphics_background.y = building_sprite.y - offset_y;
    this.building_graphics_background.zIndex = building_sprite.zIndex - 1;

    this.building_graphics_foreground.x = building_sprite.x;
    this.building_graphics_foreground.y = building_sprite.y - offset_y;
    this.building_graphics_foreground.zIndex = building_sprite.zIndex + 1;

    const middle_x = building_sprite.width * 0.5;

    this.building_text.text = building_label;
    this.building_text.scale.set(viewport.game_scale * 0.5);
    this.building_text.x = building_sprite.x + middle_x;
    this.building_text.y = building_sprite.y;
    this.building_text.zIndex = building_sprite.zIndex + 2;

    const h_a = building_image_metadata.h * viewport.tile_height * 0.5;

    const hx = building_sprite.width * 0.15; // === 0.5 * 0.3
    const hy = hx * 0.5; // === sin(30deg)
    const vy = (building_sprite.height - 2 * h_a + offset_y) * 0.3;

    // top west
    this.building_graphics_background.moveTo(0, h_a).lineTo(hx, h_a + hy).stroke();
    this.building_graphics_foreground.moveTo(0, h_a).lineTo(hx, h_a - hy).stroke();
    this.building_graphics_foreground.moveTo(0, h_a).lineTo(0, h_a + vy).stroke();

    // top north
    this.building_graphics_background.moveTo(middle_x, 0).lineTo(middle_x, vy).stroke();
    this.building_graphics_background.moveTo(middle_x, 0).lineTo(middle_x - hx, hy).stroke();
    this.building_graphics_background.moveTo(middle_x, 0).lineTo(middle_x + hx, hy).stroke();

    // top south
    // in front of building, omit to avoid obscuring

    // top east
    this.building_graphics_background.moveTo(building_sprite.width, h_a).lineTo(building_sprite.width - hx, h_a + hy).stroke();
    this.building_graphics_foreground.moveTo(building_sprite.width, h_a).lineTo(building_sprite.width - hx, h_a - hy).stroke();
    this.building_graphics_foreground.moveTo(building_sprite.width, h_a).lineTo(building_sprite.width, h_a + vy).stroke();

    // bottom west
    const bottom_west_y = offset_y + building_sprite.height - h_a - 1;
    this.building_graphics_background.moveTo(0, bottom_west_y).lineTo(hx, bottom_west_y - hy).stroke();
    this.building_graphics_foreground.moveTo(0, bottom_west_y).lineTo(hx, bottom_west_y + hy).stroke();
    this.building_graphics_foreground.moveTo(0, bottom_west_y).lineTo(0, bottom_west_y - vy).stroke();

    // bottom north
    // usually behind building, omit for performance

    // bottom south
    const bottom_south_y = building_sprite.height + offset_y - 1;
    this.building_graphics_foreground.moveTo(middle_x, bottom_south_y).lineTo(middle_x, bottom_south_y - vy).stroke();
    this.building_graphics_foreground.moveTo(middle_x, bottom_south_y).lineTo(middle_x - hx, bottom_south_y - hy).stroke();
    this.building_graphics_foreground.moveTo(middle_x, bottom_south_y).lineTo(middle_x + hx, bottom_south_y - hy).stroke();

    // bottom east
    const bottom_east_y = offset_y + building_sprite.height - h_a;
    this.building_graphics_background.moveTo(building_sprite.width, bottom_east_y - 1).lineTo(building_sprite.width - hx, bottom_east_y - hy - 1).stroke();
    this.building_graphics_foreground.moveTo(building_sprite.width, bottom_east_y - 1).lineTo(building_sprite.width - hx, bottom_east_y + hy - 1).stroke();
    this.building_graphics_foreground.moveTo(building_sprite.width, bottom_east_y - 1).lineTo(building_sprite.width, bottom_east_y - vy - 1).stroke();

    this.building_graphics_background.visible = true;
    this.building_graphics_foreground.visible = true;
    this.building_text.visible = true;
  }


  render_tile_item (countByLayer: Record<string, number>, tileItem: TileItem, selected_building_label: any, construction_item: any, within_construction: boolean, canvas: any, viewport: any): void {
    if ((within_construction || !within_construction && !tileItem.sprite.tree) && tileItem.sprite.land?.withinCanvas(canvas, viewport)) {
      tileItem.sprite.land.render(this.land_sprite_cache.sprite(countByLayer, {
        texture:tileItem.sprite.land.texture
      }), canvas, viewport);
    }

    const has_concrete_with_height = tileItem.sprite.concrete ? !tileItem.sprite.concrete.isFlat || tileItem.sprite.concrete.isPlatform : false;
    if (tileItem.sprite.concrete?.withinCanvas(canvas, viewport)) {
      const sprite_cache = has_concrete_with_height ? this.with_height_static_sprite_cache : this.concrete_sprite_cache;
      const concrete = sprite_cache.sprite(countByLayer, {
        texture: tileItem.sprite.concrete.texture
      });
      tileItem.sprite.concrete.render(concrete, canvas, viewport);

      // if (has_concrete_with_height && tileItem.sprite.underlay) {
      //   tileItem.sprite.underlay.render(this.with_height_static_sprite_cache.sprite(countByLayer, {
      //     texture: tileItem.sprite.underlay.texture
      //   }), concrete.zIndex, false, canvas, viewport);
      // }
    }

    const has_road_with_height = tileItem.sprite.road ? has_concrete_with_height || tileItem.sprite.road.isBridge || tileItem.sprite.road.isOverWater : false;
    if (tileItem.sprite.road?.withinCanvas(canvas, viewport)) {
      const sprite_cache = has_road_with_height ? this.with_height_static_sprite_cache : this.road_sprite_cache;
      const road = sprite_cache.sprite(countByLayer, {
        texture: tileItem.sprite.road.texture
      });
      tileItem.sprite.road.render(road, canvas, viewport);

      // if (has_road_with_height && tileItem.sprite.underlay) {
      //   tileItem.sprite.underlay.render(this.with_height_static_sprite_cache.sprite(countByLayer, {
      //     texture: tileItem.sprite.underlay.texture
      //   }), road.zIndex, false, canvas, viewport);
      // }
    }

    // if (!(has_road_with_height || has_concrete_with_height) && !tileItem.sprite.tree && tileItem.sprite.underlay?.withinCanvas(canvas, viewport)) {
    //   tileItem.sprite.underlay.render(this.underlay_sprite_cache.sprite(countByLayer, {
    //     texture: tileItem.sprite.underlay.texture
    //   }), -1, false, canvas, viewport);
    // }

    if (!within_construction && tileItem.sprite.tree?.withinCanvas(canvas, viewport)) {
      const tree = this.with_height_static_sprite_cache.sprite(countByLayer, {
        texture: tileItem.sprite.tree.texture
      });
      tileItem.sprite.tree.render(tree, canvas, viewport);

      // if (tileItem.sprite.underlay) {
      //   tileItem.sprite.underlay.render(this.with_height_static_sprite_cache.sprite(countByLayer, {
      //     texture: tileItem.sprite.underlay.texture
      //   }), tree.zIndex, true, canvas, viewport);
      // }
    }

    if (tileItem.sprite.foundation?.withinCanvas(canvas, viewport)) {
      tileItem.sprite.foundation.render(this.foundation_sprite_cache.sprite(countByLayer, {
        texture: tileItem.sprite.foundation.texture
      }), canvas, viewport);
    }

    if (tileItem.sprite.building?.withinCanvas(canvas, viewport)) {
      const select_building_callback = (leftClick: boolean, rightClick: boolean) => {
        if (this.clientState.interface.construction_building_id?.length) {
          return false;
        }

        if (leftClick) {
          this.clientState.interface.toggle_building(tileItem.tile.building?.id);
        }
        else if (rightClick && tileItem.tile.building?.id) {
          this.clientState.interface.select_and_inspect_building(tileItem.tile.building.id);
        }

        if (this.clientState.interface.is_mouse_primary_down) {
          this.clientState.interface.is_mouse_primary_down = false;
        }
        return true;
      }

      const sprite_cache = tileItem.sprite.building.isAnimated ? this.with_height_animated_sprite_cache : this.with_height_static_sprite_cache;
      const building = sprite_cache.sprite(countByLayer, {
        textures: tileItem.sprite.building.textures,
        speed: 0.15,
        hitArea: tileItem.sprite.building.hitArea(viewport),
        click_callback: select_building_callback
      });
      tileItem.sprite.building.render(building, canvas, viewport);

      for (const effectInfo of tileItem.sprite.building.effects) {
        effectInfo.render(this.with_height_animated_sprite_cache.sprite(countByLayer, {
          textures: effectInfo.textures,
          speed: 0.1
        }), building, canvas, viewport);
      }

      for (const signInfo of tileItem.sprite.building.signs) {
        signInfo.render(this.with_height_animated_sprite_cache.sprite(countByLayer, {
          textures: signInfo.textures,
          speed: 0.1
        }), building, canvas, viewport);
      }

      if (tileItem.sprite.building.isSelected) {
        this.render_building_selection(viewport, building, tileItem.sprite.building.imageMetadata, selected_building_label);
      }
    }

    if (construction_item?.withinCanvas(canvas, viewport)) {
      const sprite_cache = construction_item.is_animated ? this.with_height_animated_sprite_cache : this.with_height_static_sprite_cache;
      construction_item.render(sprite_cache.sprite(countByLayer, {
        textures: construction_item.textures,
        speed: 0.15,
        hitArea: construction_item.hitArea(viewport)
      }), canvas, viewport);
    }

    if (tileItem.sprite.overlay?.withinCanvas(canvas, viewport)) {
      tileItem.sprite.overlay.render(this.overlay_sprite_cache.sprite(countByLayer, {
        texture: tileItem.sprite.overlay.texture
      }), -1, false, canvas, viewport);
    }
  }
}
