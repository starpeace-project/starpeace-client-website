
import MetadataLand from '~/plugins/starpeace-client/land/metadata-land.coffee'

export default class LandManager
  constructor: (@asset_manager, @ajax_state, @client_state) ->

  queue_asset_load: () ->
    planet_metadata = @client_state.current_planet_metadata()
    return if !planet_metadata? || @client_state.core.land_library.has_assets(planet_metadata.planet_type) || @ajax_state.is_locked('assets.land_metadata', planet_metadata.planet_type)

    @ajax_state.lock('assets.land_metadata', planet_metadata.planet_type)
    @asset_manager.queue("metadata.#{planet_metadata.planet_type}", "./land.#{planet_metadata.planet_type}.metadata.json", (resource) =>
      metadata = MetadataLand.from_json(resource.data)

      @client_state.core.land_library.load_land_metadata(metadata)
      @client_state.core.land_library.load_required_atlases(metadata.planet_type, resource.data?.atlas)

      @asset_manager.queue_and_load_atlases((resource.data?.atlas || []), (atlas_path, atlas) => @client_state.core.land_library.load_atlas(planet_metadata.planet_type, atlas_path, atlas))
      @ajax_state.unlock('assets.land_metadata', planet_metadata.planet_type)
    )
