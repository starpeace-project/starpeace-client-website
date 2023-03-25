import { markRaw, reactive } from 'vue';

import Logger from '~/plugins/starpeace-client/logger.coffee'

import Managers from '~/plugins/starpeace-client/managers.coffee'

import AjaxState from '~/plugins/starpeace-client/state/ajax-state.coffee'
import ClientState from '~/plugins/starpeace-client/state/client-state.coffee'
import Options from '~/plugins/starpeace-client/state/options.coffee'

import BuildingImageRenderer from '~/plugins/starpeace-client/renderer/building-image-renderer.coffee'
import MiniMapRenderer from '~/plugins/starpeace-client/renderer/mini-map-renderer.coffee'
import Renderer from '~/plugins/starpeace-client/renderer/renderer.coffee'

import Identity from '~/plugins/starpeace-client/identity/identity.coffee'
import APIClient from '~/plugins/starpeace-client/api/api-client.coffee'

WEBGL_CONTAINER_CONSTRUCTION = 'construction-image-webgl-container'
WEBGL_CONTAINER_INSPECT = 'inspect-image-webgl-container'

export default class Client
  constructor: (disableRightClick) ->
    @options = reactive(new Options())
    @options.initialize()
    @options.subscribe_options_listener => @notify_options_changed()
    @ajax_state = reactive(new AjaxState())
    @client_state = reactive(new ClientState(@options, @ajax_state))
    @client_state.reset_full_state()
    @client_state.configureListeners()
    @client_state.subscribe_workflow_status_listener => @notify_workflow_changed()

    @api = markRaw(new APIClient(@client_state))

    @managers = markRaw(new Managers(@api, @options, @ajax_state, @client_state))

    @renderer = markRaw(new Renderer(@managers, @client_state, @options, disableRightClick))
    @mini_map_renderer = markRaw(new MiniMapRenderer(@managers, @renderer, @client_state, @options))
    @construction_preview_renderer = markRaw(new BuildingImageRenderer(@managers, @client_state, WEBGL_CONTAINER_CONSTRUCTION,
      (=> @client_state.construction_preview_renderer_initialized), (=> @client_state.construction_preview_renderer_initialized = true),
      (=> @client_state.interface.construction_selected_building_id), @options))
    @inspect_preview_renderer = markRaw(new BuildingImageRenderer(@managers, @client_state, WEBGL_CONTAINER_INSPECT,
      (=> @client_state.inspect_preview_renderer_initialized), (=> @client_state.inspect_preview_renderer_initialized = true),
      (=> @client_state.selected_building()?.definition_id), @options))

    @refresh_events_interval = null

    Logger.banner()

  notify_options_changed: () ->
    # update translations?

  notify_workflow_changed: () ->
    if @client_state.workflow_status == 'pending_initialization' && !@client_state.loading
      @client_state.loading = true

      @renderer.initialize()
      @managers.initialize(@renderer.application.renderer.extract)
      @mini_map_renderer.initialize()
      @construction_preview_renderer.initialize()
      @inspect_preview_renderer.initialize()

      @client_state.finish_initialization()

    else if @client_state.workflow_status == 'ready'
      @client_state.loading = false

      clearTimeout(@refresh_events_interval) if @refresh_events_interval?
      @refresh_events_interval = setInterval(=>
        if @client_state.workflow_status == 'ready'
          refresh_promises = []
          refresh_promises.push @managers.mail_manager.load_by_corporation(@client_state.player.corporation_id) if @client_state.has_new_mail()
          refresh_promises.push @managers.invention_manager.load_by_company(company_id) for company_id in @client_state.corporation.company_ids_with_pending_inventions()

          if @client_state.interface.selected_building_id?.length
            refresh_promises.push @managers.building_manager.load_building_metadata(@client_state.interface.selected_building_id)

            selected_building = @client_state.selected_building()
            selected_building_company = if selected_building? then @client_state.core.company_cache.metadata_for_id(selected_building.company_id) else null
            refresh_promises.push @managers.company_manager.load_by_company(selected_building.company_id) if selected_building && !selected_building_company

          if refresh_promises.length
            Promise.all(refresh_promises)
              .then -> Logger.debug "refreshed recent events"
              .then => @client_state.has_dirty_metadata = true
              .catch (err) => @client_state.add_error_message('Failure refreshing recent events from server', err)
        else
          clearTimeout(@refresh_events_interval)
          @refresh_events_interval = null
      , 2500)


  tick: () ->
    if @client_state.initialized && @client_state.workflow_status == 'ready'
      @renderer.tick() if @client_state.renderer_initialized
      @mini_map_renderer.tick() if @client_state.mini_map_renderer_initialized
      @construction_preview_renderer.tick() if @client_state.construction_preview_renderer_initialized && @client_state?.menu?.is_visible('construction') && @client_state.interface.construction_selected_building_id?.length
      @inspect_preview_renderer.tick() if @client_state.inspect_preview_renderer_initialized && @client_state?.interface?.show_inspect && @client_state?.interface?.selected_building_id?.length
