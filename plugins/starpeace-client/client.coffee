
import Logger from '~/plugins/starpeace-client/logger.coffee'

import PlanetaryMetadataManager from '~/plugins/starpeace-client/metadata/planetary-metadata-manager.coffee'
import PlanetTypeManifestManager from '~/plugins/starpeace-client/metadata/planet-type-manifest-manager.coffee'

import AssetManager from '~/plugins/starpeace-client/loader/asset-manager.coffee'
import BuildingManager from '~/plugins/starpeace-client/loader/building-manager.coffee'
import EventManager from '~/plugins/starpeace-client/loader/event-manager.coffee'
import OverlayManager from '~/plugins/starpeace-client/loader/overlay-manager.coffee'
import PlanetaryManager from '~/plugins/starpeace-client/loader/planetary-manager.coffee'

import GameState from '~/plugins/starpeace-client/state/game-state.coffee'
import MenuState from '~/plugins/starpeace-client/state/menu-state.coffee'
import UIState from '~/plugins/starpeace-client/state/ui-state.coffee'

import Renderer from '~/plugins/starpeace-client/renderer/renderer.coffee'
import CameraManager from '~/plugins/starpeace-client/renderer/camera-manager.coffee'
import InputHandler from '~/plugins/starpeace-client/renderer/input-handler.coffee'


CLIENT_VERSION = "0.1.0"

class Client
  constructor: () ->
    @planetary_metadata_manager = new PlanetaryMetadataManager(@)
    @planet_type_manifest_manager = new PlanetTypeManifestManager(@)

    @asset_manager = new AssetManager(@)
    @building_manager = new BuildingManager(@)
    @event_manager = new EventManager(@)
    @overlay_manager = new OverlayManager(@)
    @planetary_manager = new PlanetaryManager(@)

    @game_state = new GameState()
    @menu_state = new MenuState()
    @ui_state = new UIState()

    @renderer = new Renderer(@)
    @camera_manager = new CameraManager(@, @renderer)
    @input_handler = new InputHandler(@camera_manager, @renderer)

    @initialize_callback = null

    Logger.banner()

  select_planet: (planet) ->
    @game_state.current_planet = planet
    Logger.debug "proceeding with planet <#{@game_state.current_planet}>"

    @building_manager.queue_asset_load()
    @event_manager.queue_asset_load()
    @overlay_manager.queue_asset_load()
    @planetary_manager.queue_asset_load(@game_state.current_planet.planet_type, @game_state.current_planet.map_id)

    @asset_manager.load_queued()

  notify_assets_changed: () ->
    return unless @game_state.current_planet? && @building_manager.has_assets() && @event_manager.has_assets() &&
      @overlay_manager.has_assets() && @planetary_manager.has_assets(@game_state.current_planet)

    @game_state.has_assets = true

    clearTimeout(@initialize_callback) if @initialize_callback
    @initialize_callback = setTimeout(=>
      @renderer.initialize()
      @input_handler.initialize()
      @event_manager.update_message()
    , 500)

  tick: () ->
    @renderer.tick() if @renderer.initialized

export default Client
