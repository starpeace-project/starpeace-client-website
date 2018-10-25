
import Logger from '~/plugins/starpeace-client/logger.coffee'
import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

export default class InventionManager
  constructor: (@asset_manager, @event_listener, @game_state) ->
    @chunk_promises = {}

    @requested_invention_metadata = false
    @inventions_by_id = null
    @invention_dependencies_by_id = null

    @invention_info_by_id = null

    @vue_state_counter = 0

  has_assets: () ->
    @inventions_by_id? && Object.keys(@inventions_by_id).length

  queue_asset_load: () ->
    return if @requested_invention_metadata
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
