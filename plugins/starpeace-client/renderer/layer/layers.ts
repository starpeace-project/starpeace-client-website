import { DateTime } from 'luxon';
import { type Container } from 'pixi.js';

import TileItemCache from '~/plugins/starpeace-client/renderer/item/tile-item-cache.js';
import LayerManager from '~/plugins/starpeace-client/renderer/layer/layer-manager.js';

import type Building from '~/plugins/starpeace-client/building/building';

import type TranslationManager from '~/plugins/starpeace-client/language/translation-manager';
import type ClientState from '~/plugins/starpeace-client/state/client-state';
import type Options from '~/plugins/starpeace-client/state/options/options';


const PLANE_CHECK_SPEED = 5000;
const PLANE_COUNT = 6;


interface ViewportIsometric {
  i: number;
  j: number;
  i_exact: number;
  j_exact: number;
}

interface ViewportTopLeft {
  x: number;
  y: number;
  x_exact: number;
  y_exact: number;
}

interface ViewportState {
  view_center: ViewportTopLeft;
  iso_start: ViewportIsometric;
  iso_max_i: ViewportIsometric;
  iso_max_j: ViewportIsometric;
  iso_min_j: ViewportIsometric;
}

interface IsometricState {
  i_start: number;
  j_start: number;
  i_max: number;
  j_max: number;
  j_min: number;

  n_bump: boolean;
  m_bump: boolean;
  n: number;
  n_buffer: number;
  m: number;
  m_buffer: number;
}

export interface RenderContext {
  inProgress: boolean;
  now: DateTime;
  currentSeason: string;

  renderTrees: boolean;
  renderBuildings: boolean
  renderBuildingAnimations: boolean;
  renderBuildingEffects: boolean;

  showZones: boolean;
  showOverlay: boolean;
  currentOverlay: any | undefined;

  selectedBuilding: Building | undefined;
  selectedBuildingId: string | undefined;
  selectedCorporationId: string | undefined;
  selectedBuildingLabel: string | undefined;
}


export default class Layers {
  translationManager: TranslationManager;
  clientState: ClientState;
  options: Options;

  cache: TileItemCache;
  layerManager: LayerManager;

  checkLoop: any;

  // cached to reduce garbage collection
  viewport: ViewportState;
  isometric: IsometricState;
  context: RenderContext;

  constructor (planeManager: any, translationManager: TranslationManager, clientState: ClientState, options: Options) {
    this.translationManager = translationManager;
    this.clientState = clientState;
    this.options = options;
    this.cache = new TileItemCache(clientState, options);
    this.layerManager = new LayerManager(clientState);

    this.checkLoop = setInterval(() => {
      if (!clientState.initialized || !options.option('renderer.planes')) {
        return;
      }

      while (clientState.plane_sprites.length < PLANE_COUNT) {
        const flightPlan = planeManager.random_flight_plan(clientState.camera);
        const sprite = this.cache.tileItemsFactory.plane(flightPlan);
        if (!sprite) {
          return;
        }
        clientState.plane_sprites.push(sprite);
      }
    }, PLANE_CHECK_SPEED);

    this.viewport = {
      view_center: {
        x: 0,
        y: 0,
        x_exact: 0,
        y_exact: 0
      },
      iso_start: {
        i: 0,
        j: 0,
        i_exact: 0,
        j_exact: 0
      },
      iso_max_i: {
        i: 0,
        j: 0,
        i_exact: 0,
        j_exact: 0
      },
      iso_max_j: {
        i: 0,
        j: 0,
        i_exact: 0,
        j_exact: 0
      },
      iso_min_j: {
        i: 0,
        j: 0,
        i_exact: 0,
        j_exact: 0
      }
    };

    this.isometric = {
      i_start: 0,
      j_start: 0,
      i_max: 0,
      j_max: 0,
      j_min: 0,

      n_bump: false,
      m_bump: false,
      n: 0,
      n_buffer: 0,
      m: 0,
      m_buffer: 0
    };

    this.context = {
      inProgress: false,
      now: DateTime.now(),
      currentSeason: '',

      renderTrees: false,
      renderBuildings: false,
      renderBuildingAnimations: false,
      renderBuildingEffects: false,

      showZones: false,
      showOverlay: false,
      currentOverlay: undefined,

      selectedBuilding: undefined,
      selectedBuildingId: undefined,
      selectedCorporationId: undefined,
      selectedBuildingLabel: undefined
    };
  }

  destroy (): void {
    if (this.checkLoop) {
      clearInterval(this.checkLoop);
      this.checkLoop = undefined;
    }
    this.layerManager.destroy();
  }

  removeLayers (stage: Container): void {
    this.layerManager.remove_from_stage(stage);
  }
  addLayers (stage: Container): void {
    this.layerManager.add_to_stage(stage);
  }

  get shouldRefresh (): boolean {
    return this.clientState.has_dirty_metadata || this.cache.isDirty || this.cache.shouldClearCache;
  }

  refreshPlanes (): void {
    if (!this.clientState.initialized || !this.clientState.renderer_initialized || !this.clientState.plane_sprites.length) {
      return;
    }

    if (!this.options.option('renderer.planes')) {
      this.clientState.plane_sprites = [];
      this.layerManager.clear_cache_plane_sprites({})
      return
    }

    const countByLayer: Record<string, number> = {};
    const toRemove: number[] = [];
    for (let index = 0; index < this.clientState.plane_sprites.length; index++) {
      const sprite = this.clientState.plane_sprites[index];
      if (sprite.isAtTarget) {
        toRemove.push(index);
      }
      else {
        sprite.sprite = this.layerManager.plane_sprite_with(countByLayer, sprite.textures);
        sprite.render(sprite.sprite, this.clientState.camera);
      }
    }

    this.layerManager.clear_cache_plane_sprites(countByLayer);
    for (const index of toRemove.reverse()) {
      this.clientState.plane_sprites.splice(index, 1);
    }
  }

  refresh (): void {
    if (!this.clientState.initialized || !this.clientState.renderer_initialized || !this.clientState.planet.current_season || this.context.inProgress) {
      return;
    }

    if (this.cache.shouldClearCache) {
      this.cache.clearFullCache();
    }
    this.cache.resetCache();

    const viewport = this.clientState.camera;
    this.viewport.view_center = viewport.top_left();
    this.viewport.iso_start = viewport.map_to_iso(this.viewport.view_center.x, this.viewport.view_center.y);
    this.viewport.iso_max_i = viewport.map_to_iso(this.viewport.view_center.x + viewport.canvas_width, this.viewport.view_center.y + viewport.canvas_height);
    this.viewport.iso_max_j = viewport.map_to_iso(this.viewport.view_center.x, this.viewport.view_center.y + viewport.canvas_height);
    this.viewport.iso_min_j = viewport.map_to_iso(this.viewport.view_center.x + viewport.canvas_width, this.viewport.view_center.y);

    this.isometric.i_start = this.viewport.iso_start.i - 8;
    this.isometric.j_start = this.viewport.iso_start.j;
    this.isometric.i_max = this.viewport.iso_max_i.i + 24;
    this.isometric.j_max = this.viewport.iso_max_j.j + 30;
    this.isometric.j_min = this.viewport.iso_min_j.j - 6;

    this.isometric.n_bump = false;
    this.isometric.m_bump = false;
    this.isometric.n = 0;
    this.isometric.n_buffer = 4;
    this.isometric.m = 10;
    this.isometric.m_buffer = 6;

    const spriteCountByLayer: Record<string, number> = {};

    this.context.inProgress = true;
    this.context.now = DateTime.now();
    this.context.currentSeason = this.clientState.planet.current_season;
    this.context.renderTrees = this.options.option('renderer.trees');
    this.context.renderBuildings = this.options.option('renderer.buildings');
    this.context.renderBuildingAnimations = this.options.option('renderer.building_animations');
    this.context.renderBuildingEffects = this.options.option('renderer.building_effects');
    this.context.showZones = this.clientState.interface.show_zones;
    this.context.showOverlay = this.clientState.interface.show_overlay;
    this.context.currentOverlay = this.clientState.interface.current_overlay;
    this.context.selectedBuilding = this.clientState.interface.selected_building_id ? this.clientState.selected_building() : undefined;
    this.context.selectedBuildingId = this.context.selectedBuilding ? this.clientState.interface.selected_building_id : undefined;
    this.context.selectedCorporationId = this.context.selectedBuilding?.corporationId ?? undefined;
    this.context.selectedBuildingLabel = !!this.context.selectedBuilding ? this.translationManager.label_for_building(this.context.selectedBuilding) : undefined;

    const game_map = this.clientState.planet.game_map;

    const construction_building_id = this.clientState.interface.construction_building_id;
    const can_construct = !!construction_building_id && this.clientState.can_construct_building();

    const construction_x = construction_building_id ? this.clientState.interface.construction_building_map_x : -1;
    const construction_y = construction_building_id ? this.clientState.interface.construction_building_map_y : -1;
    const construction_width = this.clientState.interface.construction_building_width;
    const construction_height = this.clientState.interface.construction_building_height;

    let renderedBuildingSelection = false;

    let x = this.isometric.i_start;
    while (x < this.isometric.i_max) {
      let j = this.isometric.j_start - this.isometric.n;
      while (j < (this.isometric.j_start + this.isometric.m)) {
        if (j > 1 && j < game_map.height && x > 1 && x < game_map.width) {
          const tileCacheIndex = (j * game_map.width + x).toString();
          let tileItem = this.cache.tileItems[tileCacheIndex];
          if (!tileItem) {
            tileItem = this.cache.cacheItem(game_map.info_for_tile(x, j, this.context), tileCacheIndex, x, j, this.context);
          }

          const constructionItem = construction_building_id && construction_x == x && construction_y == j ? this.cache.tileItemsFactory.buildingConstruction(construction_building_id, this.context.renderBuildingAnimations, can_construct) : undefined;
          const withinConstruction = construction_x >= 0 && x > construction_x - construction_width && x <= construction_x && construction_y >= 0 && j > construction_y - construction_height && j <= construction_y;

          if (tileItem) {
            this.layerManager.render_tile_item(spriteCountByLayer, tileItem, this.context.selectedBuildingLabel, constructionItem, withinConstruction, viewport.iso_to_canvas(x, j, this.viewport.view_center), viewport);
            renderedBuildingSelection ||= tileItem.sprite?.building?.isSelected;
          }
        }

        j += 1;
      }

      if (!this.isometric.n_bump) {
        this.isometric.n += 1;
        this.isometric.n_bump = ((this.isometric.j_start - this.isometric.n) == this.isometric.j_min);
        if (this.isometric.n_bump) {
          this.isometric.n += 1;
        }
      }
      else {
        if (this.isometric.n_buffer > 0) {
          this.isometric.n_buffer -= 1;
        }
        else {
          this.isometric.n -= 1;
        }
      }

      if (!this.isometric.m_bump) {
        this.isometric.m += 1;
        this.isometric.m_bump = ((this.isometric.j_start + this.isometric.m) == this.isometric.j_max);
      }
      else {
        if (this.isometric.m_buffer > 0) {
          this.isometric.m_buffer -= 1;
        }
        else {
          this.isometric.m -= 1;
        }
      }

      x += 1;
    }
    this.context.inProgress = false;

    if (!renderedBuildingSelection) {
      this.layerManager.building_graphics_background.visible = false;
      this.layerManager.building_graphics_foreground.visible = false;
      this.layerManager.building_text.visible = false;
    }

    this.layerManager.clear_cache_sprites(spriteCountByLayer);
    this.layerManager.with_height_container.sortChildren();
    this.clientState.has_dirty_metadata = false;
  }
}
