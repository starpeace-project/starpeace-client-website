
import GameMap from '~/plugins/starpeace-client/map/game-map.coffee'

import AssetManager from '~/plugins/starpeace-client/asset/asset-manager.coffee'
import BookmarkManager from '~/plugins/starpeace-client/bookmark/bookmark-manager.coffee'
import BuildingManager from '~/plugins/starpeace-client/building/building-manager.coffee'
import ConcreteManager from '~/plugins/starpeace-client/building/concrete-manager.coffee'
import EffectManager from '~/plugins/starpeace-client/asset/effect-manager.coffee'
import EventManager from '~/plugins/starpeace-client/event/event-manager.coffee'
import CorporationManager from '~/plugins/starpeace-client/industry/corporation-manager.coffee'
import InventionManager from '~/plugins/starpeace-client/invention/invention-manager.coffee'
import LandManager from '~/plugins/starpeace-client/land/land-manager.coffee'
import MapManager from '~/plugins/starpeace-client/land/map-manager.coffee'
import MailManager from '~/plugins/starpeace-client/mail/mail-manager.coffee'
import OverlayManager from '~/plugins/starpeace-client/overlay/overlay-manager.coffee'
import PlaneManager from '~/plugins/starpeace-client/plane/plane-manager.coffee'
import PlanetsManager from '~/plugins/starpeace-client/planet/planets-manager.coffee'
import SystemsManager from '~/plugins/starpeace-client/planet/systems-manager.coffee'
import RoadManager from '~/plugins/starpeace-client/road/road-manager.coffee'
import TranslationManager from '~/plugins/starpeace-client/language/translation-manager.coffee'
import TycoonManager from '~/plugins/starpeace-client/tycoon/tycoon-manager.coffee'

import Identity from '~/plugins/starpeace-client/identity/identity.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class Managers
  constructor: (@api, @options, @ajax_state, @client_state) ->
    @asset_manager = new AssetManager(@ajax_state)

    @translation_manager = new TranslationManager(@asset_manager, @ajax_state, @client_state, @options)

    @bookmark_manager = new BookmarkManager(@api, @translation_manager, @ajax_state, @client_state)
    @building_manager = new BuildingManager(@api, @asset_manager, @translation_manager, @ajax_state, @client_state)
    @concrete_manager = new ConcreteManager(@asset_manager, @ajax_state, @client_state)
    @corporation_manager = new CorporationManager(@api, @ajax_state, @client_state)
    @effect_manager = new EffectManager(@asset_manager, @ajax_state, @client_state)
    @event_manager = new EventManager(@asset_manager, @ajax_state, @client_state)
    @invention_manager = new InventionManager(@api, @asset_manager, @ajax_state, @client_state)
    @land_manager = new LandManager(@asset_manager, @ajax_state, @client_state)
    @map_manager = new MapManager(@asset_manager, @ajax_state, @client_state)
    @mail_manager = new MailManager(@api, @ajax_state, @client_state)
    @overlay_manager = new OverlayManager(@asset_manager, @ajax_state, @client_state)
    @plane_manager = new PlaneManager(@asset_manager, @ajax_state, @client_state)
    @planets_manager = new PlanetsManager(@api, @ajax_state, @client_state)
    @road_manager = new RoadManager(@asset_manager, @ajax_state, @client_state)
    @systems_manager = new SystemsManager(@api, @ajax_state, @client_state)
    @tycoon_manager = new TycoonManager(@api, @ajax_state, @client_state)


    @client_state.identity.subscribe_visa_type_listener =>
      if @client_state.identity.visa_type == 'visitor'
        @client_state.identity.set_identity(Identity.visitor())
      else
        Identity.mock_tycoon()
          .then (identity) => @client_state.identity.set_identity(identity)
          .catch (error) -> Logger.debug "failed to retrieve identity" # FIXME: TODO: figure out error handling

    @client_state.identity.subscribe_identity_listener =>
      return unless @client_state.identity.identity?

      # FIXME: TODO: create/move to session_manager
      @api.register_session(@client_state.identity.identity)
        .then (session) =>
          @client_state.session.set_session_info(session)
        .catch (err) -> Logger.debug "failed to retrieve session for identity" # FIXME: TODO: figure out error handling

    @client_state.session.subscribe_session_token_listener =>
      @tycoon_manager.load_metadata() if @client_state.session.tycoon_id? && !@client_state.core.tycoon_cache.has_tycoon_metadata_fresh(@client_state.session.tycoon_id)
      @systems_manager.load_metadata() unless @client_state.core.systems_cache.has_systems_metadata_fresh()

    @client_state.player.subscribe_planet_id_listener =>
      return unless @client_state.player.system_id? && @client_state.player.planet_id?

      if @client_state.identity.identity.is_tycoon() && !@client_state.player.corporation_id?
        corporation = @client_state.core.corporation_cache.corporation_metadata_for_system_planet_tycoon_id(@client_state.player.system_id, @client_state.player.planet_id, @client_state.session.tycoon_id)
        @client_state.player.set_corporation_id(corporation.id) if corporation?

      @building_manager.queue_asset_load()
      @concrete_manager.queue_asset_load()
      @effect_manager.queue_asset_load()
      @event_manager.queue_asset_load()
      @invention_manager.queue_asset_load()
      @land_manager.queue_asset_load()
      @map_manager.queue_asset_load()
      @overlay_manager.queue_asset_load()
      @plane_manager.queue_asset_load()
      @road_manager.queue_asset_load()
      @translation_manager.queue_asset_load()

      @asset_manager.load_queued()
      @planets_manager.load_details(@client_state.player.planet_id)

    @client_state.player.subscribe_corporation_id_listener =>
      return unless @client_state.player.corporation_id?

      corporation = @client_state.core.corporation_cache.metadata_for_id(@client_state.player.corporation_id)
      return unless corporation?

      @client_state.corporation.set_company_ids(_.map(corporation.companies_metadata, (company) -> company.id)) if corporation.companies_metadata?.length
      @client_state.player.set_company_id(if corporation.companies_metadata?.length then  _.sortBy(corporation.companies_metadata, (company) -> company.name)[0].id else null)
      @client_state.player.set_system_id(corporation.system_id) unless @client_state.player.system_id == corporation.system_id
      @client_state.player.set_planet_id(corporation.planet_id) unless @client_state.player.planet_id == corporation.planet_id

      promises = []
      for company in (corporation.companies_metadata || [])
        promises.push @building_manager.load_metadata(company.id)
        promises.push @invention_manager.load_metadata(company.id)

      promises.push @corporation_manager.load_metadata(@client_state.player.corporation_id)
      promises.push @bookmark_manager.load_metadata(@client_state.player.corporation_id)
      promises.push @mail_manager.load_metadata(@client_state.player.corporation_id)

      Promise.all promises
        .then => Logger.debug 'loaded corporation metadata'
        .catch (err) => Logger.info "failed to retrieve data for corporation" # FIXME: TODO: add error handling


  initialize: () ->
    planet_metadata = @client_state.current_planet_metadata()
    @client_state.planet.load_game_map(new GameMap(@building_manager, @road_manager, @overlay_manager,
        @client_state.core.land_library.metadata_for_planet_type(planet_metadata.planet_type),
        @client_state.core.map_library.texture_for_id(planet_metadata.map_id), @client_state, @options))

    @event_manager.update_message()

    @building_manager.initialize()
    @invention_manager.initialize()
    @bookmark_manager.initialize()
