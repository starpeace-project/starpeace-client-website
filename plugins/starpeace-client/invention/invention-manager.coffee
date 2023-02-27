
import Logger from '~/plugins/starpeace-client/logger.coffee'
import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

import CompanyInventions from '~/plugins/starpeace-client/invention/company-inventions'

export default class InventionManager
  constructor: (@api, @asset_manager, @ajax_state, @client_state) ->
    @chunk_promises = {}

  initialize: () ->
    @client_state.core.invention_library.initialize(@client_state.core.building_library, @client_state.core.planet_library)

  load_by_company: (company_id) ->
    new Promise (done, error) =>
      if !@client_state.has_session() || !company_id? || @ajax_state.is_locked('player.inventions_metadata', company_id)
        done()
      else
        @ajax_state.lock('player.inventions_metadata', company_id)
        @api.inventions_for_company(company_id)
          .then (json_response) =>
            @client_state.corporation.update_company_inventions_metadata(company_id, CompanyInventions.fromJson(json_response))
            @ajax_state.unlock('player.inventions_metadata', company_id)
            done()

          .catch (err) =>
            @ajax_state.unlock('player.inventions_metadata', company_id) # FIXME: TODO add error handling
            error()


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
