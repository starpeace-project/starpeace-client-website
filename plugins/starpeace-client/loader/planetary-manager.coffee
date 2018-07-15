
###
global PIXI
###

export default class PlanetaryManager
  constructor: (@asset_manager, @planet_type_manifest_manager, @event_listener) ->
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

    @asset_manager.queue("metadata.#{planet_type}", "./land.#{planet_type}.metadata.json", (resource) =>
      @planet_type_metadata[planet_type] = resource.data
      @planet_type_manifest_manager.set_definitions(planet_type, resource.data.ground_definitions, resource.data.tree_definitions)
      @load_planet_atlas(planet_type, resource.data.atlas)
    ) unless @planet_type_metadata[planet_type]?

    @asset_manager.queue("map.#{map_id}", "./map.#{map_id}.texture.bmp", (resource) =>
      @map_id_texture[map_id] = resource
      @event_listener.notify_asset_listeners()
    ) unless @map_id_texture[map_id]?

  load_planet_atlas: (planet_type, atlas_paths) ->
    for path in atlas_paths
      do (path) =>
        @asset_manager.queue(path, path, (resource) =>
          @planet_type_atlas[planet_type] = [] unless @planet_type_atlas[planet_type]?
          @planet_type_atlas[planet_type].push resource
          @event_listener.notify_asset_listeners()
        )
    @asset_manager.load_queued()
