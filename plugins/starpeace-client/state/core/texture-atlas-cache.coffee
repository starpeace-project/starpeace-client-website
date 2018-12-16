
import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class TextureAtlasCache
  constructor: () ->
    @reset_state()

  reset_state: () ->
    @required_atlases = null
    @loaded_atlases = {}

    @textures_by_item_id = {}

  has_assets: () -> @required_atlases? && @required_atlases.length == Object.keys(@loaded_atlases).length

  set_required_atlases: (required_atlases) ->
    throw "Expected array of atlases" unless Array.isArray(required_atlases)
    @required_atlases = required_atlases

  load_atlas: (atlas_key, atlas) ->
    @loaded_atlases[atlas_key] = atlas
