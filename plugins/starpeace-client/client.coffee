
import moment from 'moment'

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

export default class Client
  constructor: () ->
    @options = new Options()
    @options.subscribe_options_listener => @notify_options_changed()
    @ajax_state = new AjaxState()
    @client_state = new ClientState(@options, @ajax_state)
    @client_state.subscribe_workflow_status_listener => @notify_workflow_changed()

    @api = new APIClient(@client_state)

    @managers = new Managers(@api, @options, @ajax_state, @client_state)

    @renderer = new Renderer(@managers, @client_state, @options)
    @mini_map_renderer = new MiniMapRenderer(@managers, @renderer, @client_state, @options)
    @construction_preview_renderer = new BuildingImageRenderer(@managers, @client_state, @options)

    @refresh_events_interval = null

    Logger.banner()

    @client_state.core.galaxy_cache.load_galaxy_configuration(galaxy.id, galaxy) for galaxy in @client_state.options.get_galaxies()

  notify_options_changed: () ->
    if @client_state.initialized && @client_state.workflow_status == 'ready'
      unless @client_state.core.translations_library.has_metadata(@options.language())
        @client_state.loading = true
        @managers.event_manager.queue_asset_load(=> @managers.event_manager.update_message())
        @managers.translation_manager.queue_asset_load(=>
          @options.notify_options_listeners() # workaround to ensure UI is refreshed after translations load, rendering correct text
          @client_state.loading = false
        )
        @managers.asset_manager.load_queued()

  notify_workflow_changed: () ->
    if @client_state.workflow_status == 'pending_tycoon_metadata' && @client_state.state_needs_tycoon_metadata() && !@ajax_state.is_locked('tycoon_metadata', @client_state.session.tycoon_id)
      @managers.tycoon_manager.load_metadata()

    else if @client_state.workflow_status == 'pending_galaxy_metadata' && @client_state.state_needs_galaxy_metadata() && !@ajax_state.is_locked('galaxy_metadata', @client_state.identity.galaxy_id)
      @managers.galaxy_manager.load_metadata(@client_state.identity.galaxy_id)

    if @client_state.workflow_status == 'pending_initialization' && !@client_state.loading
      @client_state.loading = true

      @managers.initialize()
      @renderer.initialize()
      @mini_map_renderer.initialize()
      @construction_preview_renderer.initialize()

      @client_state.finish_initialization()

    else if @client_state.workflow_status == 'ready'
      @client_state.loading = false

      clearTimeout(@refresh_events_interval) if @refresh_events_interval?
      @refresh_events_interval = setInterval(=>
        if @client_state.workflow_status == 'ready'
          refresh_promises = []
          refresh_promises.push @managers.planets_manager.load_events()
          refresh_promises.push @managers.corporation_manager.load_events() if @client_state.player.corporation_id?.length
          refresh_promises.push @managers.invention_manager.load_metadata(company_id) for company_id in @client_state.corporation.company_ids_with_pending_inventions()
          refresh_promises.push @managers.building_manager.load_building_metadata(@client_state.interface.selected_building_id) if @client_state.interface.selected_building_id?.length

          Promise.all(refresh_promises).then ->
            Logger.debug "refreshed events"
        else
          clearTimeout(@refresh_events_interval)
          @refresh_events_interval = null
      , 5000)


  tick: () ->
    if @client_state.initialized && @client_state.workflow_status == 'ready'
      @renderer.tick() if @client_state.renderer_initialized
      @mini_map_renderer.tick() if @client_state.mini_map_renderer_initialized
      @construction_preview_renderer.tick() if @client_state.construction_preview_renderer_initialized
