import _ from 'lodash';
import { DateTime }  from 'luxon';

import CoreState from '~/plugins/starpeace-client/state/core/core-state.js';

import BookmarkState from '~/plugins/starpeace-client/state/player/bookmark-state.js';
import CorporationState from '~/plugins/starpeace-client/state/player/corporation-state.js';
import IdentityState from '~/plugins/starpeace-client/state/player/identity-state.js';
import PlanetState from '~/plugins/starpeace-client/state/player/planet-state.js';
import PlayerState from '~/plugins/starpeace-client/state/player/player-state.js';

import CameraState from '~/plugins/starpeace-client/state/ui/camera-state.coffee';
import InterfaceState from '~/plugins/starpeace-client/state/ui/interface-state.js';
import MenuState from '~/plugins/starpeace-client/state/ui/menu-state.js';
import MusicState from '~/plugins/starpeace-client/state/ui/music-state.js';

import Building from '~/plugins/starpeace-client/building/building.js';

import AjaxState from '~/plugins/starpeace-client/state/ajax-state.js';
import EventListener from '~/plugins/starpeace-client/state/event-listener.js';
import Options from '~/plugins/starpeace-client/state/options/options.js';

import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.js';
import Logger from '~/plugins/starpeace-client/logger.js';
import SpritePlane from '../renderer/sprite/sprite-plane';


const MAX_FAILED_AUTH_ERRORS = 3;
const MAX_FAILED_CONNECTION_ERRORS = 3;

export default class ClientState {
  event_listener: EventListener = new EventListener();
  options: Options;
  ajax_state: AjaxState;

  core = new CoreState();

  bookmarks: BookmarkState = new BookmarkState();
  corporation: CorporationState = new CorporationState();
  identity: IdentityState = new IdentityState();
  player: PlayerState = new PlayerState();
  planet: PlanetState = new PlanetState();

  camera: CameraState = new CameraState();
  interface: InterfaceState;
  menu: MenuState = new MenuState();
  music: MusicState = new MusicState();

  workflow_status: string | null = null;

  session_expired_warning: boolean = false;
  server_connection_warning: boolean = false;

  renderer_initializing: boolean = false;
  mini_map_renderer_initializing: boolean = false;
  construction_preview_renderer_initializing: boolean = false;
  inspect_preview_renderer_initializing: boolean = false;

  renderer_initialized: boolean = false;
  mini_map_renderer_initialized: boolean = false;
  construction_preview_renderer_initialized: boolean = false;
  inspect_preview_renderer_initialized: boolean = false;

  managers_initializing: boolean = false;
  managers_initialized: boolean = false;
  initialized: boolean = false;

  planet_event_client: any | null = null;

  has_dirty_metadata: boolean = false;

  recent_system_messages: Array<any> = [];
  older_system_messages: Array<any> = [];
  system_message_callback: any | null = null;

  plane_sprites: Array<SpritePlane> = [];


  constructor (options: Options, ajaxState: AjaxState) {
    this.options = options;
    this.ajax_state = ajaxState;

    this.interface = new InterfaceState(this.options);
  }

  configureListeners (): void {
    this.core.corporation_cache.subscribe_corporation_metadata_listener(() => this.update_state());
    this.core.tycoon_cache.subscribe_tycoon_metadata_listener(() => this.update_state());

    this.core.building_library.subscribe_listener(() => this.update_state());
    this.core.concrete_library.subscribe_listener(() => this.update_state());
    this.core.effect_library.subscribe_listener(() => this.update_state());
    this.core.invention_library.subscribe_listener(() => this.update_state());
    this.core.land_library.subscribe_listener(() => this.update_state());
    this.core.map_library.subscribe_listener(() => this.update_state());
    this.core.news_library.subscribe_listener(() => this.update_state());
    this.core.overlay_library.subscribe_listener(() => this.update_state());
    this.core.plane_library.subscribe_listener(() => this.update_state());
    this.core.road_library.subscribe_listener(() => this.update_state());
    this.core.sign_library.subscribe_listener(() => this.update_state());

    this.bookmarks.subscribeBookmarksMetadataListener(() => this.update_state());
    this.corporation.subscribe_company_ids_listener(() => this.update_state());
    this.corporation.subscribe_cashflow_listener(() => this.update_state());
    this.corporation.subscribe_company_buildings_listener(() => this.update_state());
    this.corporation.subscribe_company_inventions_listener(() => this.update_state());
    this.identity.subscribe_visa_type_listener(() => this.update_state());
    this.planet.subscribe_state_listener(() => this.update_state());
    this.planet.subscribe_towns_listener(() => this.update_state());
    this.planet.subscribe_tycoons_online_listener(() => this.update_state());
    this.player.subscribe_planet_visa_type_listener(() => this.update_state());
    this.player.subscribe_planet_visa_id_listener(() => this.update_state());
    this.player.subscribe_corporation_id_listener(() => this.update_state());
    this.player.subscribe_mail_listener(() => this.update_state());

    this.player.subscribeCompanyIdListener(() => {
      this.interface.construction_selected_category_id = null;
      this.interface.construction_building_id = null;
    });
  }

  subscribe_workflow_status_listener (callback: () => void): void {
    this.event_listener.subscribe('workflow_status', callback);
  }
  notify_workflow_status_listeners (): void {
    this.event_listener.notify_listeners('workflow_status');
  }

  reset_full_state (): void {
    this.session_expired_warning = false;
    this.server_connection_warning = false;

    this.workflow_status = 'initializing';

    this.renderer_initializing = false;
    this.mini_map_renderer_initializing = false;
    this.construction_preview_renderer_initializing = false;
    this.inspect_preview_renderer_initializing = false;

    this.renderer_initialized = false;
    this.mini_map_renderer_initialized = false;
    this.construction_preview_renderer_initialized = false;
    this.inspect_preview_renderer_initialized = false;

    this.ajax_state.reset_state();

    this.core.reset_multiverse();
    this.core.reset_planet();
    for (const galaxy of this.options.galaxy.getGalaxies()) {
      this.core.galaxy_cache.loadGalaxyConfiguration(galaxy.id, galaxy);
    }

    this.identity.reset_state();
    this.reset_planet_state();
  }

  reset_planet_state (): void {
    this.managers_initializing = false;
    this.managers_initialized = false;
    this.initialized = false;

    if (this.planet_event_client) {
      this.planet_event_client.disconnect();
    }
    this.planet_event_client = null;

    this.has_dirty_metadata = false;

    this.recent_system_messages = [];
    this.older_system_messages = [];
    this.system_message_callback = null;

    this.plane_sprites = [];

    this.core.reset_planet();

    this.bookmarks.reset();
    this.corporation.reset_state();
    this.player.reset_state();
    this.planet.reset_state();

    this.camera.reset_state();
    this.interface.reset_state();
    this.menu.reset_state();
    this.music.reset_state();

    this.update_state();
  }


  finish_initialization (): void {
    this.initialized = true;
    this.update_state();
  }

  update_state (): void {
    const new_state = this.determine_state();
    if (this.workflow_status !== new_state) {
      this.workflow_status = new_state;
      this.notify_workflow_status_listeners();
    }
  }

  determine_state (): string {
    if (!this.initialized || !this.managers_initialized || !this.renderer_initialized || !this.mini_map_renderer_initialized || !this.construction_preview_renderer_initialized || !this.inspect_preview_renderer_initialized) {
      if (!this.identity.galaxy_id && !this.identity.galaxy_visa_type) {
        return 'pending_universe';
      }

      const planet_metadata = this.current_planet_metadata();
      if (!planet_metadata) {
        return 'pending_planet';
      }
      if (!this.player.planet_visa_id) {
        return 'pending_visa';
      }
      if (!this.planet.has_data() || !this.core.has_metadata()) {
        return 'pending_planet_details';
      }
      if (this.state_needs_player_data()) {
        return 'pending_player_data';
      }
      if (!this.core.has_assets(this.options.language(), planet_metadata.map_id, planet_metadata.planet_type)) {
        return 'pending_assets';
      }
      return 'pending_initialization';
    }
    return 'ready';
  }

  state_needs_player_data (): boolean {
    return this.is_tycoon() && !!this.player.corporation_id && (!this.player.has_data() || !this.corporation.has_data() || !this.bookmarks.hasData);
  }


  has_session (): boolean {
    return !!this.player.planet_visa_id && this.ajax_state.invalidConnectionCounter < MAX_FAILED_CONNECTION_ERRORS && this.ajax_state.invalidSessionCounter < MAX_FAILED_AUTH_ERRORS;
  }
  handle_authorization_error (): void {
    if (!!this.ajax_state.invalidSessionAsOf && TimeUtils.within_minutes(this.ajax_state.invalidSessionAsOf, 5)) {
      this.ajax_state.invalidSessionCounter += 1;
    }
    else {
      this.ajax_state.invalidSessionCounter = 1;
    }
    this.ajax_state.invalidSessionAsOf = DateTime.now();

    if (this.ajax_state.invalidSessionCounter >= MAX_FAILED_AUTH_ERRORS && !this.session_expired_warning) {
      this.session_expired_warning = true;
      setTimeout(() => this.reset_full_state(), 5000);
    }
  }
  handle_connection_error () {
    if (!!this.ajax_state.invalidConnectionAsOf && TimeUtils.within_minutes(this.ajax_state.invalidConnectionAsOf, 5)) {
      this.ajax_state.invalidConnectionCounter += 1;
    }
    else {
      this.ajax_state.invalidConnectionCounter = 1;
    }
    this.ajax_state.invalidConnectionAsOf = DateTime.now();

    if (this.ajax_state.invalidConnectionCounter >= MAX_FAILED_CONNECTION_ERRORS && !this.server_connection_warning) {
      this.server_connection_warning = true
      setTimeout(() => this.reset_full_state(), 5000);
    }
  }
  handle_connection_disconnect (): void {
    if (!this.server_connection_warning) {
      this.server_connection_warning = true;
      setTimeout(() => this.reset_full_state(), 5000);
    }
  }

  reset_to_galaxy (): void {
    setTimeout(() => {
      this.reset_planet_state();
    }, 250);
  }

  change_planet_id (newPlanetVisaType: string, planetId: string) {
    setTimeout(() => {
      this.reset_planet_state();
      this.player.set_planet_visa_type(planetId, newPlanetVisaType);
    }, 250);
  }


  add_error_message (message: string, err: any | undefined | null): void {
    Logger.warn(message);
    if (err) {
      console.error(err);
    }
    this.add_system_message(message);
  }
  add_system_message (message: string): void {
    if (message.length) {
      this.recent_system_messages.unshift({ time: DateTime.now(), message });
      if (!this.system_message_callback) {
        this.system_message_callback = setTimeout(() => this.poll_system_messages(), 1000);
      }
    }
  }
  poll_system_messages (): void {
    const cutoff = DateTime.now().plus({ seconds: -5 });
    while (this.recent_system_messages.length > 0 && this.recent_system_messages[this.recent_system_messages.length - 1].time < cutoff) {
      this.older_system_messages.unshift(this.recent_system_messages.splice(this.recent_system_messages.length - 1, 1)[0]);
    }
    this.system_message_callback = this.recent_system_messages.length ? setTimeout(() => this.poll_system_messages(), 1000) : null
  }

  is_galaxy_tycoon (): boolean {
    return this.identity.galaxy_visa_type === 'tycoon';
  }
  is_tycoon (): boolean {
    return this.is_galaxy_tycoon() && this.player.planet_visa_type === 'tycoon' && !!this.identity.galaxy_tycoon_id;
  }


  current_planet_metadata (): any | undefined | null {
    return !!this.player.planet_id ? this.core.galaxy_cache.planet_metadata_for_id(this.player.planet_id) : null;
  }
  current_corporation_metadata (): any | undefined | null {
    return !!this.player.corporation_id ? this.core.corporation_cache.metadata_for_id(this.player.corporation_id) : null;
  }
  current_company_metadata (): any | undefined | null {
    return !!this.player.company_id ? this.core.company_cache.metadata_for_id(this.player.company_id) : null;
  }

  current_location (): any | null {
    if (!this.initialized || this.workflow_status !== 'ready') {
      return null;
    }
    const center = this.camera.center();
    return this.camera.map_to_iso(center.x, center.y);
  }

  name_for_planet_id (planetId: string): string | undefined {
    return this.core.galaxy_cache.planet_metadata_for_id(planetId)?.name;
  }
  name_for_tycoon_id (tycoonId: string): string | undefined {
    return this.core.tycoon_cache.metadata_for_id(tycoonId)?.name;
  }
  name_for_corporation_id (corporationId: string): string | undefined {
    return this.core.corporation_cache.metadata_for_id(corporationId)?.name;
  }

  seal_for_company_id (companyId: string): string {
    return this.core.company_cache.metadata_for_id(companyId)?.seal_id ?? 'NONE';
  }
  name_for_company_id (companyId: string): string {
    return this.core.company_cache.metadata_for_id(companyId)?.name ?? '';
  }

  town_for_location (): any | null {
    const location = this.current_location();
    if (!location) {
      return null;
    }
    return this.planet.town_for_color(this.planet.game_map.town_color_at(location.i, location.j));
  }

  selected_building (): any | undefined | null {
    return !!this.interface.selected_building_id ? this.core.building_cache.building_for_id(this.interface.selected_building_id) : null;
  }

  inventions_for_company (): Array<any> {
    if (this.is_tycoon()) {
      const company_metadata = this.current_company_metadata();
      return !!company_metadata ? this.core.invention_library.metadata_for_seal_id(company_metadata.seal_id) : [];
    }
    else {
      return this.core.invention_library.all_metadata();
    }
  }

  building_count_for_company (definitionId: string): number {
    if (this.is_tycoon() && this.player.company_id?.length) {
      return this.corporation.building_ids_for_company(this.player.company_id)
          .map((id: string) => this.core.building_cache.building_for_id(id))
          .filter((b: Building) => b?.definition_id === definitionId)
          .length;
    }
    return 0;
  }


  matches_jump_history (mapX: number, mapY: number): boolean {
    if (this.interface.location_index < 0 || this.interface.location_index >= this.interface.location_history.length) {
      return false;
    }
    return this.interface.location_history[this.interface.location_index].map_x == mapX && this.interface.location_history[this.interface.location_index].map_y == mapY;
  }

  add_jump_history (mapX: number, mapY: number, buildingId: string | undefined | null): void {
    this.interface.location_history.unshift({ map_x: mapX, map_y: mapY, building_id: buildingId });
    if (this.interface.location_history.length > 5) {
      this.interface.location_history.pop();
    }
  }

  jump_back (): void {
    const location = this.current_location();
    const matches_back = this.matches_jump_history(location.i, location.j);

    if (this.interface.location_index >= this.interface.location_history.length - 1 && matches_back) {
      return;
    }
    if (matches_back) {
      this.interface.location_index++;
    }
    const history = this.interface.location_history[this.interface.location_index];
    this.jump_to(history.map_x, history.map_y, history.building_id, false);
  }
  jump_next (): void {
    if (this.interface.location_index <= 0) {
      return;
    }
    this.interface.location_index--;
    const history = this.interface.location_history[this.interface.location_index];
    this.jump_to(history.map_x, history.map_y, history.building_id, false);
  }

  jump_to (mapX: number, mapY: number, buildingId: string | undefined | null, withHistory: boolean = true): void {
    if (withHistory) {
      const location = this.current_location();
      if (this.interface.location_index > 0) {
        this.interface.location_history.splice(0, this.interface.location_index);
        this.interface.location_index = 0;
      }

      if (!this.matches_jump_history(location.i, location.j)) {
        this.add_jump_history(location.i, location.j, this.interface.selected_building_id);
      }
      if (!this.matches_jump_history(mapX, mapY)) {
        this.add_jump_history(mapX, mapY, buildingId);
      }
    }

    this.menu.hide_menu('body')
    if (!!buildingId) {
      this.interface.select_building_id(buildingId);
    }
    if (mapX !== undefined && mapY !== undefined) {
      this.camera.recenterAt(mapX, mapY);
    }
  }


  has_construction_requirements (buildingId: string): boolean {
    if (!this.player.company_id || !buildingId) {
      return false;
    }

    const metadata = this.core.building_library.definition_for_id(buildingId);
    if (!metadata) {
      return false;
    }

    const completedIds = new Set(this.corporation.completed_invention_ids_for_company(this.player.company_id) ?? []);
    for (const id of (metadata.requiredInventionIds ?? [])) {
      if (!completedIds.has(id)) {
        return false;
      }
    }

    return (this.corporation.cash ?? 0) >= 0;
  }

  can_construct_building (): boolean {
    if (!this.interface.construction_building_id || !this.has_construction_requirements(this.interface.construction_building_id)) {
      return false;
    }
    return this.planet.can_place_building(this.interface.construction_building_map_x, this.interface.construction_building_map_y, this.interface.construction_building_city_zone_id, this.interface.construction_building_width, this.interface.construction_building_height);
  }

  initiate_building_construction (buildingId: string): void {
    const view_center = this.camera.center();
    const iso_start = this.camera.map_to_iso(view_center.x, view_center.y);

    const metadata = this.core.building_library.metadata_by_id[buildingId];
    const image_metadata = !!metadata ? this.core.building_library.images_by_id[metadata.imageId] : null;

    this.interface.construction_building_id = buildingId;
    this.interface.construction_building_map_x = iso_start.i;
    this.interface.construction_building_map_y = iso_start.j;
    this.interface.construction_building_city_zone_id = metadata?.zoneId;
    this.interface.construction_building_width = image_metadata?.w ?? 1;
    this.interface.construction_building_height = image_metadata?.h ?? 1;

    if (!this.interface.show_zones) {
      this.interface.toggle_zones();
    }
  }


  show_politics (townId: string): void {
    if (!this.menu.is_visible('politics')) {
      this.menu.toggle_menu('politics');
    }
    this.interface.select_politics_mayor(townId);
  }

  show_tycoon_profile (tycoonId: string): void {
    this.interface.selected_tycoon_id = tycoonId;
    if (!this.menu.is_visible('tycoon')) {
      this.menu.toggle_menu('tycoon');
    }
  }

  has_new_mail (): boolean {
    return !!this.player.corporation_id && !!this.corporation.last_mail_at && (!this.player.last_mail_at || this.corporation.last_mail_at > this.player.last_mail_at) && !this.ajax_state.is_locked('mail_metadata', this.player.corporation_id);
  }
  send_mail (tycoonName: string): void {
    if (!this.menu.is_visible('mail')) {
      this.menu.toggle_menu('mail');
    }
    this.player.mail_compose_mode = true;
    this.player.mail_compose_to = `${this.player.mail_compose_to}${(_.trim(this.player.mail_compose_to).length > 0 ? '; ' : '')}${tycoonName}`;
  }
}
