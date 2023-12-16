import { DateTime } from 'luxon';
import { markRaw } from 'vue';

import type BuildingEvent from '~/plugins/starpeace-client/event/building-event';

import EventListener from '~/plugins/starpeace-client/state/event-listener';
import type GameMap from '~/plugins/starpeace-client/map/game-map.coffee';

export default class PlanetState {
  event_listener: EventListener;

  game_map: GameMap | undefined = undefined;

  connecting: boolean = false;
  connected: boolean = false;
  current_time: DateTime | undefined = undefined;
  current_season: string | undefined = undefined;

  towns: Array<any> | undefined = undefined;
  towns_by_id: Record<string, any> = {};
  towns_by_color: Record<any, any> = {};
  tycoons_online: any | undefined = undefined;

  constructor () {
    this.event_listener = new EventListener();
  }

  reset_state () {
    if (this.game_map) {
      this.game_map.stop();
    }
    this.game_map = undefined;

    this.connecting = false;
    this.connected = false;
    this.current_time = undefined;
    this.current_season = undefined;

    this.towns = undefined;
    this.towns_by_id = {};
    this.towns_by_color = {};
    this.tycoons_online = undefined;
  }

  subscribeIssuedVisaListener (callback: (event: any) => void) {
    this.event_listener.subscribe('planet.issued_visa', callback);
  }
  notifyIssuedVisaListener (event: any) {
    this.event_listener.notify_listeners('planet.issued_visa', event);
  }

  subscribeBuildingListener (callback: (event: BuildingEvent) => void) {
    this.event_listener.subscribe('planet.map_building', callback);
  }
  notifyBuildingListeners (event: BuildingEvent) {
    this.event_listener.notify_listeners('planet.map_building', event);
  }
  subscribe_map_data_listener (callback: (event: any) => void) {
    this.event_listener.subscribe('planet.map_data', callback);
  }
  notify_map_data_listeners (event: any) {
    this.event_listener.notify_listeners('planet.map_data', event);
  }

  subscribe_state_listener (callback: () => void) {
    this.event_listener.subscribe('planet.state', callback);
  }
  notify_state_listeners () {
    this.event_listener.notify_listeners('planet.state')
  }
  subscribe_towns_listener (callback: () => void) {
    this.event_listener.subscribe('player.towns', callback);
  }
  notify_towns_listeners () {
    this.event_listener.notify_listeners('player.towns');
  }
  subscribe_tycoons_online_listener (callback: () => void) {
    this.event_listener.subscribe('player.tycoons_online', callback);
  }
  notify_tycoons_online_listeners () {
    this.event_listener.notify_listeners('player.tycoons_online');
  }

  has_data (): boolean {
    return !!this.current_time && !!this.current_season && (this.towns?.length ?? 0) > 0 && !!this.tycoons_online;
  }

  load_game_map (map: GameMap) {
    this.game_map = markRaw(map);
    // FIXME: TODO: may want to notify
  }

  load_state (time: DateTime, planetEvent: any) {
    this.current_time = time;
    this.current_season = planetEvent.season;
    this.notify_state_listeners()
  }

  town_for_color (color: any) {
    return this.towns_by_color[color];
  }
  town_for_id (id: string) {
    return this.towns_by_id[id];
  }
  load_towns (towns: Array<any>) {
    this.towns = towns ?? [];
    for (const town of this.towns) {
      this.towns_by_id[town.id] = town;
      this.towns_by_color[town.color] = town;
    }
    this.notify_towns_listeners();
  }

  load_tycoons_online (tycoons: Array<any>) {
    this.tycoons_online = tycoons ?? [];
    this.notify_tycoons_online_listeners();
  }

  can_place_building (mapX: number, mapY: number, cityZoneId: string | undefined | null, width: number, height: number): boolean {
    let has_all_data = true;
    let can_place = true;

    // no short-circuiting, so that all map positions can be loaded
    for (let j = 0; j < height; j++) {
      for (let i = 0; i < width; i++) {
        const tile_i = mapX - i;
        const tile_j = mapY - j;

        const building_chunk_info = this.game_map.building_map.chunk_building_info_at(tile_i, tile_j);
        if (!building_chunk_info?.has_data()) {
          has_all_data = false;
          this.game_map.building_map.chunk_building_update_at(tile_i, tile_j);
        }
        else if (!!this.game_map.building_map.building_id_at(tile_i, tile_j)) {
          can_place = false;
        }

        const road_chunk_info = this.game_map.building_map.chunk_road_info_at(tile_i, tile_j);
        if (!road_chunk_info?.has_data()) {
          has_all_data = false;
          this.game_map.building_map.chunk_road_update_at(tile_i, tile_j);
        }
        else if (!!this.game_map.road_map.road_info_at(tile_i, tile_j)) {
          can_place = false;
        }

        const zone_chunk_info = this.game_map.overlay_map.chunk_info_at('ZONES', tile_i, tile_j);
        if (!zone_chunk_info?.has_data()) {
          has_all_data = false
          this.game_map.overlay_map.chunk_update_at('ZONES', tile_i, tile_j)
        }
        else {
          const zoneInfo = this.game_map.overlay_map.overlay_at('ZONES', tile_i, tile_j)
          if ((!!cityZoneId && !!zoneInfo && !zoneInfo.matches(cityZoneId)) || (!cityZoneId && !!zoneInfo)) {
            can_place = false;
          }
        }

        if (this.game_map.ground_map?.is_coast_at(tile_i, tile_j) || this.game_map?.ground_map?.is_water_at(tile_i, tile_j) && this.game_map?.ground_map?.is_coast_around(tile_i, tile_j)) {
          can_place = false
        }
      }
    }

    return has_all_data && can_place;
  }
}
