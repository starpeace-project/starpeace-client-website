
import AssetLibrary from '~/plugins/starpeace-client/state/core/library/asset-library.coffee'
import TextureAtlasCache from '~/plugins/starpeace-client/state/core/texture-atlas-cache.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class BuildingLibrary extends AssetLibrary
  constructor: () ->
    super()

    @texture_cache = new TextureAtlasCache()

    @metadata_by_id = {}
    @metadata_by_seal_id = {}

    @images_by_id = {}

  has_metadata: () -> Object.keys(@metadata_by_id).length > 0
  has_assets: () -> @has_metadata() && @texture_cache.has_assets()

  initialize: () ->
    for key,info of @metadata_by_id
      for seal_id in (info.seal_ids || [])
        @metadata_by_seal_id[seal_id] = [] unless @metadata_by_seal_id[seal_id]?
        @metadata_by_seal_id[seal_id].push info


  load_buildings: (definitions, images) ->
    @metadata_by_id[building_definition.id] = building_definition for building_definition in definitions
    @images_by_id[building_image.id] = building_image for building_image in images
    @notify_listeners()

  load_required_atlases: (atlases) ->
    @texture_cache.set_required_atlases(atlases)

  load_atlas: (atlas_key, atlas) ->
    @texture_cache.load_atlas(atlas_key, atlas)
    @notify_listeners()
