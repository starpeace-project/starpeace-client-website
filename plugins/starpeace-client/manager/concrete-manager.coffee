
export default class ConcreteManager
  constructor: (@asset_manager, @event_listener) ->
    @requested_concrete_metadata = false
    @concrete_metadata = null
    @loaded_atlases = {}

  has_assets: () ->
    @concrete_metadata? && @concrete_metadata.atlas.length == Object.keys(@loaded_atlases).length

  queue_asset_load: () ->
    return if @requested_concrete_metadata
    @requested_concrete_metadata = true
    @asset_manager.queue('metadata.concrete', './concrete.metadata.json', (resource) =>
      @concrete_metadata = resource.data
      concrete.key = key for key,concrete of @concrete_metadata.concrete
      @load_concrete_atlas(resource.data.atlas)
    )

  load_concrete_atlas: (atlas_paths) ->
    for path in atlas_paths
      do (path) =>
        @asset_manager.queue(path, path, (resource) =>
          @loaded_atlases[path] = resource
          @event_listener.notify_asset_listeners()
        )
    @asset_manager.load_queued()
