
import AssetManager from '~/plugins/starpeace-client/loader/asset-manager.coffee'
import BuildingManager from '~/plugins/starpeace-client/loader/building-manager.coffee'
import EffectManager from '~/plugins/starpeace-client/loader/effect-manager.coffee'
import EventManager from '~/plugins/starpeace-client/loader/event-manager.coffee'
import OverlayManager from '~/plugins/starpeace-client/loader/overlay-manager.coffee'
import PlaneManager from '~/plugins/starpeace-client/loader/plane-manager.coffee'
import PlanetaryManager from '~/plugins/starpeace-client/loader/planetary-manager.coffee'

import PlanetaryMetadataManager from '~/plugins/starpeace-client/metadata/planetary-metadata-manager.coffee'
import PlanetTypeManifestManager from '~/plugins/starpeace-client/metadata/planet-type-manifest-manager.coffee'

export default class Managers
  constructor: (@event_listener, @game_state, @ui_state) ->
    @asset_manager = new AssetManager(@game_state)
    @building_manager = new BuildingManager(@asset_manager, @event_listener, @game_state)
    @effect_manager = new EffectManager(@asset_manager, @event_listener)
    @event_manager = new EventManager(@asset_manager, @game_state, @ui_state)
    @overlay_manager = new OverlayManager(@asset_manager, @event_listener, @game_state)
    @plane_manager = new PlaneManager(@asset_manager, @event_listener, @game_state, @ui_state)

    @planet_type_manifest_manager = new PlanetTypeManifestManager()
    @planetary_metadata_manager = new PlanetaryMetadataManager(@identity)
    @planetary_manager = new PlanetaryManager(@asset_manager, @planet_type_manifest_manager, @event_listener)

    @event_listener.subscribe_planet_listener(=> @queue_asset_load())

  has_assets: () ->
    @game_state.current_planet? && @building_manager.has_assets() && @effect_manager.has_assets() && @event_manager.has_assets() &&
      @overlay_manager.has_assets() && @planetary_manager.has_assets(@game_state.current_planet) && @plane_manager.has_assets()

  queue_asset_load: () ->
    @building_manager.queue_asset_load()
    @effect_manager.queue_asset_load()
    @event_manager.queue_asset_load()
    @overlay_manager.queue_asset_load()
    @plane_manager.queue_asset_load()
    @planetary_manager.queue_asset_load(@game_state.current_planet.planet_type, @game_state.current_planet.map_id)

    @asset_manager.load_queued()

  initialize: () ->
    @event_manager.update_message()
