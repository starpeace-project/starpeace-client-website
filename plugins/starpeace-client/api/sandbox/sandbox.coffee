
import _ from 'lodash'
import { DateTime } from 'luxon';

import TimeUtils from '~/plugins/starpeace-client/utils/time-utils'
import Utils from '~/plugins/starpeace-client/utils/utils'

import SandboxBookmarks from '~/plugins/starpeace-client/api/sandbox/sandbox-bookmarks.coffee'
import SandboxBuildings from '~/plugins/starpeace-client/api/sandbox/sandbox-buildings.coffee'
import SandboxData from '~/plugins/starpeace-client/api/sandbox/sandbox-data'
import SandboxInventions from '~/plugins/starpeace-client/api/sandbox/sandbox-inventions.coffee'
import SandboxMail from '~/plugins/starpeace-client/api/sandbox/sandbox-mail.coffee'


export default class Sandbox
  constructor: () ->
    @sandbox_data = new SandboxData()
    @sandbox_bookmarks = new SandboxBookmarks(@)
    @sandbox_buildings = new SandboxBuildings(@)
    @sandbox_inventions = new SandboxInventions(@)
    @sandbox_mail = new SandboxMail(@)

    @session_tokens = {}
    @visasById = {}

  valid_session: (token) -> @session_tokens[token]? && TimeUtils.within_minutes(@session_tokens[token], 60)
  register_session: (type) ->
    token = Utils.uuid()
    @session_tokens[token] = DateTime.now()
    token

  cost_for_invention_id: (invention_id) ->
    if window?.starpeace_client?.client_state?.core?.invention_library?
      window.starpeace_client.client_state.core.invention_library.metadata_by_id[invention_id]?.properties?.price || 0
    else
      0

  tick_day: () ->
    @sandbox_data.planet_id_dates[id] = @sandbox_data.planet_id_dates[id].plus({ day: 1 }) for id,date of @sandbox_data.planet_id_dates

    for corp_id,corp_cashflow of @sandbox_data.corporation.cashflowByCorporationId
      for company_id,company of corp_cashflow.companiesById
        cashflow_adjustment = 0
        cashflow_adjustment += @sandbox_inventions.do_pending(company_id)
        cashflow_adjustment += @sandbox_buildings.do_construction(company_id)

        company.adjustCashflow(cashflow_adjustment)
      corp_cashflow.incrementCash()
