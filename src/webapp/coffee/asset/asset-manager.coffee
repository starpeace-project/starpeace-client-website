

window.starpeace ||= {}
window.starpeace.asset ||= {}
window.starpeace.asset.AssetManager = class AssetManager

  constructor: (@client) ->
    @planet_type_metadata = {}
    @planet_type_atlas = {}
    @map_id_texture = {}

    PIXI.loader.baseUrl = "https://cdn.starpeace.io"
    PIXI.loader.onProgress.add (e) =>
      @loading_progress = e.progress

    @reload = false

  set_planet_metadata: (planet_type, resource) ->
    @client.ui_state.vue_application.$set(@client.ui_state.vue_application.asset_manager.planet_type_metadata, planet_type, resource.data)
    @client.planet_type_manifest_manager.set_definitions(planet_type, resource.data.ground_definitions, resource.data.tree_definitions)
    @load_planet_atlas(planet_type, resource.data.atlas)

  set_map_texture: (map_id, resource) ->
    @client.ui_state.vue_application.$set(@client.ui_state.vue_application.asset_manager.map_id_texture, map_id, resource)

  load_planet_assets: (planet_type, map_id) ->
    return unless planet_type?.length

    PIXI.loader.add "metadata.#{planet_type}", "./land.#{planet_type}.metadata.json" unless @planet_type_metadata[planet_type]?
    PIXI.loader.add "map.#{map_id}", "./map.#{map_id}.texture.bmp" unless @map_id_texture[map_id]?

    PIXI.loader.load (loader, resources) =>
      @set_planet_metadata(planet_type, resources["metadata.#{planet_type}"]) unless @planet_type_metadata[planet_type]?
      @set_map_texture(map_id, resources["map.#{map_id}"]) unless @map_id_texture[map_id]?
      @client.notify_assets_changed()


  set_planet_atlas: (planet_type, resource) ->
    unless @planet_type_atlas[planet_type]?
      @client.ui_state.vue_application.$set(@client.ui_state.vue_application.asset_manager.planet_type_atlas, planet_type, [])
    @client.ui_state.vue_application.asset_manager.planet_type_atlas[planet_type].push resource
    @client.notify_assets_changed()

  load_planet_atlas: (planet_type, atlas_paths) ->
    PIXI.loader.add path for path in atlas_paths
    PIXI.loader.load (loader, resources, e) =>
      @set_planet_atlas(planet_type, resources[path]) for path in atlas_paths

