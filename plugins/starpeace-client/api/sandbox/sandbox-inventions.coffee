import _ from 'lodash'


export default class SandboxInventions
  constructor: (@sandbox) ->

  do_pending: (company_id) ->
    cashflow_adjustment = 0
    inventions = @sandbox.sandbox_data.corporation.inventionsByCompanyId[company_id]

    if inventions?.activeId?.length
      cost = @sandbox.cost_for_invention_id(inventions.activeId)
      step_increment = Math.round(cost / 30)
      inventions.activeInvestment += step_increment
      cashflow_adjustment -= (step_increment / 24)

      if inventions.activeInvestment >= cost
        inventions.completedIds.push inventions.activeId
        inventions.activeId = null
        inventions.activeInvestment = 0

    else if inventions?.pendingIds?.length
      inventions.activeId = inventions?.pendingIds.splice(0, 1)[0]
      inventions.activeInvestment = 0

    cashflow_adjustment

  company_inventions: (company_id) ->
    _.cloneDeep {
      companyId: company_id
      pendingIds: (@sandbox.sandbox_data.corporation.inventionsByCompanyId[company_id]?.pendingIds || [])
      activeId: @sandbox.sandbox_data.corporation.inventionsByCompanyId[company_id]?.activeId
      activeInvestment: (@sandbox.sandbox_data.corporation.inventionsByCompanyId[company_id]?.activeInvestment || 0)
      completedIds: (@sandbox.sandbox_data.corporation.inventionsByCompanyId[company_id]?.completedIds || [])
    }

  sell_company_invention: (company_id, invention_id) ->
    throw new Error(404) unless @sandbox.sandbox_data.corporation.inventionsByCompanyId[company_id]?

    refund = 0

    inventions = @sandbox.sandbox_data.corporation.inventionsByCompanyId[company_id]
    completed_index = inventions.completedIds.indexOf(invention_id)
    if completed_index >= 0
      refund = @sandbox.cost_for_invention_id(invention_id)
      inventions.completedIds.splice(completed_index, 1)

    if inventions.activeId == invention_id
      refund = inventions.activeInvestment
      inventions.activeId = null
      inventions.activeInvestment = 0

    pending_index = inventions.pendingIds.indexOf(invention_id)
    inventions.pendingIds.splice(pending_index, 1) if pending_index >= 0

    corporation_id = @sandbox.sandbox_data.corporation.infoByCompanyId[company_id].corporation_id
    @sandbox.sandbox_data.corporation.cashflowByCorporationId[corporation_id].companiesById[company_id].adjustCashflow(refund)
    @company_inventions(company_id)

  queue_company_invention: (company_id, invention_id) ->
    throw new Error(404) unless @sandbox.sandbox_data.corporation.inventionsByCompanyId[company_id]?

    inventions = @sandbox.sandbox_data.corporation.inventionsByCompanyId[company_id]

    completed_index = inventions.completedIds.indexOf(invention_id)
    pending_index = inventions.pendingIds.indexOf(invention_id)
    inventions.pendingIds.push(invention_id) if completed_index < 0 && pending_index < 0

    @company_inventions(company_id)
