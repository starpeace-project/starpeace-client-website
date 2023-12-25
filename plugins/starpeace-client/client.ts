import { markRaw, reactive } from 'vue';

import Logger from '~/plugins/starpeace-client/logger.js'

import Managers from '~/plugins/starpeace-client/managers.js'

import AjaxState from '~/plugins/starpeace-client/state/ajax-state.js'
import ClientState from '~/plugins/starpeace-client/state/client-state.js'
import Options from '~/plugins/starpeace-client/state/options/options.js'

import BuildingImageRenderer from '~/plugins/starpeace-client/renderer/building-image-renderer.coffee'
import MiniMapRenderer from '~/plugins/starpeace-client/renderer/mini-map-renderer.coffee'
import Renderer from '~/plugins/starpeace-client/renderer/renderer.coffee'

import ApiClient from '~/plugins/starpeace-client/api/api-client.js';

const WEBGL_CONTAINER_CONSTRUCTION = 'construction-image-webgl-container';
const WEBGL_CONTAINER_INSPECT = 'inspect-image-webgl-container';

export default class Client {
  options: Options;
  ajax_state: AjaxState;
  client_state: ClientState;

  api: ApiClient;
  managers: Managers;

  renderer: Renderer;
  mini_map_renderer: Renderer;
  construction_preview_renderer: Renderer;
  inspect_preview_renderer: Renderer;

  constructor (clientVersion: string, disableRightClick: boolean) {
    this.options = reactive(new Options());
    this.options.initialize();
    this.ajax_state = reactive(new AjaxState());
    this.client_state = reactive(new ClientState(this.options, this.ajax_state));
    this.client_state.reset_full_state();
    this.client_state.configureListeners();
    this.client_state.subscribe_workflow_status_listener(() => this.notify_workflow_changed());

    this.api = markRaw(new ApiClient(this.client_state));
    this.managers = markRaw(new Managers(this.api, this.options, this.ajax_state, this.client_state));

    this.renderer = markRaw(new Renderer(this.managers, this.client_state, this.options, disableRightClick));
    this.mini_map_renderer = markRaw(new MiniMapRenderer(this.managers, this.renderer, this.client_state, this.options));
    this.construction_preview_renderer = markRaw(new BuildingImageRenderer(this.managers, this.client_state, WEBGL_CONTAINER_CONSTRUCTION,
      () => this.client_state.construction_preview_renderer_initialized, () => this.client_state.construction_preview_renderer_initialized = true,
      () => this.client_state.interface.construction_selected_building_id, this.options));
    this.inspect_preview_renderer = markRaw(new BuildingImageRenderer(this.managers, this.client_state, WEBGL_CONTAINER_INSPECT,
      () => this.client_state.inspect_preview_renderer_initialized, () => this.client_state.inspect_preview_renderer_initialized = true,
      () => this.client_state.selected_building()?.definition_id, this.options));

    Logger.banner(clientVersion);
  }

  notify_workflow_changed (): void {
    if (this.client_state.workflow_status == 'pending_initialization') {
      if (!this.client_state.renderer_initialized && !this.client_state.renderer_initializing) {
        this.renderer.initialize();
      }
      if (this.client_state.renderer_initialized && !this.client_state.managers_initialized && !this.client_state.managers_initializing) {
        this.managers.initialize(this.renderer.application.renderer.extract);
      }

      if (this.client_state.managers_initialized && !this.client_state.mini_map_renderer_initialized && !this.client_state.mini_map_renderer_initializing) {
        this.mini_map_renderer.initialize();
      }
      if (!this.client_state.construction_preview_renderer_initialized && !this.client_state.construction_preview_renderer_initializing) {
        this.construction_preview_renderer.initialize();
      }
      if (!this.client_state.inspect_preview_renderer_initialized && !this.client_state.inspect_preview_renderer_initializing) {
        this.inspect_preview_renderer.initialize();
      }

      if (!this.client_state.initialized && this.client_state.renderer_initialized && this.client_state.mini_map_renderer_initialized && this.client_state.construction_preview_renderer_initialized && this.client_state.inspect_preview_renderer_initialized && this.client_state.managers_initialized) {
        this.client_state.finish_initialization();
      }
    }
    else if (this.client_state.workflow_status === 'ready') {
      this.managers.startRefresh();
    }
  }

  tick (): void {
    if (this.client_state.initialized && this.client_state.workflow_status === 'ready') {
      if (this.client_state.renderer_initialized) {
        this.renderer.tick();
      }
      if (this.client_state.mini_map_renderer_initialized) {
        this.mini_map_renderer.tick();
      }
      if (this.client_state.construction_preview_renderer_initialized && this.client_state?.menu?.is_visible('construction') && this.client_state.interface.construction_selected_building_id?.length) {
        this.construction_preview_renderer.tick();
      }
      if (this.client_state.inspect_preview_renderer_initialized && this.client_state?.interface?.show_inspect && this.client_state?.interface?.selected_building_id?.length) {
        this.inspect_preview_renderer.tick();
      }
    }
  }
}
