
import Library from '~/plugins/starpeace-client/state/core/library/library.coffee'
import TextureAtlasCache from '~/plugins/starpeace-client/state/core/texture-atlas-cache.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class EffectLibrary extends Library
  constructor: () ->
    super()

    @texture_cache = new TextureAtlasCache()

    @metadata_by_id = {}

  has_metadata: () -> Object.keys(@metadata_by_id).length
  has_assets: () -> @has_metadata() && @texture_cache.has_assets()

  load_effect_metadata: (effect_metadata) ->
    @metadata_by_id[effect.id] = effect for effect in effect_metadata
    @notify_listeners()

  load_required_atlases: (atlases) ->
    @texture_cache.set_required_atlases(atlases)

  load_atlas: (atlas_key, atlas) ->
    @texture_cache.load_atlas(atlas_key, atlas)
    @notify_listeners()
