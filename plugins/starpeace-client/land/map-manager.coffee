
export default class MapManager
  constructor: (@asset_manager, @ajax_state, @client_state) ->

  queue_asset_load: () ->
    planet_metadata = @client_state.current_planet_metadata()
    return if !planet_metadata? || @client_state.core.map_library.has_assets(planet_metadata.map_id) || @ajax_state.is_locked('assets.map_texture', planet_metadata.map_id)

    @ajax_state.lock('assets.map_texture', planet_metadata.map_id)
    @asset_manager.queue("map.#{planet_metadata.map_id}", "./map.#{planet_metadata.map_id}.texture.bmp", (resource) =>
      @client_state.core.map_library.load_map_texture(planet_metadata.map_id, resource)

      @ajax_state.unlock('assets.map_texture', planet_metadata.map_id)
    )
