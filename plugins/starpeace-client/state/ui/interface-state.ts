import { markRaw } from 'vue';

import BuildingEvent, { BuildingNewsEvent } from '~/plugins/starpeace-client/event/building-event';

import Overlay from '~/plugins/starpeace-client/overlay/overlay.coffee'
import EventListener from '~/plugins/starpeace-client/state/event-listener'
import Options from '~/plugins/starpeace-client/state/options/options';
import { VisaNewsEvent } from '../../event/visa-event';

const MINI_MAP_ZOOM_MAX = 2;
const MINI_MAP_ZOOM_MIN = .25;
const MINI_MAP_ZOOM_STEP = .25;

export class EventTickerTarget {
  buildingId: string | undefined;
  mapX: number;
  mapY: number;

  constructor (buildingId: string | undefined, mapX: number, mapY: number) {
    this.buildingId = buildingId;
    this.mapX = mapX;
    this.mapY = mapY;
  }
}

/**
 * State of client user interface (renderer or DOM)
 */
export default class InterfaceState {
  options: Options;
  event_listener: EventListener;

  static_news_index: number = -1;
  eventTickerMessage: string = '';
  eventTickerTarget: EventTickerTarget | undefined = undefined;
  tickerVisaEvents: Array<VisaNewsEvent> = [];
  tickerBuildingEvents: Array<BuildingNewsEvent> = [];

  remove_galaxy_visible: boolean = false;
  add_galaxy_visible: boolean = false;

  show_create_tycoon: boolean = false;
  create_tycoon_galaxy_id: string | null = null;

  show_overlay: boolean = false;
  current_overlay: string = Overlay.TYPES.TOWNS;
  show_losing_facilities: boolean = false;

  show_zones: boolean = false;

  is_moving: boolean = false;
  is_mouse_primary_down: boolean = false;
  start_mouse_x: number = -1;
  start_mouse_y: number = -1;
  last_mouse_x: number = -1;
  last_mouse_y: number = -1;

  location_history: Array<any> = [];
  location_index: number = 0;

  show_inspect: boolean = false;
  selectedInspectTabId: string | undefined = undefined;

  selected_building_id: string | null = null;

  inventions_selected_category_id: string | null = 'SERVICE';
  inventions_selected_industry_type_id: string | null = 'GENERAL';
  inventions_selected_invention_id: string | null = null;

  construction_selected_category_id: string | null = null;
  construction_selected_building_id: string | null = null;

  construction_building_id: string | null = null;
  construction_building_map_x: number = 0;
  construction_building_map_y: number = 0;
  construction_building_city_zone_id: string | null = null;
  construction_building_width: number = 0;
  construction_building_height: number = 0;

  selected_tycoon_id: string | null = null;

  selected_politics_type: string | null = null;
  selected_politics_id: string | null = null;

  selected_ranking_type_id: string | null = null;
  selected_ranking_corporation_id: string | null = null;

  constructor (options: Options) {
    this.options = options;
    this.event_listener = markRaw(new EventListener());
  }

  reset_state (): void {
    this.static_news_index = -1;
    this.eventTickerMessage = '';
    this.eventTickerTarget = undefined;
    this.tickerVisaEvents = [];
    this.tickerBuildingEvents = [];

    this.remove_galaxy_visible = false;
    this.add_galaxy_visible = false;

    this.show_create_tycoon = false;
    this.create_tycoon_galaxy_id = null;

    this.show_overlay = false;
    this.current_overlay = Overlay.TYPES.TOWNS;
    this.show_losing_facilities = false;

    this.show_zones = false;

    this.is_mouse_primary_down = false;
    this.start_mouse_x = -1;
    this.start_mouse_y = -1;
    this.last_mouse_x = -1;
    this.last_mouse_y = -1;

    this.location_history = [];
    this.location_index = 0;

    this.show_inspect = false;
    this.selectedInspectTabId = undefined;

    this.selected_building_id = null;

    this.inventions_selected_category_id = 'SERVICE';
    this.inventions_selected_industry_type_id = 'GENERAL';
    this.inventions_selected_invention_id = null;

    this.construction_selected_category_id = null;
    this.construction_selected_building_id = null;

    this.construction_building_id = null;
    this.construction_building_map_x = 0;
    this.construction_building_map_y = 0;
    this.construction_building_city_zone_id = null;
    this.construction_building_width = 0;
    this.construction_building_height = 0;

    this.selected_tycoon_id = null;

    this.selected_politics_type = null;
    this.selected_politics_id = null;

    this.selected_ranking_type_id = null;
    this.selected_ranking_corporation_id = null;
  }

  subscribe_mini_map_zoom_listener (callback: () => void): void {
    this.event_listener.subscribe('interface.mini_map_zoom', callback);
  }
  notify_mini_map_zoom_listeners (): void {
    this.event_listener.notify_listeners('interface.mini_map_zoom');
  }
  subscribe_mini_map_size_listener (callback: () => void): void {
    this.event_listener.subscribe('interface.mini_map_size', callback);
  }
  notify_mini_map_size_listeners (): void {
    this.event_listener.notify_listeners('interface.mini_map_size');
  }

  subscribe_selected_ranking_type_id_listener (callback: () => void): void {
    this.event_listener.subscribe('interface.selected_ranking_type_id', callback);
  }
  notify_selected_ranking_type_id_listeners (): void {
    this.event_listener.notify_listeners('interface.selected_ranking_type_id');
  }
  subscribe_selected_ranking_corporation_id_listener (callback: () => void): void {
    this.event_listener.subscribe('interface.selected_ranking_corporation_id', callback);
  }
  notify_selected_ranking_corporation_id_listeners (): void {
    this.event_listener.notify_listeners('interface.selected_ranking_corporation_id');
  }

  subscribeSelectedBuildingListener (callback: () => void): void {
    this.event_listener.subscribe('interface.selected_building_id', callback);
  }
  notifySelectedBuildingListeners (): void {
    this.event_listener.notify_listeners('interface.selected_building_id');
  }


  updateEventTicker (message: string) {
    this.eventTickerMessage = message;
    this.eventTickerTarget = undefined;
  }
  updateEventTickerWithTarget (message: string, buildingId: string | undefined, mapX: number, mapY: number) {
    this.eventTickerMessage = message;
    this.eventTickerTarget = new EventTickerTarget(buildingId, mapX, mapY);
  }

  queueVisaEvent (event: VisaNewsEvent): void {
    this.tickerVisaEvents.push(event);
  }
  queueBuildingEvent (event: BuildingEvent): void {
    this.tickerBuildingEvents.push(BuildingNewsEvent.from(event));
  }
  mergeEvents (event: BuildingNewsEvent): number {
    const removableIndices: Array<number> = [];
    for (let index = 0; index < this.tickerBuildingEvents.length; index++) {
      if (event.canMerge(this.tickerBuildingEvents[index])) {
        removableIndices.push(index);
      }
    }

    const count = removableIndices.length;
    for (let index = removableIndices.length - 1; index >= 0; index--) {
      this.tickerBuildingEvents.splice(index, 1);
    }
    return count;
  }

  show_add_galaxy (): void {
    this.add_galaxy_visible = true;
  }
  hide_add_galaxy (): void {
    this.add_galaxy_visible = false;
  }

  show_remove_galaxy (): void {
    this.remove_galaxy_visible = true;
  }
  hide_remove_galaxy (): void {
    this.remove_galaxy_visible = false;
  }

  toggle_overlay (): void {
    if (this.show_overlay) {
      this.show_overlay = false;
    }
    else {
      this.show_zones = false;
      this.show_overlay = true;
    }
  }

  toggle_zones (): void {
    if (this.show_zones) {
      this.show_zones = false;
    }
    else {
      this.show_overlay = false;
      this.show_zones = true;
    }
  }

  hide_inspect (): void {
    this.show_inspect = false;
    this.selectedInspectTabId = undefined;
  }
  toggle_inspect (): void {
    this.show_inspect = !this.show_inspect;
    if (!this.show_inspect) {
      this.selectedInspectTabId = undefined;
    }
  }

  mini_map_adjust_zoom (zoomDelta: number): boolean {
    const before = this.options.option('mini_map.zoom');
    const zoom = Math.min(MINI_MAP_ZOOM_MAX, Math.max(MINI_MAP_ZOOM_MIN, before + zoomDelta));
    if (zoom != before) {
      this.options.setAndSaveOption('mini_map.zoom', zoom);
      this.notify_mini_map_zoom_listeners();
      return true;
    }
    return false;
  }
  mini_map_zoom_in (): void {
    this.mini_map_adjust_zoom(MINI_MAP_ZOOM_STEP);
  }
  mini_map_zoom_out (): void {
    this.mini_map_adjust_zoom(-MINI_MAP_ZOOM_STEP);
  }

  update_mini_map (width: number, height: number): void {
    this.options.setAndSaveOption('mini_map.width', width)
    this.options.setAndSaveOption('mini_map.height', height)
    this.notify_mini_map_size_listeners()
  }

  toggle_building (buildingId: string): void {
    if (buildingId == this.selected_building_id) {
      this.unselect_building();
    }
    else {
      this.select_building_id(buildingId);
    }
  }
  unselect_building (): void {
    this.show_inspect = false;
    this.selectedInspectTabId = undefined;
    this.selected_building_id = null;
    this.notifySelectedBuildingListeners();
  }
  select_and_inspect_building (buildingId: string): void {
    this.selected_building_id = buildingId;
    this.show_inspect = true;
    this.notifySelectedBuildingListeners();
  }
  select_building_id (buildingId: string): void {
    this.selected_building_id = buildingId;
    this.notifySelectedBuildingListeners();
  }

  selectConstructionCategoryId (categoryId: string | null): void {
    this.construction_selected_category_id = categoryId;
  }
  selectConstructionDefinitionId (definitionId: string | null): void {
    this.construction_selected_building_id = definitionId;
  }

  selectConstructionBuildingId (definitionId: string | null): void {
    this.construction_building_id = definitionId;
  }

  select_ranking_type_id (rankingTypeId: string | null): void {
    this.selected_ranking_type_id = rankingTypeId;
    this.notify_selected_ranking_type_id_listeners();
  }
  select_ranking_corporation_id (corporationId: string | null): void {
    this.selected_ranking_corporation_id = corporationId;
    this.notify_selected_ranking_corporation_id_listeners();
  }
  toggle_ranking_corporation_id (corporationId: string): void {
    this.select_ranking_corporation_id(this.selected_ranking_corporation_id == corporationId ? null : corporationId);
  }

  select_politics_president (planetId: string): void {
    this.select_politics('PRESIDENT', planetId);
  }
  select_politics_mayor (townId: string): void {
    this.select_politics('MAYOR', townId);
  }
  select_politics (type: string, id: string): void {
    this.selected_politics_type = type;
    this.selected_politics_id = id;
  }
  unselect_politics (): void {
    this.selected_politics_type = null
    this.selected_politics_id = null
  }

  primary_mouse_down (mouseX: number, mouseY: number): void {
    this.is_moving = true;
    this.start_mouse_x = this.last_mouse_x = mouseX;
    this.start_mouse_y = this.last_mouse_y = mouseY;
  }
}
