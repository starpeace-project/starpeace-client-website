
import Logger from '~/plugins/starpeace-client/logger.coffee'

import PlanetaryMetadataManager from '~/plugins/starpeace-client/metadata/planetary-metadata-manager.coffee'
import PlanetTypeManifestManager from '~/plugins/starpeace-client/metadata/planet-type-manifest-manager.coffee'

import Managers from '~/plugins/starpeace-client/manager/managers.coffee'

import GameMap from '~/plugins/starpeace-client/map/game-map.coffee'

import BookmarkManager from '~/plugins/starpeace-client/map/bookmark/bookmark-manager.coffee'

import EventListener from '~/plugins/starpeace-client/state/event-listener.coffee'
import GameState from '~/plugins/starpeace-client/state/game-state.coffee'
import MenuState from '~/plugins/starpeace-client/state/menu-state.coffee'
import Options from '~/plugins/starpeace-client/state/options.coffee'
import UIState from '~/plugins/starpeace-client/state/ui-state.coffee'

import MusicManager from '~/plugins/starpeace-client/sound/music-manager.coffee'

import MiniMapRenderer from '~/plugins/starpeace-client/renderer/mini-map-renderer.coffee'
import Renderer from '~/plugins/starpeace-client/renderer/renderer.coffee'
import CameraManager from '~/plugins/starpeace-client/renderer/camera/camera-manager.coffee'
import InputHandler from '~/plugins/starpeace-client/renderer/input/input-handler.coffee'


export default class Client
  constructor: () ->
    @event_listener = new EventListener()
    @event_listener.subscribe_asset_listener(=> @notify_assets_changed())

    @options = new Options()
    @game_state = new GameState()
    @menu_state = new MenuState()
    @ui_state = new UIState(@options)

    @managers = new Managers(@event_listener, @game_state, @ui_state)
    @music_manager = new MusicManager(@game_state)

    @renderer = new Renderer(@event_listener, @managers, @game_state, @options, @ui_state)
    @mini_map_renderer = new MiniMapRenderer(@event_listener, @managers, @renderer, @game_state, @options, @ui_state)
    @camera_manager = new CameraManager(@renderer, @game_state)
    @input_handler = new InputHandler(@game_state, @menu_state, @camera_manager, @renderer)

    @bookmark_manager = new BookmarkManager(@game_state, @options)

    @initialize_callback = null

    Logger.banner()

  initialize_game_map: () ->
    planet = @game_state.current_planet
    @game_state.game_map = new GameMap(@event_listener, @managers.building_manager, @managers.road_manager, @managers.overlay_manager,
        @managers.planet_type_manifest_manager.planet_type_manifest[planet.planet_type], @managers.planetary_manager.map_id_texture[planet.map_id], @options, @ui_state)

  notify_assets_changed: () ->
    return unless @managers.has_assets()
    @game_state.has_assets = true
    @game_state.loading = true

    clearTimeout(@initialize_callback) if @initialize_callback
    @initialize_callback = setTimeout(=>
      @managers.initialize()
      @initialize_game_map()
      @renderer.initialize()
      @input_handler.initialize()
      @mini_map_renderer.initialize()
      @game_state.initialized = true

      @bookmark_manager.load()

      setTimeout (=> @game_state.loading = false), 500
    , 500)

  tick: () ->
    @renderer.tick() if @renderer.initialized
    @mini_map_renderer.tick() if @mini_map_renderer.initialized
