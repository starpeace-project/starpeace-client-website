
import moment from 'moment'
import Vue from 'vue'

import EventListener from '~/plugins/starpeace-client/state/event-listener.coffee'

export default class PlanetState
  constructor: () ->
    @event_listener = new EventListener()
    @reset_state()

  reset_state: () ->
    @game_map = null
    @events_as_of = null

    @current_time = null
    @current_season = null

    @towns = null
    @towns_by_id = {}
    @towns_by_color = {}
    @tycoons_online = null

  subscribe_map_data_listener: (listener_callback) -> @event_listener.subscribe('planet.map_data', listener_callback)
  notify_map_data_listeners: (chunk_event) -> @event_listener.notify_listeners('planet.map_data', chunk_event)

  subscribe_state_listener: (listener_callback) -> @event_listener.subscribe('planet.state', listener_callback)
  notify_state_listeners: () -> @event_listener.notify_listeners('planet.state')
  subscribe_towns_listener: (listener_callback) -> @event_listener.subscribe('player.towns', listener_callback)
  notify_towns_listeners: () -> @event_listener.notify_listeners('player.towns')
  subscribe_tycoons_online_listener: (listener_callback) -> @event_listener.subscribe('player.tycoons_online', listener_callback)
  notify_tycoons_online_listeners: () -> @event_listener.notify_listeners('player.tycoons_online')

  has_data: () -> @current_time? && @current_season? && @towns? && @tycoons_online?

  load_game_map: (game_map) ->
    @game_map = game_map
    # FIXME: TODO: may want to notify


  load_state: (time, season) ->
    @current_time = time
    @current_season = season
    @notify_state_listeners()

  town_for_color: (color) -> @towns_by_color[color]
  town_for_id: (id) -> @towns_by_id[id]
  load_towns: (towns) ->
    @towns = towns || []
    for town in @towns
      @towns_by_id[town.id] = town
      @towns_by_color[town.color] = town
    @notify_towns_listeners()

  load_tycoons_online: (tycoons) ->
    @tycoons_online = tycoons || []
    @notify_tycoons_online_listeners()

  can_place_building: (map_x, map_y, building_city_zone_id, width, height) ->
    has_all_data = true
    can_place = true
    for j in [0...height]
      for i in [0...width]
        tile_i = map_x - i
        tile_j = map_y - j

        building_chunk_info = @game_map.building_map.chunk_building_info_at(tile_i, tile_j)
        unless building_chunk_info?.is_current()
          has_all_data = false
          @game_map.building_map.chunk_building_update_at(tile_i, tile_j)
        else if @game_map.building_map.building_info_at(tile_i, tile_j)?
          can_place = false

        road_chunk_info = @game_map.building_map.chunk_road_info_at(tile_i, tile_j)
        unless road_chunk_info?.is_current()
          has_all_data = false
          @game_map.building_map.chunk_road_update_at(tile_i, tile_j)
        else if @game_map.road_map.road_info_at(tile_i, tile_j)?
          can_place = false

        zone_chunk_info = @game_map.overlay_map.chunk_info_at('ZONES', tile_i, tile_j)
        unless zone_chunk_info?.is_current()
          has_all_data = false
          @game_map.overlay_map.chunk_update_at('ZONES', tile_i, tile_j)
        else
          zone_info = @game_map.overlay_map.overlay_at('ZONES', tile_i, tile_j)
          can_place = false if building_city_zone_id? && zone_info? && !zone_info.matches(building_city_zone_id)

        can_place = false if @game_map.ground_map?.is_coast_at(tile_i, tile_j) || @game_map?.ground_map?.is_water_at(tile_i, tile_j) && @game_map?.ground_map?.is_coast_around(tile_i, tile_j)

    has_all_data && can_place
