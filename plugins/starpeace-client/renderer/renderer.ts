import '~/plugins/javascript-detect-element-resize/detect-element-resize';
import { Application, autoDetectRenderer } from 'pixi.js';
import Stats from 'stats.js';

import ChunkMap from '~/plugins/starpeace-client/map/chunk/chunk-map.js';

import InputHandler from '~/plugins/starpeace-client/renderer/input/input-handler.coffee';
import Layers from '~/plugins/starpeace-client/renderer/layer/layers.js';

import type ClientState from '~/plugins/starpeace-client/state/client-state.js';
import type Options from '~/plugins/starpeace-client/state/options/options.js';


export interface Offset {
  left: number;
  top: number;
}


export default class Renderer {
  managers: any;

  clientState: ClientState;
  options: Options;
  disableRightClick: boolean;

  inputHandler: InputHandler | undefined;

  rendererHeight: number = 0;
  rendererWidth: number = 0;
  offset: Offset | undefined;

  applicationFailures: number = 0;
  application: Application = new Application();
  layers: Layers | undefined;

  fpsMeter: any | undefined;

  constructor (managers: any, clientState: ClientState, options: Options, disableRightClick: boolean) {
    this.managers = managers;
    this.clientState = clientState;
    this.options = options;
    this.disableRightClick = disableRightClick;

    this.clientState.planet.subscribe_map_data_listener((chunk_event) => {
      if (this.layers?.cache) {
        const sourceX = (chunk_event.info.chunk_x - 0) * ChunkMap.CHUNK_WIDTH - 10;
        const targetX = (chunk_event.info.chunk_x + 1) * ChunkMap.CHUNK_WIDTH + 10;
        const sourceY = (chunk_event.info.chunk_y - 0) * ChunkMap.CHUNK_HEIGHT - 10;
        const targetY = (chunk_event.info.chunk_y + 1) * ChunkMap.CHUNK_HEIGHT + 10;
        this.layers.cache.clearCache(sourceX, targetX, sourceY, targetY);
      }
    });

    this.clientState.options.subscribe_options_listener(async (event: any) => {
      if (event.changedOptions.has('renderer.webgpu') && this.clientState.renderer_initialized) {
        await this.resetAndInitialize();
      }
    });
  }

  get renderer_height (): number {
    return this.rendererHeight;
  }
  get renderer_width (): number {
    return this.rendererWidth;
  }

  updateOffset (renderContainer: any | undefined): void {
    if (!!renderContainer.offsetParent) {
      const rect = renderContainer.getBoundingClientRect();
      this.offset = {
        top: rect.top + document.body.scrollTop,
        left: rect.left + document.body.scrollLeft
      };
    }
    else {
      this.offset = undefined;
    }
  }

  handleResize (): void {
    const renderContainer = document?.getElementById('render-container');
    this.updateOffset(renderContainer);

    if (renderContainer) {
      this.rendererWidth = Math.ceil(renderContainer.offsetWidth);
      this.rendererHeight = Math.ceil(renderContainer.offsetHeight);
      this.clientState.camera.resize(this.rendererWidth, this.rendererHeight);
      this.application.renderer.resize(this.rendererWidth, this.rendererHeight);
    }

    if (this.layers?.cache) {
      this.layers.cache.isDirty = true;
      this.layers.refresh();
    }
  }

  async resetAndInitialize (): Promise<void> {
    try {
      if (this.clientState.renderer_initialized) {
        this.clientState.renderer_initialized = false;
        this.application.destroy();
        this.application = new Application();
      }

      document?.getElementById('render-container')?.replaceChildren();
      await this.initialize();
    }
    catch (err) {
      this.applicationFailures += 1;

      if (this.applicationFailures < 10) {
        console.warn('Failed to reset renderer', err);
        setTimeout(() => this.resetAndInitialize(), 500);
      }
      else {
        this.options.setAndSaveOption('renderer.webgpu', false);
        this.applicationFailures = 0;
        this.clientState.reset_full_state();
      }
    }
  }

  async initializeApplication (): Promise<void> {
    const renderContainer = document?.getElementById('render-container');
    if (!renderContainer) {
      return;
    }

    // scroll to top (TODO: why?)
    setTimeout(scrollTo, 0, 0, 1);

    this.updateOffset(renderContainer);
    this.rendererWidth = Math.ceil(renderContainer.offsetWidth);
    this.rendererHeight = Math.ceil(renderContainer.offsetHeight);
    this.clientState.camera.resize(this.rendererWidth, this.rendererHeight);

    await this.application.init({
      preference: !!this.options.option('renderer.webgpu') ? 'webgpu' : 'webgl',
      autoStart: false,
      width: this.rendererWidth,
      height: this.rendererHeight,
      backgroundColor : 0x000000,
      resizeTo: undefined,
      eventFeatures: {
        click: true,
        globalMove: false,
        move: false,
        wheel: false
      }
    });

    renderContainer.appendChild(this.application.canvas);

    this.inputHandler = new InputHandler(this.managers, this, renderContainer, this.clientState);

    const fpsDom = document?.getElementById('fps-container');
    if (fpsDom && !this.fpsMeter) {
      this.fpsMeter = new Stats();
      fpsDom.appendChild(this.fpsMeter.dom);
    }

    (window as any)?.addResizeListener(renderContainer, () => this.handleResize());
  }

  initializeMap (): void {
    this.layers?.removeLayers(this.application.stage);
    this.layers?.destroy();
    this.layers = new Layers(this.managers.plane_manager, this.managers.translation_manager, this.clientState, this.options);
    this.layers.addLayers(this.application.stage);
  }

  async initialize (): Promise<void> {
    await this.initializeApplication();
    this.initializeMap();
    this.clientState.renderer_initialized = true;
    this.applicationFailures = 0;
  }

  tick (): void {
    if (!this.clientState.renderer_initialized) {
      return;
    }

    if (this.fpsMeter) {
      this.fpsMeter.begin();
    }

    if (!this.offset) {
      this.updateOffset(document?.getElementById('render-container'));
    }

    if (this.layers) {
      if (this.layers.cache.hasDirtyView) {
        this.clientState.planet_event_client.updateView();
      }

      if (this.layers.shouldRefresh) {
        this.layers.refresh();
      }

      this.layers.refreshPlanes();
    }

    this.application.render();
    if (this.fpsMeter) {
      this.fpsMeter.end();
    }
  }
}
