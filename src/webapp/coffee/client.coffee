

window.starpeace ||= {}
window.starpeace.Client = class Client

  constructor: () ->
    @identity = starpeace.identity.Identity.from_local_storage()
    @account = null

    @planetary_system = null
    @planet = null

    @planetary_metadata_manager = new starpeace.metadata.PlanetaryMetadataManager(@)
    @planet_type_manifest_manager = new starpeace.metadata.PlanetTypeManifestManager(@)

    @asset_manager = new starpeace.asset.AssetManager(@)

    @game_state = new starpeace.state.GameState(@)

    @renderer = new starpeace.renderer.Renderer(@)
    @camera_manager = new starpeace.renderer.CameraManager(@, @renderer)
    @input_handler = new starpeace.renderer.InputHandler(@camera_manager, @renderer)

    @ui_manager = new starpeace.UIManager(@)

    @reload = false

    # FIXME: TODO: consider loading state from url parameters (planet_id)

  land_manifest_for_planet: () ->
    @planet_type_manifest_manager.planet_type_manifest[@planet.planet_type]

  proceed_as_visitor: () ->
    @identity.reset_and_destroy() if @identity?
    @identity = starpeace.identity.Identity.visitor()
    console.debug "[starpeace] proceeding with visitor identity <#{@identity}>"

    starpeace.account.Account.for_identity(@identity)
      .then (account) =>
        @account = account
        console.debug "[starpeace] successfully retrieved account <#{@account}> for identity"

      .catch (error) ->
        # FIXME: TODO: figure out error handling

  select_planetary_system: (planetary_system_id) ->
    system = @planetary_metadata_manager.planetary_system_for_id(planetary_system_id)
    throw "unknown planetary system id <#{planetary_system_id}>" unless system?
    @planetary_system = system
    document.title = "#{@planetary_system.name} - STARPEACE" if document?
    console.debug "[starpeace] proceeding with planetary system <#{@planetary_system}>"

  reset_planetary_system: () ->
    document.title = "STARPEACE" if document?
    @planetary_system = null
    @planet = null
    @game_state.initialized = false
    # FIXME: TODO: what other state should be reset?
    console.debug "[starpeace] resetting planetary system back to empty, will need to re-select"

  select_planet: (planet_id) ->
    planet = @planetary_metadata_manager.planet_for_id(planet_id)
    throw "unknown planet id <#{planetary_system_id}>" unless planet?
    @planet = planet
    document.title = "#{@planet.name} - STARPEACE" if document?
    console.debug "[starpeace] proceeding with planet <#{@planet}>"
    @asset_manager.load_planet_assets(@planet.planet_type, @planet.map_id)


  notify_assets_changed: () ->
    return unless @ui_manager.vue_application.has_planet_assets
    @renderer.initialize()
    @input_handler.initialize()

  tick: () ->
    @renderer.tick() if @renderer.initialized
  