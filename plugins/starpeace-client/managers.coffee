
import GameMap from '~/plugins/starpeace-client/map/game-map.coffee'

import AssetManager from '~/plugins/starpeace-client/asset/asset-manager.coffee'
import BookmarkManager from '~/plugins/starpeace-client/bookmark/bookmark-manager.coffee'
import BuildingManager from '~/plugins/starpeace-client/building/building-manager.coffee'
import ConcreteManager from '~/plugins/starpeace-client/building/concrete-manager.coffee'
import CompanyManager from '~/plugins/starpeace-client/company/company-manager.coffee'
import CorporationManager from '~/plugins/starpeace-client/corporation/corporation-manager.coffee'
import EffectManager from '~/plugins/starpeace-client/asset/effect-manager.coffee'
import EventManager from '~/plugins/starpeace-client/event/event-manager.coffee'
import GalaxyManager from '~/plugins/starpeace-client/galaxy/galaxy-manager.coffee'
import InventionManager from '~/plugins/starpeace-client/invention/invention-manager.coffee'
import LandManager from '~/plugins/starpeace-client/land/land-manager.coffee'
import MapManager from '~/plugins/starpeace-client/land/map-manager.coffee'
import MailManager from '~/plugins/starpeace-client/mail/mail-manager.coffee'
import OverlayManager from '~/plugins/starpeace-client/overlay/overlay-manager.coffee'
import PlaneManager from '~/plugins/starpeace-client/plane/plane-manager.coffee'
import PlanetsManager from '~/plugins/starpeace-client/planet/planets-manager.coffee'
import RoadManager from '~/plugins/starpeace-client/road/road-manager.coffee'
import SignManager from '~/plugins/starpeace-client/asset/sign-manager.coffee'
import TranslationManager from '~/plugins/starpeace-client/language/translation-manager.coffee'
import TycoonManager from '~/plugins/starpeace-client/tycoon/tycoon-manager.coffee'

import TreeMenuUtils from '~/plugins/starpeace-client/utils/tree-menu-utils.coffee'

import Identity from '~/plugins/starpeace-client/identity/identity.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class Managers
  constructor: (@api, @options, @ajax_state, @client_state) ->
    @asset_manager = new AssetManager(@ajax_state)

    @translation_manager = new TranslationManager(@asset_manager, @ajax_state, @options, @client_state)

    @bookmark_manager = new BookmarkManager(@api, @translation_manager, @ajax_state, @client_state)
    @building_manager = new BuildingManager(@api, @asset_manager, @bookmark_manager, @translation_manager, @ajax_state, @client_state)
    @concrete_manager = new ConcreteManager(@asset_manager, @ajax_state, @client_state)
    @company_manager = new CompanyManager(@api, @ajax_state, @client_state)
    @corporation_manager = new CorporationManager(@api, @ajax_state, @client_state)
    @effect_manager = new EffectManager(@asset_manager, @ajax_state, @client_state)
    @event_manager = new EventManager(@asset_manager, @ajax_state, @client_state)
    @galaxy_manager = new GalaxyManager(@api, @ajax_state, @client_state)
    @invention_manager = new InventionManager(@api, @asset_manager, @ajax_state, @client_state)
    @land_manager = new LandManager(@asset_manager, @ajax_state, @client_state)
    @map_manager = new MapManager(@asset_manager, @ajax_state, @client_state)
    @mail_manager = new MailManager(@api, @ajax_state, @client_state)
    @overlay_manager = new OverlayManager(@api, @asset_manager, @ajax_state, @client_state)
    @plane_manager = new PlaneManager(@asset_manager, @ajax_state, @client_state)
    @planets_manager = new PlanetsManager(@api, @ajax_state, @client_state)
    @road_manager = new RoadManager(@api, @asset_manager, @ajax_state, @client_state)
    @sign_manager = new SignManager(@asset_manager, @ajax_state, @client_state)
    @tycoon_manager = new TycoonManager(@api, @ajax_state, @client_state)

    @utils = {
      tree_menu: new TreeMenuUtils(@planets_manager, @translation_manager, @ajax_state, @client_state)
    }

    @client_state.identity.subscribe_visa_type_listener =>
      return unless @client_state.identity.galaxy_tycoon?

      corporations = @client_state.identity.galaxy_tycoon?.corporations || []
      @client_state.core.corporation_cache.load_tycoon_corporations(@client_state.identity.galaxy_tycoon.id, corporations)
      @client_state.core.company_cache.load_companies_metadata(corporation.companies) for corporation in corporations

    @client_state.player.subscribe_planet_visa_type_listener =>
      return unless @client_state.player.planet_id? && @client_state.player.planet_visa_type?

      # FIXME: TODO: create/move to planet_manager
      @api.register_visa(@client_state.identity.galaxy_id, @client_state.player.planet_id, @client_state.player.planet_visa_type)
        .then (visa) =>
          @client_state.player.set_planet_visa_id(visa.visaId)
          @client_state.player.set_planet_corporation_id(visa.corporationId) if visa.corporationId?
        .catch (err) ->
          console.error err
          Logger.debug "failed to retrieve visa for planet" # FIXME: TODO: figure out error handling

    @client_state.player.subscribe_planet_visa_id_listener =>
      return unless @client_state.player.planet_id? && @client_state.player.planet_visa_id?

      @building_manager.queue_asset_load()
      @concrete_manager.queue_asset_load()
      @effect_manager.queue_asset_load()
      @event_manager.queue_asset_load()
      @land_manager.queue_asset_load()
      @map_manager.queue_asset_load()
      @overlay_manager.queue_asset_load()
      @plane_manager.queue_asset_load()
      @road_manager.queue_asset_load()
      @sign_manager.queue_asset_load()

      @asset_manager.load_queued()

      Promise.all([
        @planets_manager.load_metadata_building(@client_state.player.planet_id),
        @planets_manager.load_metadata_core(@client_state.player.planet_id),
        @planets_manager.load_metadata_invention(@client_state.player.planet_id),
        @planets_manager.load_events(@client_state.player.planet_id),
        @planets_manager.load_towns(@client_state.player.planet_id),
        @planets_manager.load_online_tycoons(@client_state.player.planet_id)
      ]).catch (err) ->
        console.error err
        throw err

    @client_state.player.subscribe_corporation_id_listener =>
      return unless @client_state.player.corporation_id? && @client_state.player.planet_visa_id?

      try
        corporation = await @corporation_manager.load_by_corporation(@client_state.player.corporation_id)
        return unless corporation?

        @client_state.core.company_cache.load_companies_metadata(corporation.companies)
        @client_state.corporation.set_company_ids(_.map(corporation.companies, (company) -> company.id))
        @client_state.player.set_company_id(_.first(_.sortBy(corporation.companies, (company) -> company.name))?.id)

        promises = []
        for company in (corporation.companies || [])
          promises.push @building_manager.load_by_company(company.id)
          promises.push @invention_manager.load_by_company(company.id)

        promises.push @corporation_manager.load_cashflow(@client_state.player.corporation_id)
        promises.push @bookmark_manager.load_by_corporation(@client_state.player.corporation_id)
        promises.push @mail_manager.load_by_corporation(@client_state.player.corporation_id)

        await Promise.all(promises)
        Logger.debug 'loaded corporation metadata'
      catch err
        console.error err
        Logger.info "failed to retrieve data for corporation" # FIXME: TODO: add error handling

    @client_state.interface.subscribe_selected_ranking_type_id_listener =>
      return unless @client_state.player.planet_id? && @client_state.interface.selected_ranking_type_id?
      return if @client_state.core.planet_cache.rankings(@client_state.interface.selected_ranking_type_id)?
      @planets_manager.load_rankings(@client_state.player.planet_id, @client_state.interface.selected_ranking_type_id)
        .then => Logger.debug 'loaded rankings'
        .catch (err) =>
          console.error err
          Logger.info "failed to retrieve data for rankings" # FIXME: TODO: add error handling

    @client_state.interface.subscribe_selected_ranking_corporation_id_listener =>
      return unless @client_state.player.planet_id? && @client_state.interface.selected_ranking_corporation_id?
      return if @client_state.core.corporation_cache.metadata_for_id(@client_state.interface.selected_ranking_corporation_id)?
      @corporation_manager.load_by_corporation(@client_state.interface.selected_ranking_corporation_id)
        .then => Logger.debug 'loaded corporation'
        .catch (err) =>
          console.error err
          Logger.info "failed to retrieve data for corporation" # FIXME: TODO: add error handling



  initialize: () ->
    planet_metadata = @client_state.current_planet_metadata()
    @client_state.planet.load_game_map(new GameMap(@building_manager, @road_manager, @overlay_manager,
        @client_state.core.land_library.metadata_for_planet_type(planet_metadata.planet_type),
        @client_state.core.map_library.texture_for_id(planet_metadata.map_id), @client_state.core.map_library.towns_texture_for_id(planet_metadata.map_id),
        @client_state, @options))

    @building_manager.initialize()
    @invention_manager.initialize()
    @bookmark_manager.initialize()
    @event_manager.initialize()
