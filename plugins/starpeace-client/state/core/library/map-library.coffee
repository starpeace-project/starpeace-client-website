
import Library from '~/plugins/starpeace-client/state/core/library/library.coffee'
import TextureAtlasCache from '~/plugins/starpeace-client/state/core/texture-atlas-cache.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class MapLibrary extends Library
  constructor: () ->
    super()

    @texture_by_map_id = {}

  has_assets: (map_id) -> @texture_by_map_id[map_id]?

  texture_for_id: (map_id) -> @texture_by_map_id[map_id]
  load_map_texture: (map_id, texture) ->
    @texture_by_map_id[map_id] = texture
    @notify_listeners()
