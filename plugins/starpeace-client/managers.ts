import _ from 'lodash';

import GameMap from '~/plugins/starpeace-client/map/game-map.coffee';

import AssetManager from '~/plugins/starpeace-client/asset/asset-manager.coffee';
import BookmarkManager from '~/plugins/starpeace-client/bookmark/bookmark-manager.js';
import Building from '~/plugins/starpeace-client/building/building.js';
import BuildingManager from '~/plugins/starpeace-client/building/building-manager.js';
import ConcreteManager from '~/plugins/starpeace-client/building/concrete-manager.coffee';
import CompanyManager from '~/plugins/starpeace-client/company/company-manager.js';
import CorporationManager from '~/plugins/starpeace-client/corporation/corporation-manager.js';
import EffectManager from '~/plugins/starpeace-client/asset/effect-manager.coffee';
import EventManager from '~/plugins/starpeace-client/event/event-manager';
import GalaxyManager from '~/plugins/starpeace-client/galaxy/galaxy-manager.js';
import InventionManager from '~/plugins/starpeace-client/invention/invention-manager.js';
import LandManager from '~/plugins/starpeace-client/land/land-manager.coffee';
import MapManager from '~/plugins/starpeace-client/land/map-manager.coffee';
import MailManager from '~/plugins/starpeace-client/mail/mail-manager';
import OverlayManager from '~/plugins/starpeace-client/overlay/overlay-manager.coffee';
import PlaneManager from '~/plugins/starpeace-client/plane/plane-manager.coffee';
import PlanetsManager from '~/plugins/starpeace-client/planet/planets-manager';
import RoadManager from '~/plugins/starpeace-client/road/road-manager.coffee';
import SignManager from '~/plugins/starpeace-client/asset/sign-manager.coffee';
import TranslationManager from '~/plugins/starpeace-client/language/translation-manager';
import TycoonManager from '~/plugins/starpeace-client/tycoon/tycoon-manager';

import PlanetEventClient from '~/plugins/starpeace-client/api/planet-event-client';

import type ApiClient from '~/plugins/starpeace-client/api/api-client.js';
import TreeMenuUtils from '~/plugins/starpeace-client/utils/tree-menu-utils.coffee';
import Logger from '~/plugins/starpeace-client/logger';

import Options from '~/plugins/starpeace-client/state/options/options';
import AjaxState from '~/plugins/starpeace-client/state/ajax-state';
import type ClientState from '~/plugins/starpeace-client/state/client-state.js';


interface Utilities {
  tree_menu: TreeMenuUtils;
}

export default class Managers {
  api: ApiClient;
  options: Options;
  ajaxState: AjaxState;
  clientState: ClientState;

  asset_manager: AssetManager;
  translation_manager: TranslationManager;

  bookmark_manager: BookmarkManager;
  building_manager: BuildingManager;
  concrete_manager: ConcreteManager;
  company_manager: CompanyManager;
  corporation_manager: CorporationManager;
  effect_manager: EffectManager;
  event_manager: EventManager;
  galaxy_manager: GalaxyManager;
  invention_manager: InventionManager;
  land_manager: LandManager;
  map_manager: MapManager;
  mail_manager: MailManager;
  overlay_manager: OverlayManager;
  plane_manager: PlaneManager;
  planets_manager: PlanetsManager;
  road_manager: RoadManager;
  sign_manager: SignManager;
  tycoon_manager: TycoonManager;

  utils: Utilities;

  refreshInterval: any | undefined;

  constructor (api: ApiClient, options: Options, ajaxState: AjaxState, clientState: ClientState) {
    this.api = api;
    this.options = options;
    this.ajaxState = ajaxState;
    this.clientState = clientState;

    this.asset_manager = new AssetManager(this.ajaxState);

    this.translation_manager = new TranslationManager(this.asset_manager, this.ajaxState, this.options, this.clientState);

    this.bookmark_manager = new BookmarkManager(this.api, this.translation_manager, this.ajaxState, this.clientState);
    this.building_manager = new BuildingManager(this.api, this.asset_manager, this.bookmark_manager, this.translation_manager, this.ajaxState, this.clientState);
    this.concrete_manager = new ConcreteManager(this.asset_manager, this.ajaxState, this.clientState);
    this.company_manager = new CompanyManager(this.api, this.ajaxState, this.clientState);
    this.corporation_manager = new CorporationManager(this.api, this.ajaxState, this.clientState);
    this.effect_manager = new EffectManager(this.asset_manager, this.ajaxState, this.clientState);
    this.event_manager = new EventManager(this.asset_manager, this.translation_manager, this.options, this.ajaxState, this.clientState);
    this.galaxy_manager = new GalaxyManager(this.api, this.ajaxState, this.clientState);
    this.invention_manager = new InventionManager(this.api, this.asset_manager, this.ajaxState, this.clientState);
    this.land_manager = new LandManager(this.asset_manager, this.ajaxState, this.clientState);
    this.map_manager = new MapManager(this.asset_manager, this.ajaxState, this.clientState);
    this.mail_manager = new MailManager(this.api, this.ajaxState, this.clientState);
    this.overlay_manager = new OverlayManager(this.api, this.asset_manager, this.ajaxState, this.clientState);
    this.plane_manager = new PlaneManager(this.asset_manager, this.ajaxState, this.clientState);
    this.planets_manager = new PlanetsManager(this.api, this.ajaxState, this.clientState);
    this.road_manager = new RoadManager(this.api, this.asset_manager, this.ajaxState, this.clientState);
    this.sign_manager = new SignManager(this.asset_manager, this.ajaxState, this.clientState);
    this.tycoon_manager = new TycoonManager(this.api, this.ajaxState, this.clientState);

    this.utils = {
      tree_menu: new TreeMenuUtils(this.planets_manager, this.translation_manager, this.ajaxState, this.clientState)
    };

    this.refreshInterval = undefined;

    this.configureListeners();
  }

  configureListeners (): void {
    this.clientState.identity.subscribe_visa_type_listener(() => {
      if (!this.clientState.identity.galaxy_tycoon_id) {
        return;
      }

      this.corporation_manager.load_identifiers_by_tycoon(this.clientState.identity.galaxy_tycoon_id);
    });

    this.clientState.player.subscribe_planet_visa_type_listener(async () => {
      if (!this.clientState.player.planet_id || !this.clientState.player.planet_visa_type) {
        return;
      }

      try {
        // FIXME: TODO: create/move to planet_manager
        const visa = await this.api.register_visa(this.clientState.identity.galaxy_id, this.clientState.player.planet_visa_type);
        this.clientState.player.set_planet_visa_id(visa.id);
        if (visa.corporationId) {
          this.clientState.player.set_planet_corporation_id(visa.corporationId);
        }
      }
      catch (err) {
        console.error(err);
        Logger.debug("failed to retrieve visa for planet"); // FIXME: TODO: figure out error handling
      }
    });

    this.clientState.player.subscribe_planet_visa_id_listener(async () => {
      if (!this.clientState.player.planet_id || !this.clientState.player.planet_visa_id) {
        return;
      }

      this.clientState.planet_event_client = new PlanetEventClient(this.api, this.clientState);

      this.building_manager.queue_asset_load();
      this.concrete_manager.queue_asset_load();
      this.effect_manager.queue_asset_load();
      this.event_manager.queue_asset_load();
      this.land_manager.queue_asset_load();
      this.map_manager.queue_asset_load();
      this.overlay_manager.queue_asset_load();
      this.plane_manager.queue_asset_load();
      this.road_manager.queue_asset_load();
      this.sign_manager.queue_asset_load();

      this.asset_manager.load_queued();

      try {
        await Promise.all([
          this.planets_manager.load_metadata_building(),
          this.planets_manager.load_metadata_core(),
          this.planets_manager.load_metadata_invention(),
          this.planets_manager.load_towns(),
          this.planets_manager.load_online_tycoons()
        ]);
      }
      catch (err) {
        console.error(err);
        throw err;
      }
    });

    this.clientState.player.subscribe_corporation_id_listener(async () => {
      if (!this.clientState.player.corporation_id || !this.clientState.player.planet_visa_id) {
        return;
      }

      try {
        const corporation = await this.corporation_manager.load_by_corporation(this.clientState.player.corporation_id);
        if (!corporation) {
          return;
        }

        this.clientState.core.company_cache.load_companies_metadata(corporation.companies);
        this.clientState.corporation.set_company_ids((corporation.companies ?? []).map((company) => company.id));
        this.clientState.player.set_company_id(_.first(_.orderBy(corporation.companies, ['name'], ['asc']))?.id);

        const promises: Array<Promise<any>> = [];
        for (const company of (corporation.companies ?? [])) {
          promises.push(this.building_manager.load_by_company(company.id, true));
          promises.push(this.invention_manager.loadByCompany(company.id, true));
        }

        promises.push(this.bookmark_manager.loadByCorporation(this.clientState.player.corporation_id));
        promises.push(this.mail_manager.load_by_corporation(this.clientState.player.corporation_id));

        await Promise.all(promises);
        Logger.debug('loaded corporation metadata');
      }
      catch (err) {
        console.error(err);
        Logger.info("failed to retrieve data for corporation"); // FIXME: TODO: add error handling
      }
    });

    this.clientState.interface.subscribe_selected_ranking_type_id_listener(async () => {
      if (!this.clientState.player.planet_id || !this.clientState.interface.selected_ranking_type_id) {
        return;
      }
      try {
        await this.planets_manager.load_rankings(this.clientState.interface.selected_ranking_type_id);
        Logger.debug('loaded rankings');
      }
      catch (err) {
        console.error(err);
        Logger.info("failed to retrieve data for rankings"); // FIXME: TODO: add error handling
      }
    });

    this.clientState.interface.subscribe_selected_ranking_corporation_id_listener(async () => {
      if (!this.clientState.player.planet_id || !this.clientState.interface.selected_ranking_corporation_id) {
        return
      }
      try {
        await this.corporation_manager.load_by_corporation(this.clientState.interface.selected_ranking_corporation_id);
        Logger.debug('loaded corporation');
      }
      catch (err) {
        console.error(err);
        Logger.info("failed to retrieve data for corporation"); // FIXME: TODO: add error handling
      }
    });

    this.clientState.interface.subscribeSelectedBuildingListener(async () => {
      try {
        await Promise.all(this.refreshSelection());
      }
      catch (err) {
        console.error(err);
        Logger.info('failed to retrieve selected building information'); // FIXME: TODO: add error handling
      }
    });
  }

  initialize (extract: any): void {
    const planet_metadata = this.clientState.current_planet_metadata();
    this.clientState.planet.load_game_map(new GameMap(this.building_manager, this.road_manager, this.overlay_manager,
        this.clientState.core.land_library.metadata_for_planet_type(planet_metadata.planet_type),
        this.clientState.core.map_library.texture_for_id(planet_metadata.map_id), this.clientState.core.map_library.towns_texture_for_id(planet_metadata.map_id),
        extract, this.clientState, this.options));

    this.clientState.music.initialize();

    this.building_manager.initialize();
    this.invention_manager.initialize();
    this.bookmark_manager.initialize();
    this.event_manager.initialize();

    this.clientState.managers_initialized = true;
  }

  startRefresh (): void {
    if (this.refreshInterval) {
      clearTimeout(this.refreshInterval);
    }
    this.refreshInterval = setInterval(async () => {
      if (this.clientState.workflow_status === 'ready') {
        await this.refreshMainLoop();
      }
      else {
        clearTimeout(this.refreshInterval);
        this.refreshInterval = undefined;
      }
    }, 2500);
  }

  async refreshMainLoop (): Promise<void> {
    const promises: Array<Promise<any>> = this.refreshSelection();
    if (this.clientState.has_new_mail()) {
      promises.push(this.mail_manager.load_by_corporation(this.clientState.player.corporation_id));
    }
    for (const companyId of this.clientState.corporation.company_ids_with_pending_inventions()) {
      promises.push(this.invention_manager.loadByCompany(companyId, true));
    }

    if (promises.length) {
      try {
        await Promise.all(promises);
        Logger.debug('refreshed recent events');
        this.clientState.has_dirty_metadata = true;
      }
      catch (err) {
        this.clientState.add_error_message('Failure refreshing recent events from server', err);
      }
    }
  }

  async refreshSelectedBuilding (): Promise<void> {
    if (this.clientState.interface.selected_building_id?.length) {
      try {
        await this.building_manager.load_building_metadata(this.clientState.interface.selected_building_id);
      }
      catch (err: any) {
        if (err?.response?.status === 404) {
          this.clientState.interface.unselect_building();
        }
        else {
          throw err;
        }
      }
    }
  }

  refreshSelection (): Array<Promise<any>> {
    const promises: Array<Promise<any>> = [];
    if (this.clientState.interface.selected_building_id?.length) {
      promises.push(this.refreshSelectedBuilding());
    }

    const building: Building | undefined | null = this.clientState.interface.selected_building_id?.length ? this.clientState.core.building_cache.building_for_id(this.clientState.interface.selected_building_id) : undefined;
    if (building) {
      if (this.clientState.interface.show_inspect) {
        promises.push(this.building_manager.load_building_details(building.id, true));
      }

      if (!building.isIfel) {
        const company = this.clientState.core.company_cache.metadata_for_id(building.companyId);
        if (!company) {
          promises.push(this.company_manager.load_by_company(building.companyId));
        }
      }
    }
    return promises;
  }
}
