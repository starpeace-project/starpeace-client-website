
export default class InventionInfo
  constructor: (@metadata) ->
    @upstream_ids = null
    @downstream_ids = null

  is_related: (link) ->
    @upstream_ids?[link.source]? && @upstream_ids?[link.target]? || @downstream_ids?[link.source]? && @downstream_ids?[link.target]?
