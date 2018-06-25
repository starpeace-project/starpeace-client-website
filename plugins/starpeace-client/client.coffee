
import PlanetaryMetadataManager from '~/plugins/starpeace-client/metadata/planetary-metadata-manager.coffee'
import PlanetTypeManifestManager from '~/plugins/starpeace-client/metadata/planet-type-manifest-manager.coffee'

import AssetManager from '~/plugins/starpeace-client/loader/asset-manager.coffee'
import BuildingManager from '~/plugins/starpeace-client/loader/building-manager.coffee'
import OverlayManager from '~/plugins/starpeace-client/loader/overlay-manager.coffee'

import GameState from '~/plugins/starpeace-client/state/game-state.coffee'
import MenuState from '~/plugins/starpeace-client/state/menu-state.coffee'
import UIState from '~/plugins/starpeace-client/state/ui-state.coffee'

import Renderer from '~/plugins/starpeace-client/renderer/renderer.coffee'
import CameraManager from '~/plugins/starpeace-client/renderer/camera-manager.coffee'
import InputHandler from '~/plugins/starpeace-client/renderer/input-handler.coffee'

import EventManager from '~/plugins/starpeace-client/event-manager.coffee'

CLIENT_VERSION = "0.1.0"

class Client
  constructor: () ->
    @planetary_metadata_manager = new PlanetaryMetadataManager(@)
    @planet_type_manifest_manager = new PlanetTypeManifestManager(@)

    @asset_manager = new AssetManager(@)
    @building_manager = new BuildingManager(@)
    @overlay_manager = new OverlayManager(@)

    @game_state = new GameState()
    @menu_state = new MenuState()
    @ui_state = new UIState()

    @renderer = new Renderer(@)
    @camera_manager = new CameraManager(@, @renderer)
    @input_handler = new InputHandler(@camera_manager, @renderer)

    @event_manager = new EventManager(@)

    @initialize_callback = null

    console.debug "[starpeace] client v#{CLIENT_VERSION} created"


  has_planet_assets: () ->
    planet = @game_state.current_planet
    planet?.planet_type?.length && planet?.map_id?.length &&
      @asset_manager.planet_type_metadata[planet.planet_type]? &&
      @asset_manager.planet_type_atlas[planet.planet_type]?.length &&
      @asset_manager.map_id_texture[planet.map_id]?

  notify_assets_changed: () ->
    return unless @has_planet_assets()
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
