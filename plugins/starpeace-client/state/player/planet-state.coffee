
import moment from 'moment'
import Vue from 'vue'

import BuildingZone from '~/plugins/starpeace-client/overlay/building-zone.coffee'

import EventListener from '~/plugins/starpeace-client/state/event-listener.coffee'

export default class PlanetState
  constructor: () ->
    @event_listener = new EventListener()
    @reset_state()

  reset_state: () ->
    @game_map = null
    @details = null
    @details_as_of = null

    @events_as_of = null

    @current_date = null
    @current_season = null

    @tycoons_online = []

  subscribe_map_data_listener: (listener_callback) -> @event_listener.subscribe('player.map_data', listener_callback)
  notify_map_data_listeners: (chunk_event) -> @event_listener.notify_listeners('player.map_data', chunk_event)

  subscribe_planet_details_listener: (listener_callback) -> @event_listener.subscribe('player.planet_details', listener_callback)
  notify_planet_details_listeners: () -> @event_listener.notify_listeners('player.planet_details')

  has_data: () -> @details?

  load_game_map: (game_map) ->
    @game_map = game_map
    # FIXME: TODO: may want to notify

  load_planet_details: (details) ->
    @details = details
    @details_as_of = moment()
    @notify_planet_details_listeners()

  can_place_building: (map_x, map_y, building_zone, width, height) ->
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
          can_place = false if building_zone? && zone_info? && !BuildingZone.zones_match(zone_info, building_zone)

        can_place = false if @game_map.ground_map?.is_coast_at(tile_i, tile_j) || @game_map?.ground_map?.is_water_at(tile_i, tile_j) && @game_map?.ground_map?.is_coast_around(tile_i, tile_j)

    has_all_data && can_place
