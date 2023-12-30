import _ from 'lodash';
import { SocketIO as MockIO, Server } from 'mock-socket';

import { BASE_HOSTNAME, BASE_PORT } from '~/plugins/starpeace-client/api/sandbox/sandbox-configuration.coffee'


export default class SandboxSocketEvents
  constructor: (@sandbox) ->
    @mockServer = new Server("ws://#{BASE_HOSTNAME}:#{BASE_PORT}")

    determineCashflowJson = () =>
      visa = @sandbox.visasById[@visa_id]

      if !visa.corporationId then null else {
        m: @sandbox.sandbox_data.corporation.cashflowByCorporationId[visa.corporationId]?.lastMailAt?.toSeconds(),
        c: (@sandbox.sandbox_data.corporation.cashflowByCorporationId[visa.corporationId]?.cash || 0),
        f: (@sandbox.sandbox_data.corporation.cashflowByCorporationId[visa.corporationId]?.cashflow() || 0),
        o: _.map(_.values(@sandbox.sandbox_data.corporation.cashflowByCorporationId[visa.corporationId]?.companiesById), (company) =>
          return {
            i: company.id,
            f: company.cashflow
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
        v: { x: 200, y: 100 },
        p: {
          t: @sandbox.sandbox_data.planet_id_dates[@planet_id].toSeconds(),
          s: @sandbox.sandbox_data.season_for_planet(@planet_id)
        },
        c: determineCashflowJson()
      })

      @simulationEmitter = setInterval(() =>
        socket.emit('simulation', {
          p: {
            t: @sandbox.sandbox_data.planet_id_dates[@planet_id].toSeconds(),
            s: @sandbox.sandbox_data.season_for_planet(@planet_id)
          },
          c: determineCashflowJson()
        })
      , 1000)
    )
