import _ from 'lodash';
import { SocketIO as MockIO, Server } from 'mock-socket';

import { BASE_HOSTNAME, BASE_PORT } from '~/plugins/starpeace-client/api/sandbox/sandbox-configuration.coffee'


export default class SandboxSocketEvents
  constructor: (@sandbox) ->
    @mockServer = new Server("ws://#{BASE_HOSTNAME}:#{BASE_PORT}")

    determineCashflowJson = () =>
      visa = @sandbox.visasById[@visa_id]
      if !visa.corporationId then null else {
        id: visa.corporationId,
        lastMailAt: @sandbox.sandbox_data.corporation.cashflowByCorporationId[visa.corporationId]?.lastMailAt?.toISO(),
        cash: (@sandbox.sandbox_data.corporation.cashflowByCorporationId[visa.corporationId]?.cash || 0),
        cashflow: (@sandbox.sandbox_data.corporation.cashflowByCorporationId[visa.corporationId]?.cashflow() || 0),
        companies: _.map(_.values(@sandbox.sandbox_data.corporation.cashflowByCorporationId[visa.corporationId]?.companiesById), (company) =>
          return {
            id: company.id,
            cashflow: company.cashflow
          }
        )
      }

    @mockServer.on('connect', (socket) =>
      socket.on('disconnect', (data) =>
        clearTimeout(@simulationEmitter) if @simulationEmitter
      )

      socket.on('view', (data) =>
        # data == {viewX: 200, viewY: 100}
      )

      visa = @sandbox.visasById[@visa_id]
      socket.emit('initialize', {
        view: { x: 200, y: 100 },
        planet: {
          time: @sandbox.sandbox_data.planet_id_dates[@planet_id].toISO(),
          season: @sandbox.sandbox_data.season_for_planet(@planet_id)
        },
        corporation: determineCashflowJson()
      })

      @simulationEmitter = setInterval(() =>
        socket.emit('simulation', {
          planet: {
            time: @sandbox.sandbox_data.planet_id_dates[@planet_id].toISO(),
            season: @sandbox.sandbox_data.season_for_planet(@planet_id)
          },
          corporation: determineCashflowJson()
        })
      , 1000)
    )

    # @get 'corporations/(.+?)/cashflow', (config, corporation_id) =>
    #   corp_metadata = {
    #     id: corporation_id
    #     lastMailAt: @sandbox.sandbox_data.corporation.cashflowByCorporationId[corporation_id]?.lastMailAt?.toISO()
    #     cash: (@sandbox.sandbox_data.corporation.cashflowByCorporationId[corporation_id]?.cash || 0)
    #     cashflow: (@sandbox.sandbox_data.corporation.cashflowByCorporationId[corporation_id]?.cashflow() || 0)
    #     companies: _.map(_.values(@sandbox.sandbox_data.corporation.cashflowByCorporationId[corporation_id]?.companiesById), (company) -> {
    #       id: company.id
    #       cashflow: company.cashflow
    #     })
    #   }
    #   return _.cloneDeep(corp_metadata)

    # @get 'events', (config, params) =>
    #   planet_id = config.headers['PlanetId']
    #   throw new Error(404) unless @sandbox.sandbox_data?.planet_id_dates?[planet_id]?
    #   _.cloneDeep({
    #     planetId: planet_id
    #     time: @sandbox.sandbox_data.planet_id_dates[planet_id].toISO()
    #     season: @sandbox.sandbox_data.season_for_planet(planet_id)
    #     buildingEvents: @sandbox.sandbox_events.building_events_since(params.lastUpdate)
    #     tycoonEvents: []
    #   })
