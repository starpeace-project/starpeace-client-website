import '~/plugins/javascript-detect-element-resize/detect-element-resize';
import { Application, Cache, Container, Point, Sprite, Texture } from 'pixi.js';

import Managers from '~/plugins/starpeace-client/managers';
import ClientState from '~/plugins/starpeace-client/state/client-state';
import Options from '~/plugins/starpeace-client/state/options/options';

export default class BuildingImageRenderer {

  managers: Managers;

  clientState: ClientState;
  options: Options;

  renderDomId: string;
  rendererWidth: number = 0;
  rendererHeight: number = 0;

  checkInitializedCallback: any | undefined;
  initializeCallback: any | undefined;

  buildingIdCallback: any | undefined;
  lastBuildingId: string | undefined;

  application: Application = new Application();
  container: Container = new Container();
  sprite: Sprite = new Sprite();

  constructor (managers: Managers, clientState: ClientState, renderDomId: string, checkInitializedCallback: any, initializeCallback: any, buildingIdCallback: any, options: Options) {
    this.managers = managers;
    this.clientState = clientState;
    this.options = options;
    this.renderDomId = renderDomId;
    this.checkInitializedCallback = checkInitializedCallback;
    this.initializeCallback = initializeCallback;
    this.buildingIdCallback = buildingIdCallback;
  }

  handleResize (): void {
    const renderContainer = document?.getElementById(this.renderDomId);
    if (!renderContainer) {
      return;
    }

    this.rendererWidth = Math.ceil(renderContainer.offsetWidth)
    this.rendererHeight = Math.ceil(renderContainer.offsetHeight)
    this.application.renderer.resize(this.rendererWidth, this.rendererHeight);

    this.updateBuildingSprite();
  }

  async initializeApplication (): Promise<void> {
    const renderContainer = document?.getElementById(this.renderDomId);
    if (!renderContainer) {
      return;
    }

    this.rendererWidth = Math.ceil(renderContainer.offsetWidth);
    this.rendererHeight = Math.ceil(renderContainer.offsetHeight)

    await this.application.init({
      preference: !!this.options.option('renderer.webgpu') ? 'webgpu' : 'webgl',
      width: this.rendererWidth,
      height: this.rendererHeight,
      backgroundAlpha: 0,
      eventFeatures: {
        move: false,
        globalMove: false,
        click: false,
        wheel: false
      }
    })

    this.sprite = new Sprite(Texture.EMPTY)
    this.container.removeChildren();
    this.container.addChild(this.sprite);

    this.application.stage.addChild(this.container);

    renderContainer.appendChild(this.application.canvas);
    (window as any)?.addResizeListener(renderContainer, () => this.handleResize());
  }

  async initialize (): Promise<void> {
    await this.initializeApplication();

    this.lastBuildingId = undefined;
    this.initializeCallback();
  }


  get needsUpdate (): boolean {
    return this.lastBuildingId !== this.buildingIdCallback();
  }

  updateBuildingSprite (): void {
    if (!this.checkInitializedCallback()) {
      return;
    }

    const buildingId = this.buildingIdCallback();
    if (buildingId?.length > 0) {
      const definition = this.clientState.core.building_library.definition_for_id(buildingId);
      const buildingImage = definition?.imageId ? this.clientState.core.building_library.images_by_id[definition.imageId] : undefined;
      const texture = buildingImage?.frames?.length > 0 ? Cache.get(buildingImage.frames[0]) : Texture.EMPTY;

      const heightWithRenderWidth = this.rendererWidth * (texture.height / texture.width);
      const widthWithRenderHeight = this.rendererHeight * (texture.width / texture.height);

      const [textureWidth, textureHeight] = heightWithRenderWidth > this.rendererHeight ? [widthWithRenderHeight, this.rendererHeight] : [this.rendererWidth, heightWithRenderWidth];

      this.sprite.texture = texture;
      this.sprite.x = (this.rendererWidth - textureWidth) / 2;
      this.sprite.y = (this.rendererHeight - textureHeight) / 2;
      this.sprite.scale = new Point(textureWidth / texture.width, textureHeight / texture.height);
    }

    this.lastBuildingId = buildingId;
  }

  tick (): void {
    if (!this.checkInitializedCallback()) {
      return;
    }

    if (this.needsUpdate) {
      this.updateBuildingSprite();
    }
  }
}
