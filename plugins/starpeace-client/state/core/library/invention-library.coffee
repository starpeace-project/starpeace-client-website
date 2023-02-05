import _ from 'lodash'

import Library from '~/plugins/starpeace-client/state/core/library/library.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'
import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

export default class InventionLibrary extends Library
  constructor: () ->
    super()
    @reset_planet()

  reset_planet: () ->
    @metadata_by_id = {}
    @child_ids_by_id = {}

    @upstream_ids_by_id = {}
    @downstream_ids_by_id = {}

    @inventions_by_seal = {}
    @allowing_building_by_seal_id = {}

  has_metadata: () -> Object.keys(@metadata_by_id).length > 0

  initialize: (building_library, planet_library) ->
    return unless building_library.metadata_by_id?

    @allowing_building_by_seal_id = {}
    for seal_id in planet_library.seals_for_inventions()
      invention_ids = {}
      for definition in building_library.definitions_for_seal(seal_id)
        for invention_id in (definition.allowed_invention_ids || [])
          invention_ids[invention_id] = new Set() unless invention_ids[invention_id]?
          invention_ids[invention_id].add(definition.id)
      @allowing_building_by_seal_id[seal_id] = invention_ids

    @inventions_by_seal = {}
    for id,invention of @metadata_by_id
      for seal_id in planet_library.seals_for_inventions()
        if @allowing_building_by_seal_id[seal_id]?[id]?.size
          @inventions_by_seal[seal_id] = [] unless @inventions_by_seal[seal_id]?
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
  metadata_for_id: (invention_id) -> @metadata_by_id[invention_id]
  metadata_for_seal_id: (seal_id) -> if @inventions_by_seal[seal_id]? then @inventions_by_seal[seal_id] else []
