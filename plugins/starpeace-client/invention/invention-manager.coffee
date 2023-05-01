
import Logger from '~/plugins/starpeace-client/logger.coffee'
import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

import CompanyInventions from '~/plugins/starpeace-client/invention/company-inventions'

export default class InventionManager
  constructor: (@api, @asset_manager, @ajax_state, @client_state) ->
    @chunk_promises = {}

  initialize: () ->
    @client_state.core.invention_library.initialize(@client_state.core.building_library, @client_state.core.planet_library)

  load_by_company: (company_id) ->
    throw Error() if !@client_state.has_session() || !company_id?
    await @ajax_state.locked('player.inventions_metadata', company_id, =>
      summary = CompanyInventions.fromJson(await @api.inventions_for_company(company_id))
      @client_state.corporation.update_company_inventions_metadata(company_id, summary)
      summary
    )

  sell_invention: (company_id, invention_id) ->
    throw Error() if !@client_state.has_session() || !company_id? || !invention_id?
    await @ajax_state.locked('player.sell_invention', company_id, =>
      summary = CompanyInventions.fromJson(await @api.sell_company_invention(company_id, invention_id))
      @client_state.corporation.update_company_inventions_metadata(company_id, summary)
      summary
    )

  queue_invention: (company_id, invention_id) ->
    throw Error() if !@client_state.has_session() || !company_id? || !invention_id?
    await @ajax_state.locked('player.queue_invention', company_id, =>
      summary = CompanyInventions.fromJson(await @api.queue_company_invention(company_id, invention_id))
      @client_state.corporation.update_company_inventions_metadata(company_id, summary)
      summary
    )
