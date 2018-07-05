
###
global PIXI
###

class AssetManager
  constructor: (@client) ->
    PIXI.loader.baseUrl = "https://cdn.starpeace.io"
    PIXI.loader.onProgress.add (e) =>
      @loading_progress = e.progress

    @loading = false

    @key_callbacks = {}
    @loaded_keys = new Set()

  queue: (key, asset_url, callback) ->
    if @loaded_keys.has(key)
      Logger.debug "attempted to load same key more than once: #{key}"
      return

    PIXI.loader.add(key, asset_url)
    @key_callbacks[key] = callback

  load_queued: () ->
    pending_keys = Object.keys(@key_callbacks)
    return unless pending_keys.length
    return if @loading

    @loading = true
    @client.game_state.start_ajax()
    PIXI.loader.load (loader, resources) =>
      for key in pending_keys
        if resources[key]?
          @key_callbacks[key](resources[key])
          @loaded_keys.add(key)
          delete @key_callbacks[key]
        true

      @client.game_state.finish_ajax()
      @loading = false
      setTimeout((=> @load_queued()), 250) if Object.keys(@key_callbacks).length

export default AssetManager
