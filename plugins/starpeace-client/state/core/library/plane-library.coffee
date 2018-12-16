
import AssetLibrary from '~/plugins/starpeace-client/state/core/library/asset-library.coffee'
import TextureAtlasCache from '~/plugins/starpeace-client/state/core/texture-atlas-cache.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class PlaneLibrary extends AssetLibrary
  constructor: () ->
    super()

    @texture_cache = new TextureAtlasCache()

    @metadata_by_id = {}

  has_metadata: () -> Object.keys(@metadata_by_id).length
  has_assets: () -> @has_metadata() && @texture_cache.has_assets()

  load_plane_metadata: (plane_metadata) ->
    @metadata_by_id[plane.id] = plane for plane in plane_metadata
    @notify_listeners()

  load_required_atlases: (atlases) ->
    @texture_cache.set_required_atlases(atlases)

  load_atlas: (atlas_key, atlas) ->
    @texture_cache.load_atlas(atlas_key, atlas)
    @notify_listeners()

  metadata_for_id: (id) -> @metadata_by_id[id]
  texture_for_id: (texture_id) -> PIXI.utils.TextureCache[texture_id]
