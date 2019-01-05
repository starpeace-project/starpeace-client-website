
import _ from 'lodash'
import Vue from 'vue'

import CompanySeal from '~/plugins/starpeace-client/industry/company-seal.coffee'
import AssetLibrary from '~/plugins/starpeace-client/state/core/library/asset-library.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'
import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

export default class InventionLibrary extends AssetLibrary
  constructor: () ->
    super()

    @metadata_by_id = {}
    @child_ids_by_id = {}

    @upstream_ids_by_id = {}
    @downstream_ids_by_id = {}

    @inventions_without_seal = []
    @inventions_by_seal = {}


  has_metadata: () -> Object.keys(@metadata_by_id).length > 0

  initialize: (building_library) ->
    if building_library.metadata_by_id?
      category_industry_type_seals = {}
      for key,info of building_library.metadata_by_id
        continue unless info.category?.length && info.industry_type?.length
        for seal_id in (info.seal_ids || [])
          category_industry_type_seals[info.category] = {} unless category_industry_type_seals[info.category]?
          category_industry_type_seals[info.category][info.industry_type] = {} unless category_industry_type_seals[info.category][info.industry_type]?
          category_industry_type_seals[info.category][info.industry_type][seal_id] = true unless category_industry_type_seals[info.category][info.industry_type][seal_id]?

          if info.industry_type == 'LC_RESIDENTIAL' || info.industry_type == 'MC_RESIDENTIAL' || info.industry_type == 'HC_RESIDENTIAL'
            category_industry_type_seals[info.category]['RESIDENTIAL'] = {} unless category_industry_type_seals[info.category]['RESIDENTIAL']?
            category_industry_type_seals[info.category]['RESIDENTIAL'][seal_id] = true unless category_industry_type_seals[info.category]['RESIDENTIAL'][seal_id]?

      @inventions_without_seal = []
      @inventions_by_seal = {}
      for id,invention of @metadata_by_id
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


  load_inventions: (inventions) ->
    for invention in inventions
      @metadata_by_id[invention.id] = invention

      for invention_id in (invention.depends_on || [])
        @child_ids_by_id[invention_id] = [] unless @child_ids_by_id[invention_id]?
        @child_ids_by_id[invention_id].push invention.id

    @notify_listeners()

  upstream_ids_for: (invention_id) ->
    unless @upstream_ids_by_id[invention_id]?
      upstream_ids = {}
      pending_search = [invention_id]
      while pending_search.length
        pending_invention = @metadata_by_id[pending_search.pop()]
        for parent_invention_id in (pending_invention.depends_on || [])
          unless upstream_ids[parent_invention_id]?
            upstream_ids[parent_invention_id] = true
            pending_search.push parent_invention_id
      @upstream_ids_by_id[invention_id] = Object.keys(upstream_ids)
    @upstream_ids_by_id[invention_id] || []

  downstream_ids_for: (invention_id) ->
    unless @downstream_ids_by_id[invention_id]?
      downstream_ids = {}
      pending_search = [invention_id]
      while pending_search.length
        pending_invention = @metadata_by_id[pending_search.pop()]
        downstream_inventions = @child_ids_by_id[pending_invention.id]
        for child_invention_id in (downstream_inventions || [])
          unless downstream_ids[child_invention_id]?
            downstream_ids[child_invention_id] = true
            pending_search.push child_invention_id
      @downstream_ids_by_id[invention_id] = Object.keys(downstream_ids)
    @downstream_ids_by_id[invention_id] || []

  all_metadata: () -> _.values(@metadata_by_id)
  metadata_for_id: (invention_id) ->  @metadata_by_id[invention_id]
  metadata_for_seal_id: (seal_id) -> if @inventions_by_seal[seal_id]? then @inventions_by_seal[seal_id] else []
