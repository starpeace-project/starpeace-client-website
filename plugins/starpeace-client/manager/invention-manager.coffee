
import Vue from 'vue'

import Logger from '~/plugins/starpeace-client/logger.coffee'
import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

import CompanySeal from '~/plugins/starpeace-client/industry/company-seal.coffee'

export default class InventionManager
  constructor: (@api, @asset_manager, @building_manager, @event_listener, @game_state) ->
    @chunk_promises = {}

    @requested_invention_metadata = false
    @inventions_by_id = null
    @invention_dependencies_by_id = null

    @invention_info_by_id = null

    @inventions_without_seal = []
    @inventions_by_seal = {}

    @vue_state_counter = 0

  has_assets: () ->
    @inventions_by_id? && Object.keys(@inventions_by_id).length

  initialize: () ->
    if @building_manager.building_metadata?.buildings?
      category_industry_type_seals = {}
      for key,info of @building_manager.building_metadata.buildings
        continue unless info.category?.length && info.industry_type?.length
        for seal_id in (info.seal_ids || [])
          category_industry_type_seals[info.category] = {} unless category_industry_type_seals[info.category]?
          category_industry_type_seals[info.category][info.industry_type] = {} unless category_industry_type_seals[info.category][info.industry_type]?
          category_industry_type_seals[info.category][info.industry_type][seal_id] = true unless category_industry_type_seals[info.category][info.industry_type][seal_id]?

      for id,invention of @inventions_by_id
        unless invention.category?.length && invention.industry_type?.length
          @inventions_without_seal.push invention
          continue

        if invention.industry_type == 'GENERAL'
          for seal_id,seal of CompanySeal.SEALS
            Vue.set(@inventions_by_seal, seal_id, []) unless @inventions_by_seal[seal_id]?
            @inventions_by_seal[seal_id].push invention

        else if category_industry_type_seals[invention.category]?[invention.industry_type]?
          for seal_id in Object.keys(category_industry_type_seals[invention.category]?[invention.industry_type])
            Vue.set(@inventions_by_seal, seal_id, []) unless @inventions_by_seal[seal_id]?
            @inventions_by_seal[seal_id].push invention


  queue_asset_load: () ->
    return if @requested_invention_metadata || @inventions_by_id?
    @requested_invention_metadata = true
    @asset_manager.queue('metadata.inventions', './invention.metadata.json', (resource) =>
      @configure_inventions(resource.data?.inventions || [])
    )

  configure_inventions: (inventions) ->
    @inventions_by_id = {}
    @invention_dependencies_by_id = {}
    @invention_info_by_id = {}
    for invention in inventions
      @inventions_by_id[invention.id] = invention
      for invention_id in (invention.depends_on || [])
        @invention_dependencies_by_id[invention_id] = [] unless @invention_dependencies_by_id[invention_id]?
        @invention_dependencies_by_id[invention_id].push invention.id

    for invention_id,invention of @inventions_by_id
      @invention_info_by_id[invention.id] = {
        invention: invention
        upstream: @upstream_inventions_for(invention)
        downstream: @downstream_inventions_for(invention)
        is_related: (link) -> @upstream[link.source] && @upstream[link.target] || @downstream[link.source] && @downstream[link.target]
      }

    @vue_state_counter += 1

  upstream_inventions_for: (invention) ->
    upstream = {}
    pending_search = [invention]
    while pending_search.length
      pending_invention = pending_search.pop()
      for invention_id in (pending_invention.depends_on || [])
        unless upstream[invention_id]?
          upstream_invention = @inventions_by_id[invention_id]
          upstream[upstream_invention.id] = upstream_invention
          pending_search.push upstream_invention
    upstream

  downstream_inventions_for: (invention) ->
    downstream = {}
    pending_search = [invention]
    while pending_search.length
      pending_invention = pending_search.pop()
      downstream_inventions = @invention_dependencies_by_id[pending_invention.id]
      for invention_id in (downstream_inventions || [])
        unless downstream[invention_id]?
          downstream_invention = @inventions_by_id[invention_id]
          downstream[downstream_invention.id] = downstream_invention
          pending_search.push downstream_invention
    downstream


  load_metadata: (company_id) ->
    new Promise (done, error) =>
      @game_state.session_state.start_inventions_metadata_request(company_id)
      @api.inventions_metadata(@game_state.session_state.session_token, company_id)
        .then (metadata) =>
          @game_state.session_state.set_inventions_metadata_for_id(company_id, metadata)
          @game_state.session_state.finish_inventions_metadata_request(company_id)
          @event_listener.notify_company_metadata_listeners()
          done()

        .catch (err) =>
          # FIXME: TODO add error handling
          @game_state.session_state.finish_inventions_metadata_request(company_id)
          error()
