
import Logger from '~/plugins/starpeace-client/logger.coffee'

import PlanetaryMetadataManager from '~/plugins/starpeace-client/metadata/planetary-metadata-manager.coffee'
import PlanetTypeManifestManager from '~/plugins/starpeace-client/metadata/planet-type-manifest-manager.coffee'

import Managers from '~/plugins/starpeace-client/manager/managers.coffee'

import EventListener from '~/plugins/starpeace-client/state/event-listener.coffee'
import GameState from '~/plugins/starpeace-client/state/game-state.coffee'
import MenuState from '~/plugins/starpeace-client/state/menu-state.coffee'
import UIState from '~/plugins/starpeace-client/state/ui-state.coffee'

import Renderer from '~/plugins/starpeace-client/renderer/renderer.coffee'
import CameraManager from '~/plugins/starpeace-client/renderer/camera/camera-manager.coffee'
import InputHandler from '~/plugins/starpeace-client/renderer/input/input-handler.coffee'


export default class Client
  constructor: () ->
    @event_listener = new EventListener()
    @event_listener.subscribe_asset_listener(=> @notify_assets_changed())

    @game_state = new GameState()
    @menu_state = new MenuState()
    @ui_state = new UIState()

    @managers = new Managers(@event_listener, @game_state, @ui_state)

    @renderer = new Renderer(@event_listener, @managers, @game_state, @ui_state)
    @camera_manager = new CameraManager(@renderer, @game_state)
    @input_handler = new InputHandler(@menu_state, @camera_manager, @renderer)

    @initialize_callback = null

    Logger.banner()

  notify_assets_changed: () ->
    return unless @managers.has_assets()

    @game_state.has_assets = true

    clearTimeout(@initialize_callback) if @initialize_callback
    @initialize_callback = setTimeout(=>
      @managers.initialize()
      @renderer.initialize()
      @input_handler.initialize()
    , 500)

  tick: () ->
    @renderer.tick() if @renderer.initialized
