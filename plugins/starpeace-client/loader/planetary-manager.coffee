
###
global PIXI
###

class PlanetaryManager
  constructor: (@client) ->
    @planet_type_metadata = {}
    @planet_type_atlas = {}
    @map_id_texture = {}

  has_assets: (planet) ->
    planet?.planet_type?.length && planet?.map_id?.length &&
      @planet_type_metadata[planet.planet_type]? &&
      @planet_type_atlas[planet.planet_type]?.length &&
      @map_id_texture[planet.map_id]?

  queue_asset_load: (planet_type, map_id) ->
    return unless planet_type?.length

    @client.asset_manager.queue("metadata.#{planet_type}", "./land.#{planet_type}.metadata.json", (resource) =>
      @planet_type_metadata[planet_type] = resource.data
      @client.planet_type_manifest_manager.set_definitions(planet_type, resource.data.ground_definitions, resource.data.tree_definitions)
      @load_planet_atlas(planet_type, resource.data.atlas)
    ) unless @planet_type_metadata[planet_type]?

    @client.asset_manager.queue("map.#{map_id}", "./map.#{map_id}.texture.bmp", (resource) =>
      @map_id_texture[map_id] = resource
      @client.notify_assets_changed()
    ) unless @map_id_texture[map_id]?

  load_planet_atlas: (planet_type, atlas_paths) ->
    for path in atlas_paths
      do (path) =>
        @client.asset_manager.queue(path, path, (resource) =>
          @planet_type_atlas[planet_type] = [] unless @planet_type_atlas[planet_type]?
          @planet_type_atlas[planet_type].push resource
          @client.notify_assets_changed()
        )
    @client.asset_manager.load_queued()

export default PlanetaryManager
