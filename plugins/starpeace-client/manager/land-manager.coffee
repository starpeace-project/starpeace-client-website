
###
global PIXI
###

import PlanetTypeManifest from '~/plugins/starpeace-client/map/planet-type-manifest.coffee'

export default class LandManager
  constructor: (@asset_manager, @event_listener, @game_state) ->
    @land_metadata_by_planet_type = {}
    @land_atlas_by_planet_type = {}
    @land_manifest_by_planet_type = {}

    @map_id_texture = {}

  has_assets: () ->
    planet_metadata = @game_state.current_planet_metadata()
    planet_metadata?.planet_type?.length && planet_metadata?.map_id?.length &&
      @land_metadata_by_planet_type[planet_metadata.planet_type]? &&
      @land_atlas_by_planet_type[planet_metadata.planet_type]?.length &&
      @map_id_texture[planet_metadata.map_id]?

  queue_asset_load: () ->
    planet_metadata = @game_state.current_planet_metadata()
    return unless planet_metadata?.planet_type?.length

    unless planet_metadata?.planet_type?.length && @land_metadata_by_planet_type[planet_metadata.planet_type]?
      @asset_manager.queue("metadata.#{planet_metadata.planet_type}", "./land.#{planet_metadata.planet_type}.metadata.json", (resource) =>
        @land_metadata_by_planet_type[planet_metadata.planet_type] = resource.data
        @land_manifest_by_planet_type[planet_metadata.planet_type] = new PlanetTypeManifest(planet_metadata.planet_type,  resource.data.ground_definitions, resource.data.tree_definitions)
        @load_planet_atlas(planet_metadata.planet_type, resource.data.atlas)
      )

    unless planet_metadata?.map_id?.length && @map_id_texture[planet_metadata.map_id]?
      @asset_manager.queue("map.#{planet_metadata.map_id}", "./map.#{planet_metadata.map_id}.texture.bmp", (resource) =>
        @map_id_texture[planet_metadata.map_id] = resource
        @event_listener.notify_asset_listeners()
      )

  load_planet_atlas: (planet_type, atlas_paths) ->
    for path in atlas_paths
      do (path) =>
        @asset_manager.queue(path, path, (resource) =>
          @land_atlas_by_planet_type[planet_type] = [] unless @land_atlas_by_planet_type[planet_type]?
          @land_atlas_by_planet_type[planet_type].push resource
          @event_listener.notify_asset_listeners()
        )
    @asset_manager.load_queued()
