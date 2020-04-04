import Vue from 'vue'

import Library from '~/plugins/starpeace-client/state/core/library/library.coffee'
import TextureAtlasCache from '~/plugins/starpeace-client/state/core/texture-atlas-cache.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class BuildingLibrary extends Library
  constructor: () ->
    super()

    @texture_cache = new TextureAtlasCache()

    @images_by_id = {}

    @reset_planet()

  reset_planet: () ->
    @metadata_by_id = {}
    @metadata_by_seal_id = {}

    @simulations_by_id = {}

  has_metadata: () -> Object.keys(@metadata_by_id).length > 0 && Object.keys(@metadata_by_id).length == Object.keys(@simulations_by_id).length
  has_assets: () -> @has_metadata() && @texture_cache.has_assets()

  initialize: (planet_library) ->
    for seal_id in planet_library.seals_for_buildings()
      seal = planet_library.seal_for_id(seal_id)
      for building_id in seal.building_ids
        if @metadata_by_id[building_id]
          Vue.set(@metadata_by_seal_id, seal_id, []) unless @metadata_by_seal_id[seal_id]?
          @metadata_by_seal_id[seal_id].push @metadata_by_id[building_id]


  definition_for_id: (id) -> @metadata_by_id[id] || []
  definitions_for_seal: (seal_id) -> @metadata_by_seal_id[seal_id] || []
  load_definitions: (definitions) ->
    Vue.set(@metadata_by_id, definition.id, definition) for definition in definitions
    @notify_listeners()

  simulation_definition_for_id: (id) -> @simulations_by_id[id]
  load_simulation_definitions: (definitions) ->
    Vue.set(@simulations_by_id, definition.id, definition) for definition in definitions
    @notify_listeners()

  load_images: (images) ->
    @images_by_id[building_image.id] = building_image for building_image in images
    @notify_listeners()

  load_required_atlases: (atlases) ->
    @texture_cache.set_required_atlases(atlases)

  load_atlas: (atlas_key, atlas) ->
    @texture_cache.load_atlas(atlas_key, atlas)
    @notify_listeners()
