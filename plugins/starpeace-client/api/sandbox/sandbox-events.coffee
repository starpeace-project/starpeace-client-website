
import _ from 'lodash'


export default class SandboxEvents
  constructor: (@sandbox) ->
    @queued_events = []

    @building_events = []

  building_events_since: (as_of) ->
    events = []
    for event in @building_events
      if !as_of? || event.createdAt.isAfter(as_of)
        events.push event
    events

  do_events: (company_id) ->
    cashflow_adjustment = 0
    to_remove = []

    for event,index in @queued_events
      if event.company_id == company_id
        to_remove.push index
        if event.type == 'SELL_RESEARCH'
          cashflow_adjustment += (@sandbox.cost_for_invention_id(event.invention_id) / 24)
        else if event.type == 'CANCEL_RESEARCH'
          cashflow_adjustment += (event.refund / 24)

    @queued_events.splice(index, 1) for index in to_remove.sort((lhs, rhs) -> rhs - lhs)
    cashflow_adjustment
