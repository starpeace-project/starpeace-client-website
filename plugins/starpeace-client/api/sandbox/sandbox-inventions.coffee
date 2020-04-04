
import moment from 'moment'
import _ from 'lodash'


export default class SandboxInventions
  constructor: (@sandbox) ->

  do_pending: (company_id) ->
    cashflow_adjustment = 0
    inventions = @sandbox.sandbox_data.company_id_inventions[company_id]
    if inventions?.pendingInventions?.length
      to_remove = []
      for pending,index in inventions.pendingInventions
        continue unless index == 0

        unless pending.step_increment?
          pending.cost = @sandbox.cost_for_invention_id(pending.id)
          pending.step_increment = Math.max(50000, Math.round(pending.cost / 30))
        pending.spent += pending.step_increment
        cashflow_adjustment -= (pending.step_increment / 24)

        pending.progress = Math.min(100, Math.round(pending.spent / pending.cost * 100))
        if pending.spent >= pending.cost
          to_remove.push index
          inventions.completedIds.push pending.id

      for index in to_remove.sort((lhs, rhs) -> rhs - lhs)
        inventions.pendingInventions.splice(index, 1)
      inventions.pendingInventions[index].order = index for index in [0...inventions.pendingInventions.length]
    cashflow_adjustment

  company_inventions: (company_id) ->
    _.cloneDeep {
      companyId: company_id
      pendingInventions: (@sandbox.sandbox_data.company_id_inventions[company_id]?.pendingInventions || [])
      completedIds: (@sandbox.sandbox_data.company_id_inventions[company_id]?.completedIds || [])
    }

  sell_company_invention: (company_id, invention_id) ->
    throw new Error(404) unless @sandbox.sandbox_data.company_id_inventions[company_id]?

    inventions = @sandbox.sandbox_data.company_id_inventions[company_id]
    completed_index = inventions.completedIds.indexOf(invention_id)
    pending_index = _.findIndex(inventions.pendingInventions, (pending) => pending.id == invention_id)
    if completed_index >= 0
      @sandbox.sandbox_events.queued_events.push { type: 'SELL_RESEARCH', company_id: company_id, invention_id: invention_id }
      inventions.completedIds.splice(completed_index, 1)
    else if pending_index >= 0
      @sandbox.sandbox_events.queued_events.push { type: 'CANCEL_RESEARCH', company_id: company_id, invention_id: invention_id, refund: inventions.pendingInventions[pending_index].spent }
      inventions.pendingInventions[index].order -= 1 for index in [pending_index...inventions.pendingInventions.length]
      inventions.pendingInventions.splice(pending_index, 1)

    _.cloneDeep {
      companyId: company_id
      pendingInventions: (@sandbox.sandbox_data.company_id_inventions[company_id]?.pendingInventions || [])
      completedIds: (@sandbox.sandbox_data.company_id_inventions[company_id]?.completedIds || [])
    }

  queue_company_invention: (company_id, invention_id) ->
    throw new Error(404) unless @sandbox.sandbox_data.company_id_inventions[company_id]?

    inventions = @sandbox.sandbox_data.company_id_inventions[company_id]
    completed_index = inventions.completedIds.indexOf(invention_id)
    pending_index = _.findIndex(inventions.pendingInventions, (pending) => pending.id == invention_id)
    if completed_index >= 0 || pending_index >= 0
      inventions.completedIds.splice(completed_index, 1)
    else
      inventions.pendingInventions.push {
        id: invention_id
        progress: 0
        order: inventions.pendingInventions.length
        spent: 0
      }

    _.cloneDeep {
      companyId: company_id
      pendingInventions: (@sandbox.sandbox_data.company_id_inventions[company_id]?.pendingInventions || [])
      completedIds: (@sandbox.sandbox_data.company_id_inventions[company_id]?.completedIds || [])
    }
