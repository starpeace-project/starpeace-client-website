
import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class EffectManager
  constructor: (@client) ->
    @requested_effect_metadata = false
    @effect_metadata = null
    @loaded_atlases = {}
    @effect_textures = {}

  has_assets: () ->
    @effect_metadata? && @effect_metadata.atlas.length == Object.keys(@loaded_atlases).length

  queue_asset_load: () ->
    return if @requested_effect_metadata
    @requested_effect_metadata = true
    @client.asset_manager.queue('metadata.effect', './effect.metadata.json', (resource) =>
      @effect_metadata = resource.data
      effect.key = key for key,effect of @effect_metadata.effects
      @load_effect_atlas(resource.data.atlas)
    )

  load_effect_atlas: (atlas_paths) ->
    for path in atlas_paths
      do (path) =>
        @client.asset_manager.queue(path, path, (resource) =>
          @loaded_atlases[path] = resource
          @effect_textures[effect.key] = _.map(effect.frames, (frame) -> PIXI.utils.TextureCache[frame]) for effect in @effects_for_atlas(path)
          @client.notify_assets_changed()
        )
    @client.asset_manager.load_queued()

  effects_for_atlas: (atlas_key) ->
    atlas_key = atlas_key.substring(2) if atlas_key.startsWith('./')
    effects = []
    for key,effect of @effect_metadata.effects
      effects.push(effect) if effect.atlas == atlas_key
    effects
