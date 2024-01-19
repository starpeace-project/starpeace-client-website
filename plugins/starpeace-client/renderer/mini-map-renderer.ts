import '~/plugins/javascript-detect-element-resize/detect-element-resize';
import { Application, Cache, Container, Graphics, Point, Sprite, Texture } from 'pixi.js';

import MetadataLand from '~/plugins/starpeace-client/land/metadata-land.coffee'

import ChunkMap from '~/plugins/starpeace-client/map/chunk/chunk-map'

import MiniMapInputHandler from '~/plugins/starpeace-client/renderer/input/mini-map-input-handler.coffee'
import Renderer from './renderer';
import ClientState from '../state/client-state';
import Options from '../state/options/options';
import Managers from '../managers';


const MINI_MAP_TEXTURE_KEY = 'rendered-mini-map';

const MINI_MAP_TILE_WIDTH = Math.sqrt(2);
const MINI_MAP_TILE_HEIGHT = MINI_MAP_TILE_WIDTH * .5;

export default class MiniMapRenderer {
  managers: Managers;
  renderer: Renderer;

  clientState: ClientState;
  options: Options;

  rgbaBuffer: Uint8ClampedArray | undefined;

  dragging: boolean = false;
  mapOffsetX: number = 0;
  mapOffsetY: number = 0;

  lastMiniMapZoom: number = 0;
  lastRendererWidth: number = 0;
  lastRendererHeight: number = 0;
  lastGameScale: number = 0;
  lastViewOffsetX: number = 0;
  lastViewOffsetY: number = 0;

  pendingRefresh: any | undefined;

  rendererWidth: number = 0;
  rendererHeight: number = 0;

  application: Application = new Application();
  container: Container = new Container();
  viewport: Graphics = new Graphics();
  sprite: Sprite = new Sprite();

  inputHandler: MiniMapInputHandler | undefined;

  constructor (managers: Managers, renderer: Renderer, clientState: ClientState, options: Options) {
    this.managers = managers;
    this.renderer = renderer;
    this.clientState = clientState;
    this.options = options;

    this.clientState.planet.subscribe_map_data_listener((chunkEvent) => {
      const sourceX = (chunkEvent.info.chunk_x - 0) * ChunkMap.CHUNK_WIDTH - 10;
      const targetX = (chunkEvent.info.chunk_x + 1) * ChunkMap.CHUNK_WIDTH + 10;
      const sourceY = (chunkEvent.info.chunk_y - 0) * ChunkMap.CHUNK_HEIGHT - 10;
      const targetY = (chunkEvent.info.chunk_y + 1) * ChunkMap.CHUNK_HEIGHT + 10;

      this.updateMapData(sourceX, targetX, sourceY, targetY);

      if (!this.pendingRefresh) {
        this.pendingRefresh = setTimeout(() => this.refreshMapTexture(), 500);
      }
    });

    this.clientState.camera.subscribe_viewport_listener(() => this.updateViewport());
    this.clientState.interface.subscribe_mini_map_zoom_listener(() => this.updateMiniMapScale());
  }

  updateMapData (sourceX: number, targetX: number, sourceY: number, targetY: number): void {
    if (!this.clientState.planet.game_map?.map_rgba_pixels) {
      return;
    }

    const game_map = this.clientState.planet.game_map;
    const building_library = this.clientState.core.building_library;
    const planet_library = this.clientState.core.planet_library;

    if (!this.rgbaBuffer) {
      this.rgbaBuffer = new Uint8ClampedArray(game_map.width * game_map.height * 4);
    }

    for (let y = sourceY; y < targetY; y++) {
      for (let x = sourceX; x < targetX; x++) {
        const index = (y * game_map.width + x) * 4;
        const sourceIndex = ((game_map.height - x) * game_map.width + (game_map.width - y)) * 4;

        this.rgbaBuffer[index + 3] = 255;

        const building_chunk_info = game_map.building_map.chunk_building_info_at(x, y);
        const road_chunk_info = game_map.building_map.chunk_road_info_at(x, y);

        if (building_chunk_info?.has_data() && road_chunk_info?.has_data()) {
          const buildingId = game_map.building_map.building_id_at(x, y)
          const buildingInfo = buildingId ? this.clientState.core.building_cache.building_for_id(buildingId) : undefined;
          const buildingMetadata = buildingInfo ? building_library.metadata_by_id[buildingInfo.definition_id] : undefined;

          if (game_map.road_map.road_info_at(x, y)) {
            this.rgbaBuffer[index + 0] = 30
            this.rgbaBuffer[index + 1] = 30
            this.rgbaBuffer[index + 2] = 30
          }
          else if (buildingInfo && buildingMetadata) {
            const zone = planet_library.zone_for_id(buildingMetadata.zoneId);
            const color = zone?.miniMapColor || 0x800000;
            this.rgbaBuffer[index + 0] = (color & 0xFF0000) >> 16;
            this.rgbaBuffer[index + 1] = (color & 0x00FF00) >> 8;
            this.rgbaBuffer[index + 2] = (color & 0x0000FF) >> 0;
          }
          else {
            this.rgbaBuffer[index + 0] = game_map.map_rgba_pixels[sourceIndex + 0];
            this.rgbaBuffer[index + 1] = game_map.map_rgba_pixels[sourceIndex + 1];
            this.rgbaBuffer[index + 2] = game_map.map_rgba_pixels[sourceIndex + 2];
          }
        }
        else {
          this.rgbaBuffer[index + 0] = game_map.map_rgba_pixels[sourceIndex + 0] - game_map.map_rgba_pixels[sourceIndex + 0] * .5;
          this.rgbaBuffer[index + 1] = game_map.map_rgba_pixels[sourceIndex + 1] - game_map.map_rgba_pixels[sourceIndex + 1] * .5;
          this.rgbaBuffer[index + 2] = game_map.map_rgba_pixels[sourceIndex + 2] - game_map.map_rgba_pixels[sourceIndex + 2] * .5;
        }
      }
    }
  }

  refreshMapTexture (): void {
    if (!this.clientState.initialized || this.clientState.workflow_status !== 'ready' || !this.rgbaBuffer) {
      return;
    }

    if (!Cache.has(MINI_MAP_TEXTURE_KEY)) {
      Cache.set(MINI_MAP_TEXTURE_KEY, Texture.from({
        resource: this.rgbaBuffer,
        width: this.clientState.planet.game_map.width,
        height: this.clientState.planet.game_map.height
      }));
    }

    this.sprite.texture = Cache.get(MINI_MAP_TEXTURE_KEY);
    // TODO: update() might perform better, but throws errors (v8.0.0)
    this.sprite.texture.source.unload();

    this.pendingRefresh = undefined;
  }

  handleResize (): void {
    const renderContainer = document?.getElementById('mini-map-webgl-container');
    if (!renderContainer) {
      return;
    }

    this.rendererWidth = Math.ceil(renderContainer.offsetWidth);
    this.rendererHeight = Math.ceil(renderContainer.offsetHeight);
    this.application.renderer.resize(this.rendererWidth, this.rendererHeight);
  }

  async initializeApplication (): Promise<void> {
    const renderContainer = document?.getElementById('mini-map-webgl-container');
    if (!renderContainer) {
      return;
    }

    this.rendererWidth = Math.ceil(renderContainer.offsetWidth);
    this.rendererHeight = Math.ceil(renderContainer.offsetHeight);

    await this.application.init({
      preference: !!this.options.option('renderer.webgpu') ? 'webgpu' : 'webgl',
      width: this.rendererWidth,
      height: this.rendererHeight,
      backgroundColor : 0x000000,
      eventFeatures: {
        move: false,
        globalMove: false,
        click: false,
        wheel: false
      }
    });

    this.container = new Container();
    this.container.scale = new Point(1, .5);
    this.application.stage.addChild(this.container);

    this.viewport = new Graphics();
    this.viewport.setStrokeStyle({
      width: 2,
      color: 0xFFD0FF,
      alpha: .7
    });
    this.application.stage.addChild(this.viewport);

    this.inputHandler = new MiniMapInputHandler(this, renderContainer);

    renderContainer.appendChild(this.application.canvas);
    (window as any)?.addResizeListener(renderContainer, () => this.handleResize());
  }

  initializeMiniMapSprite (): void {
    const miniMapZoom = this.options.getMiniMapZoom()
    this.sprite.texture = Cache.get(MINI_MAP_TEXTURE_KEY);
    this.sprite.eventMode = 'none';
    this.sprite.scale = new Point(miniMapZoom, miniMapZoom);

    this.sprite.x = this.mapOffsetX
    this.sprite.y = this.mapOffsetY;
    this.sprite.rotation = Math.PI * .25;
    this.container.addChild(this.sprite);
  }

  async initialize (): Promise<void> {
    await this.initializeApplication();

    const renderContainer = document.getElementById('mini-map-webgl-container');
    if (renderContainer) {
      // hide until texture ready
      renderContainer.style.visibility = 'hidden';
    }

    this.updateMapData(0, this.clientState.planet.game_map.width, 0, this.clientState.planet.game_map.height);
    if (this.pendingRefresh) {
      clearTimeout(this.pendingRefresh);
    }
    this.pendingRefresh = setTimeout(() => {
      this.refreshMapTexture();
      this.initializeMiniMapSprite();
      this.updateViewport();

      if (renderContainer) {
        renderContainer.style.visibility = 'visible';
      }
    }, 500)

    this.lastMiniMapZoom = 0;
    this.lastRendererWidth = 0;
    this.lastRendererHeight = 0;
    this.lastGameScale = 0;
    this.lastViewOffsetX = 0;
    this.lastViewOffsetY = 0;

    this.clientState.mini_map_renderer_initialized = true
  }

  recenterAt (miniCanvasX: number, miniCanvasY: number): void {
    const miniMapZoom = this.options.getMiniMapZoom();

    const offsetMiniCanvasX = miniCanvasX - this.mapOffsetX;
    const offsetMiniCanvasY = miniCanvasY - this.mapOffsetY * .5;

    const ratioX = miniMapZoom * MINI_MAP_TILE_WIDTH / MetadataLand.DEFAULT_TILE_WIDTH;
    const ratioY = miniMapZoom * MINI_MAP_TILE_HEIGHT / MetadataLand.DEFAULT_TILE_HEIGHT;

    const halfViewportWidth = Math.round(ratioX * this.clientState.camera.canvas_width / (2 * this.clientState.camera.game_scale));
    const halfViewportHeight = Math.round(ratioY * this.clientState.camera.canvas_height / (2 * this.clientState.camera.game_scale));

    const adjustedMiniCanvasX = offsetMiniCanvasX - halfViewportWidth;
    const adjustedMiniCanvasY = offsetMiniCanvasY - halfViewportHeight;

    const xRatio = adjustedMiniCanvasX / (miniMapZoom * MINI_MAP_TILE_WIDTH * .5);
    const yRatio = adjustedMiniCanvasY / (miniMapZoom * MINI_MAP_TILE_HEIGHT * .5);
    const isoX = (yRatio + xRatio) * 0.5;
    const isoY = (yRatio - xRatio) * 0.5;

    this.clientState.camera.top_left_at(isoX, isoY);
  }

  offset (deltaX: number, deltaY: number): void {
    if (deltaX !== 0) {
      this.mapOffsetX -= deltaX;
    }
    if (deltaY !== 0) {
      this.mapOffsetY -= (2 * deltaY);
    }

    this.updateViewport();
  }

  get needsUpdate (): boolean {
    return this.lastViewOffsetX !== this.clientState.camera.view_offset_x || this.lastViewOffsetY !== this.clientState.camera.view_offset_y ||
        this.lastMiniMapZoom !== this.options.getMiniMapZoom() || this.lastGameScale !== this.clientState.camera.game_scale ||
        this.lastRendererWidth !== this.rendererWidth || this.lastRendererHeight !== this.rendererHeight;
  }

  updateMiniMapScale (): void {
    const zoom = this.options.getMiniMapZoom();
    this.sprite.scale = new Point(zoom, zoom);
  }

  updateViewport (): void {
    if (!this.clientState.mini_map_renderer_initialized) {
      return;
    }

    const zoom = this.options.getMiniMapZoom();

    const ratioX = zoom * MINI_MAP_TILE_WIDTH / MetadataLand.DEFAULT_TILE_WIDTH;
    const ratioY = zoom * MINI_MAP_TILE_HEIGHT / MetadataLand.DEFAULT_TILE_HEIGHT;

    const viewportWidth = Math.round(ratioX * this.clientState.camera.canvas_width  / this.clientState.camera.game_scale);
    const viewportHeight = Math.round(ratioY * this.clientState.camera.canvas_height / this.clientState.camera.game_scale);

    let miniMapX = Math.round(this.clientState.camera.view_offset_x * ratioX - viewportWidth * .5 + this.mapOffsetX);
    let miniMapY = Math.round(this.clientState.camera.view_offset_y * ratioY - viewportHeight * .5 + .5 * this.mapOffsetY);

    if (this.lastViewOffsetX !== this.clientState.camera.view_offset_x || this.lastViewOffsetY !== this.clientState.camera.view_offset_y || this.lastMiniMapZoom !== zoom || this.lastRendererWidth !== this.rendererWidth || this.lastRendererHeight !== this.rendererHeight) {
      const centerOffsetX = miniMapX - (this.rendererWidth * .5 - viewportWidth * .5);
      const centerOffsetY = miniMapY - (this.rendererHeight * .5 - viewportHeight * .5);

      this.mapOffsetX = Math.round(this.mapOffsetX - centerOffsetX);
      this.mapOffsetY = Math.round(this.mapOffsetY - 2 * centerOffsetY);

      miniMapX = Math.round(miniMapX - centerOffsetX);
      miniMapY = Math.round(this.clientState.camera.view_offset_y * ratioY - viewportHeight * .5 + .5 * this.mapOffsetY);
    }

    this.sprite.x = this.mapOffsetX;
    this.sprite.y = this.mapOffsetY;

    this.viewport.clear();
    this.viewport.rect(miniMapX, miniMapY, viewportWidth, viewportHeight).stroke();

    this.lastMiniMapZoom = zoom;
    this.lastRendererWidth = this.rendererWidth;
    this.lastRendererHeight = this.rendererHeight;
    this.lastGameScale = this.clientState.camera.game_scale;
    this.lastViewOffsetX = this.clientState.camera.view_offset_x;
    this.lastViewOffsetY = this.clientState.camera.view_offset_y;
  }

  tick (): void {
    if (!this.clientState.mini_map_renderer_initialized) {
      return;
    }

    if (this.needsUpdate) {
      this.updateViewport();
    }
  }
}
