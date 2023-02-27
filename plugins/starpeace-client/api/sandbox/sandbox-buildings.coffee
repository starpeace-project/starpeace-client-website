import _ from 'lodash';
import { DateTime } from 'luxon';

import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

CHUNK_WIDTH = 20
CHUNK_HEIGHT = 20

export default class SandboxBuildings
  constructor: (@sandbox) ->
    @company_id_construction = {}

  queue_construction: (planet_id, parameters) ->
    throw new Error(400) unless parameters.companyId?.length
    throw new Error(400) unless parameters.definitionId?.length
    throw new Error(400) unless parameters.name?.length
    throw new Error(400) unless parameters.mapX?
    throw new Error(400) unless parameters.mapY?

    company = @sandbox.sandbox_data.company_id_info[parameters.companyId]
    throw new Error(404) unless company?

    building = {
      id: Utils.uuid()
      tycoonId: company.tycoon_id
      corporationId: company.corporation_id
      companyId: parameters.companyId
      name: parameters.name
      definitionId: parameters.definitionId
      mapX: parameters.mapX
      mapY: parameters.mapY
      stage: -1
      progress: 0
    }

    chunk_x = Math.floor(parameters.mapX / CHUNK_WIDTH)
    chunk_y = Math.floor(parameters.mapY / CHUNK_HEIGHT)
    chunk_key = "#{chunk_x}x#{chunk_y}"

    @sandbox.sandbox_data.add_building(planet_id, parameters.companyId, chunk_key, building)

    @company_id_construction[parameters.companyId] = [] unless @company_id_construction[parameters.companyId]?
    @company_id_construction[parameters.companyId].push building

    # @sandbox.sandbox_events.building_events.push { createdAt: DateTime.now(), type: 'construct', id: building.id, definitionId: building.definitionId, x: building.mapX, y: building.mapY }

    _.cloneDeep(building)

  do_construction: (company_id) ->
    cashflow_adjustment = 0

    if @company_id_construction[company_id]?.length
      to_remove = []
      for building,index in @company_id_construction[company_id]
        if building.stage == -1
          building.progress = 22 + (building.progress || 0)
          building.progress = 100 if building.progress > 100

          cashflow_adjustment -= (5000 + Math.random() * 5000)

          if building.progress == 100
            building.stage = 0
            # @sandbox.sandbox_events.building_events.push { createdAt: DateTime.now(), type: 'stage', id: building.id, definitionId: building.definitionId, x: building.mapX, y: building.mapY }
            to_remove.push index
        else
          to_remove.push index
      @company_id_construction[company_id].splice(index, 1) for index in to_remove.sort((lhs, rhs) -> rhs - lhs)

    cashflow_adjustment
