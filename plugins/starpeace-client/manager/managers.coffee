
import AssetManager from '~/plugins/starpeace-client/manager/asset-manager.coffee'
import BookmarkManager from '~/plugins/starpeace-client/map/bookmark/bookmark-manager.coffee'
import BuildingManager from '~/plugins/starpeace-client/manager/building-manager.coffee'
import ConcreteManager from '~/plugins/starpeace-client/manager/concrete-manager.coffee'
import CorporationManager from '~/plugins/starpeace-client/industry/corporation-manager.coffee'
import EffectManager from '~/plugins/starpeace-client/manager/effect-manager.coffee'
import EventManager from '~/plugins/starpeace-client/manager/event-manager.coffee'
import InventionManager from '~/plugins/starpeace-client/manager/invention-manager.coffee'
import LandManager from '~/plugins/starpeace-client/manager/land-manager.coffee'
import MailManager from '~/plugins/starpeace-client/mail/mail-manager.coffee'
import OverlayManager from '~/plugins/starpeace-client/manager/overlay-manager.coffee'
import PlaneManager from '~/plugins/starpeace-client/manager/plane-manager.coffee'
import PlanetsManager from '~/plugins/starpeace-client/planet/planets-manager.coffee'
import RoadManager from '~/plugins/starpeace-client/manager/road-manager.coffee'
import SystemsManager from '~/plugins/starpeace-client/planet/systems-manager.coffee'
import TranslationManager from '~/plugins/starpeace-client/manager/translation-manager.coffee'
import TycoonManager from '~/plugins/starpeace-client/tycoon/tycoon-manager.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class Managers
  constructor: (api, @event_listener, options, @game_state, @ui_state) ->
    @asset_manager = new AssetManager(@game_state)
    @bookmark_manager = new BookmarkManager(api, @event_listener, @game_state)
    @building_manager = new BuildingManager(api, @asset_manager, @event_listener, @game_state)
    @concrete_manager = new ConcreteManager(@asset_manager, @event_listener)
    @corporation_manager = new CorporationManager(api, @event_listener, @game_state)
    @effect_manager = new EffectManager(@asset_manager, @event_listener)
    @event_manager = new EventManager(@asset_manager, @game_state, @ui_state)
    @invention_manager = new InventionManager(api, @asset_manager, @building_manager, @event_listener, @game_state)
    @land_manager = new LandManager(@asset_manager, @event_listener, @game_state)
    @mail_manager = new MailManager(api, @event_listener, @game_state)
    @overlay_manager = new OverlayManager(@asset_manager, @event_listener, @game_state)
    @plane_manager = new PlaneManager(@asset_manager, @event_listener, @game_state, @ui_state)
    @planets_manager = new PlanetsManager(api, @event_listener, @game_state)
    @road_manager = new RoadManager(@asset_manager, @event_listener, @game_state)
    @systems_manager = new SystemsManager(api, @game_state)
    @translation_manager = new TranslationManager(@asset_manager, @event_listener, options, @game_state)
    @tycoon_manager = new TycoonManager(api, @game_state)

    @event_listener.subscribe_session_listener(=>
      @refresh_systems_metadata()
      @refresh_tycoon_metadata()
    )
    @event_listener.subscribe_system_listener(=>
      @refresh_planets_metadata()
    )
    @event_listener.subscribe_corporation_listener(=>
      @refresh_corporation_metadata()
      @refresh_bookmarks_metadata()
      @refresh_mail_metadata()
    )
    @event_listener.subscribe_planet_listener(=>
      @queue_asset_load()
      @refresh_planet_details()
    )


  has_assets: () ->
    @game_state.session_state.planet_id? && @building_manager.has_assets() && @concrete_manager.has_assets() && @effect_manager.has_assets() && @event_manager.has_assets() && @invention_manager.has_assets() &&
      @overlay_manager.has_assets() && @land_manager.has_assets() && @plane_manager.has_assets() && @road_manager.has_assets() && @translation_manager.has_assets()

  queue_asset_load: () ->
    @building_manager.queue_asset_load()
    @concrete_manager.queue_asset_load()
    @effect_manager.queue_asset_load()
    @event_manager.queue_asset_load()
    @invention_manager.queue_asset_load()
    @overlay_manager.queue_asset_load()
    @plane_manager.queue_asset_load()
    @land_manager.queue_asset_load()
    @road_manager.queue_asset_load()
    @translation_manager.queue_asset_load()

    @asset_manager.load_queued()

  initialize: () ->
    @event_manager.update_message()
    @invention_manager.initialize()
    @bookmark_manager.initialize()


  refresh_systems_metadata: () ->
    return if @game_state.common_metadata.is_refreshing_systems_metadata() || @game_state.common_metadata.has_systems_metadata_fresh()
    @systems_manager.load_metadata()
      .then ->
        Logger.debug "loaded systems metadata"
      .catch (err) ->
        console.log "error loading systems metadata #{err}" # FIXME: TODO: figure out error handling

  refresh_planets_metadata: (system_id=null) ->
    system_id = @game_state.session_state.system_id unless system_id?.length
    return if @game_state.common_metadata.is_refreshing_planets_metadata_for_system_id(system_id) || @game_state.common_metadata.has_planets_metadata_fresh_for_system_id(system_id)
    @planets_manager.load_metadata(system_id)
      .then ->
        Logger.debug "loaded planets metadata"
      .catch (err) ->
        console.log "error loading planets metadata #{err}" # FIXME: TODO: figure out error handling

  refresh_planet_details: () ->
    return unless @game_state.session_state.planet_id?.length
    return if @game_state.session_state.is_refreshing_planet_details() || @game_state.session_state.has_planet_details_fresh()
    @planets_manager.load_details(@game_state.session_state.planet_id)
      .then ->
        Logger.debug "loaded planet details"
      .catch (err) ->
        console.log "error loading planet details #{err}" # FIXME: TODO: figure out error handling

  refresh_tycoon_metadata: () ->
    return if @game_state.session_state.is_refreshing_tycoon_metadata() || @game_state.session_state.has_tycoon_metadata_fresh()
    @tycoon_manager.load_metadata()
      .then ->
        Logger.debug "loaded tycoon metadata"
      .catch (err) ->
        console.log "error loading tycoon metadata #{err}" # FIXME: TODO: figure out error handling

  refresh_corporation_metadata: () ->
    return if @game_state.session_state.is_refreshing_corporation_metadata() || @game_state.session_state.has_corporation_metadata_fresh()
    return unless @game_state.session_state.corporation_id?.length
    @corporation_manager.load_metadata(@game_state.session_state.corporation_id)
      .then ->
        Logger.debug "loaded corporation metadata"
      .catch (err) ->
        console.log "error loading corporation metadata #{err}" # FIXME: TODO: figure out error handling

  refresh_bookmarks_metadata: () ->
    return if @game_state.session_state.is_refreshing_bookmarks_metadata() || @game_state.session_state.has_bookmarks_metadata_fresh()
    return unless @game_state.session_state.corporation_id?.length
    @bookmark_manager.load_metadata(@game_state.session_state.corporation_id)
      .then ->
        Logger.debug "loaded bookmarks metadata for corporation"
      .catch (err) ->
        console.log "error loading bookmarks metadata #{err}" # FIXME: TODO: figure out error handling

  refresh_mail_metadata: () ->
    return if @game_state.session_state.is_refreshing_mail_metadata() || @game_state.session_state.has_mail_metadata_fresh()
    return unless @game_state.session_state.corporation_id?.length
    @mail_manager.load_metadata(@game_state.session_state.corporation_id)
      .then ->
        Logger.debug "loaded mail metadata for corporation"
      .catch (err) ->
        console.log "error loading mail metadata #{err}" # FIXME: TODO: figure out error handling
