
import AssetLibrary from '~/plugins/starpeace-client/state/core/library/asset-library.coffee'
import TextureAtlasCache from '~/plugins/starpeace-client/state/core/texture-atlas-cache.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class LandLibrary extends AssetLibrary
  constructor: () ->
    super()

    @texture_cache_by_planet_type = {}

    @metadata_by_planet_type = {}

  has_metadata: (planet_type) -> @metadata_by_planet_type[planet_type]?
  has_assets: (planet_type) -> @has_metadata(planet_type) && @texture_cache(planet_type).has_assets()

  texture_cache: (planet_type) ->
    @texture_cache_by_planet_type[planet_type] = new TextureAtlasCache() unless @texture_cache_by_planet_type[planet_type]?
    @texture_cache_by_planet_type[planet_type]

  load_land_metadata: (land_metadata) ->
    @metadata_by_planet_type[land_metadata.planet_type] = land_metadata
    @notify_listeners()

  load_required_atlases: (planet_type, atlases) ->
    @texture_cache(planet_type).set_required_atlases(atlases)

  load_atlas: (planet_type, atlas_key, atlas) ->
    @texture_cache(planet_type).load_atlas(atlas_key, atlas)
    @notify_listeners()

  metadata_for_planet_type: (planet_type) -> @metadata_by_planet_type[planet_type]
