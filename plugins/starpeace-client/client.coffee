
import moment from 'moment'

import Logger from '~/plugins/starpeace-client/logger.coffee'

import Managers from '~/plugins/starpeace-client/managers.coffee'

import AjaxState from '~/plugins/starpeace-client/state/ajax-state.coffee'
import ClientState from '~/plugins/starpeace-client/state/client-state.coffee'
import Options from '~/plugins/starpeace-client/state/options.coffee'

import MiniMapRenderer from '~/plugins/starpeace-client/renderer/mini-map-renderer.coffee'
import Renderer from '~/plugins/starpeace-client/renderer/renderer.coffee'
import InputHandler from '~/plugins/starpeace-client/renderer/input/input-handler.coffee'

import Identity from '~/plugins/starpeace-client/identity/identity.coffee'
import APIClient from '~/plugins/starpeace-client/api/api-client.coffee'

export default class Client
  constructor: () ->
    @options = new Options()
    @ajax_state = new AjaxState()
    @client_state = new ClientState(@options)
    @client_state.subscribe_workflow_status_listener(=> @notify_workflow_changed())

    @api = new APIClient(@ajax_state)

    @managers = new Managers(@api, @options, @ajax_state, @client_state)

    @renderer = new Renderer(@managers, @client_state, @options)
    @mini_map_renderer = new MiniMapRenderer(@managers, @renderer, @client_state, @options)
    @input_handler = new InputHandler(@renderer, @client_state)

    @refresh_events_interval = null

    Logger.banner()


  notify_workflow_changed: () ->

    if @client_state.workflow_status == 'pending_tycoon_metadata' && @client_state.state_needs_tycoon_metadata() && !@ajax_state.is_locked('tycoon_metadata', @client_state.session.tycoon_id)
      @managers.tycoon_manager.load_metadata()

    else if @client_state.workflow_status == 'pending_system_metadata' && @client_state.state_needs_system_metadata() && !@ajax_state.is_locked('systems_metadata', 'ALL')
      @managers.systems_manager.load_metadata()

    if @client_state.workflow_status == 'pending_initialization' && !@client_state.loading
      @client_state.loading = true

      @managers.initialize()
      @renderer.initialize()
      @input_handler.initialize()
      @mini_map_renderer.initialize()

      @client_state.finish_initialization()

    else if @client_state.workflow_status == 'ready'
      @client_state.loading = false

      clearTimeout(@refresh_events_interval) if @refresh_events_interval?
      @refresh_events_interval = setInterval(=>
        if @client_state.workflow_status == 'ready'
          Promise.all([
            @managers.planets_manager.load_events(),
            if @client_state.player.corporation_id?.length then @managers.corporation_manager.load_events() else Promise.resolve(true)
          ]).then ->
            Logger.debug "refreshed events"
        else
          clearTimeout(@refresh_events_interval)
          @refresh_events_interval = null
      , 5000)


  tick: () ->
    if @client_state.initialized && @client_state.workflow_status == 'ready'
      @renderer.tick() if @client_state.renderer_initialized
      @mini_map_renderer.tick() if @client_state.mini_map_renderer_initialized
