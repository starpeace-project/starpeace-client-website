import { Assets } from '@pixi/assets';

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class AssetManager
  @CDN_URL: 'https://cdn.starpeace.io'
  @CDN_VERSION: 'f53ac31bf9da5760df8621bc68ab9aee'

  constructor: (@ajax_state) ->
    Assets.init({
      basePath: "#{AssetManager.CDN_URL}/#{AssetManager.CDN_VERSION}"
    })

    @loading = false

    @key_callbacks = {}
    @loaded_keys = new Set()

  planet_animation_url: (planet) -> "#{AssetManager.CDN_URL}/#{AssetManager.CDN_VERSION}/map.#{planet.map_id}.animation.gif"

  queue: (key, asset_url, callback) ->
    if @loaded_keys.has(key)
      Logger.debug "attempted to load same key more than once: #{key}"
      return callback()

    Assets.add(key, asset_url)
    @key_callbacks[key] = callback

  load_queued: () ->
    pending_keys = Object.keys(@key_callbacks)
    return unless pending_keys.length
    return if @loading

    @loading = true
    @ajax_state.start_ajax()
    try
      resources = await Assets.load(pending_keys, (progress) -> console.debug('Asset loading progress', progress))

      for key in pending_keys
        if resources[key]?
          @key_callbacks[key](resources[key])
          @loaded_keys.add(key)
          delete @key_callbacks[key]
        true

      @ajax_state.finish_ajax()
      @loading = false
      setTimeout((=> @load_queued()), 250) if Object.keys(@key_callbacks).length

    catch err
      console.error(err)
      @loading = false


  queue_and_load_atlases: (atlases, callback) ->
    for path in atlases
      do (path) =>
        @queue(path, path, (resource) -> callback(path, resource))
    @load_queued()
