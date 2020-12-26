import * as PIXI from 'pixi.js'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class AssetManager
  @CDN_URL: 'https://cdn.starpeace.io'
  @CDN_VERSION: '993856094eba5eb4f402bee9eb229338'

  constructor: (@ajax_state) ->
    PIXI.Loader.shared.baseUrl = "#{AssetManager.CDN_URL}/#{AssetManager.CDN_VERSION}"
    PIXI.Loader.shared.onProgress.add (e) =>
      @loading_progress = e.progress

    @loading = false

    @key_callbacks = {}
    @loaded_keys = new Set()

  planet_animation_url: (planet) -> "#{AssetManager.CDN_URL}/#{AssetManager.CDN_VERSION}/map.#{planet.map_id}.animation.gif"

  queue: (key, asset_url, callback) ->
    if @loaded_keys.has(key)
      Logger.debug "attempted to load same key more than once: #{key}"
      return callback()

    PIXI.Loader.shared.add(key, asset_url)
    @key_callbacks[key] = callback

  load_queued: () ->
    pending_keys = Object.keys(@key_callbacks)
    return unless pending_keys.length
    return if @loading

    @loading = true
    @ajax_state.start_ajax()
    PIXI.Loader.shared.load (loader, resources) =>
      for key in pending_keys
        if resources[key]?
          @key_callbacks[key](resources[key])
          @loaded_keys.add(key)
          delete @key_callbacks[key]
        true

      @ajax_state.finish_ajax()
      @loading = false
      setTimeout((=> @load_queued()), 250) if Object.keys(@key_callbacks).length

  queue_and_load_atlases: (atlases, callback) ->
    for path in atlases
      do (path) =>
        @queue(path, path, (resource) -> callback(path, resource))
    @load_queued()
