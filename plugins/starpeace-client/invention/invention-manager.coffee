
import Vue from 'vue'

import Logger from '~/plugins/starpeace-client/logger.coffee'
import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

import CompanySeal from '~/plugins/starpeace-client/industry/company-seal.coffee'

export default class InventionManager
  constructor: (@api, @asset_manager, @ajax_state, @client_state) ->
    @chunk_promises = {}

  initialize: () ->
    @client_state.core.invention_library.initialize(@client_state.core.building_library)

  queue_asset_load: () ->
    return if @client_state.core.invention_library.has_metadata() || @ajax_state.is_locked('assets.invention_metadata', 'ALL')

    @ajax_state.lock('assets.invention_metadata', 'ALL')
    @asset_manager.queue('metadata.inventions', './invention.metadata.json', (resource) =>
      # FIXME: TODO: convert json to object
      @client_state.core.invention_library.load_inventions(resource.data?.inventions || [])

      @ajax_state.unlock('assets.invention_metadata', 'ALL')
    )

  load_metadata: (company_id) ->
    new Promise (done, error) =>
      if !@client_state.has_session() || !company_id? || @ajax_state.is_locked('player.inventions_metadata', company_id)
        done()
      else
        @ajax_state.lock('player.inventions_metadata', company_id)
        @api.inventions_metadata(@client_state.session.session_token, company_id)
          .then (metadata) =>
            # FIXME: TODO: convert json to object
            @client_state.corporation.set_company_inventions_metadata(company_id, metadata)

            @ajax_state.unlock('player.inventions_metadata', company_id)
            done()

          .catch (err) =>
            @ajax_state.unlock('player.inventions_metadata', company_id) # FIXME: TODO add error handling
            error()
