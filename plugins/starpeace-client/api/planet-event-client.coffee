import _ from 'lodash';
import { DateTime } from 'luxon';
import { io, Socket } from 'socket.io-client';
import { SocketIO as MockIO } from 'mock-socket';

import { BASE_HOSTNAME } from '~/plugins/starpeace-client/api/sandbox/sandbox-configuration.coffee'

export default class PlanetEventClient
  constructor: (@api_client, @client_state) ->
    galaxy_config = @client_state.core.galaxy_cache.galaxy_configuration(@client_state.identity.galaxy_id)
    throw "no configuration for galaxy" unless galaxy_config?.api_url? && galaxy_config?.api_port?

    @disconnecting = false
    @planet_id = @client_state.player.planet_id
    @client_state.planet.connecting = true
    if galaxy_config.api_url == BASE_HOSTNAME
      @api_client.mockConfiguration.socketEvents.planet_id = @client_state.player.planet_id
      @api_client.mockConfiguration.socketEvents.visa_id = @client_state.player.planet_visa_id
      @socket = MockIO.connect("ws://#{galaxy_config.api_url}:#{galaxy_config.api_port}")
      @configure()
    else
      @socket = io("ws://#{galaxy_config.api_url}:#{galaxy_config.api_port}", {
        autoConnect: false,
        transports: ['websocket'] # disable 'polling' as long-poll upgrade depends on sticky sessions,
        query: {
          JWT: @client_state.options.galaxy_jwt
          PlanetId: @client_state.player.planet_id
          VisaId: @client_state.player.planet_visa_id
        }
      })
      @configure()
      @socket.connect()

    @updateViewTarget = _.debounce(() =>
      if @socket? && @client_state.planet?.connected
        center = @client_state.camera.center()
        center_iso = @client_state.camera.map_to_iso(center.x, center.y)
        @socket.emit('view', { viewX: center_iso.i, viewY: center_iso.j })
    , 1000)

  disconnect: () ->
    @disconnecting = true
    @socket.disconnect() if @client_state.planet.connecting || @client_state.planet.connected

  configure: () ->
    @socket.on('connect_error', (error) =>
      console.log("error: #{error}")
    )

    @socket.on('connect', () =>
      @client_state.planet.connecting = false
      @client_state.planet.connected = true
      @client_state.planet.notify_state_listeners()
    )

    @socket.on('disconnect', () =>
      if !@disconnecting && @planet_id == @client_state.player.planet_id
        @client_state.planet.connecting = false
        @client_state.planet.connected = false
        @client_state.planet.notify_state_listeners()
        @client_state.handle_connection_disconnect()
    )

    @socket.on('initialize', (event) =>
      time = DateTime.fromISO(event.planet.time)
      @client_state.camera.recenter_at(event.view.x, event.view.y) if event.view?
      @client_state.planet.load_state(time, event.planet)

      if event.corporation
        last_mail = if event.corporation.lastMailAt? then DateTime.fromISO(event.corporation.lastMailAt) else null
        @client_state.corporation.update_cashflow(last_mail, event.corporation.cash, event.corporation.cashCurrentYear, event.corporation.cashflow)
        @client_state.corporation.update_cashflow_companies(event.corporation.companies)
        @client_state.core.corporation_cache.update_cashflow(@client_state.player.corporation_id, time, event.corporation.cash, event.corporation.cashCurrentYear, event.corporation.cashflow)
    )

    @socket.on('simulation', (event) =>
      time = DateTime.fromISO(event.planet.time)
      @client_state.planet.load_state(time, event.planet)

      if event.corporation
        last_mail = if event.corporation.lastMailAt? then DateTime.fromISO(event.corporation.lastMailAt) else null
        @client_state.corporation.update_cashflow(last_mail, event.corporation.cash, event.corporation.cashCurrentYear, event.corporation.cashflow)
        @client_state.corporation.update_cashflow_companies(event.corporation.companies)
        @client_state.core.corporation_cache.update_cashflow(@client_state.player.corporation_id, time, event.corporation.cash, event.corporation.cashCurrentYear, event.corporation.cashflow)
    )

  # events_for_planet: (last_update) ->
  #   @get("events", {
  #     lastUpdate: last_update.toISO()
  #   }, (result) -> result || {})

  # load_events: () ->
  #   new Promise (done, error) =>
  #     if !@client_state.has_session() || @ajax_state.is_locked('planet_events', 'ALL')
  #       done()
  #     else
  #       lock = @ajax_state.with_lock('planet_events', 'ALL', done, error)
  #       events_as_of = @client_state.planet.events_as_of || DateTime.now()
  #       refresh_at = DateTime.now()
  #       @api.events_for_planet(events_as_of)
  #         .then (json) =>
  #           @client_state.planet.load_state(DateTime.fromISO(json.time), json.season)

  #           for building_event in (json.buildingEvents || [])
  #             building_chunk_info = @client_state.planet.game_map.building_map.chunk_building_info_at(building_event.x, building_event.y)
  #             @client_state.planet.game_map.building_map.chunk_building_update_at(building_event.x, building_event.y) if building_chunk_info?

  #           @client_state.planet.events_as_of = refresh_at
  #           lock.done()
  #         .catch (err) => lock.error(err)

  # cashflow_for_corporation: (corporation_id) ->
  #   @get("corporations/#{corporation_id}/cashflow", {}, (result) -> result)

  # load_cashflow: () ->
  #   corporation_id = @client_state.player.corporation_id
  #   throw Error() if !@client_state.has_session() || !corporation_id?
  #   await @ajax_state.locked('corporation_events', corporation_id, =>
  #     cashflow_json = await @api.cashflow_for_corporation(corporation_id)
  #     mailAt = if cashflow_json.lastMailAt? then DateTime.fromISO(cashflow_json.lastMailAt) else null
  #     @client_state.corporation.update_cashflow(mailAt, cashflow_json.cash || 0, cashflow_json.cashflow || 0)
  #     @client_state.corporation.update_cashflow_companies(cashflow_json.companies || [])
  #     cashflow_json
  #   )
