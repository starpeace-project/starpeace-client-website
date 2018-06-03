

window.starpeace ||= {}
window.starpeace.Client = class Client

  constructor: () ->
    @identity = starpeace.identity.Identity.from_local_storage()
    @account = null

    @planetary_system = null
    @planet = null

    @planetary_metadata_manager = new starpeace.metadata.PlanetaryMetadataManager(@)
    @land_metadata_manager = new starpeace.metadata.LandMetadataManager(@)

    @asset_manager = new starpeace.asset.AssetManager(@)

    @game_state = new starpeace.GameState(@)
    @ui_state = new starpeace.UIState(@)

    @renderer = new starpeace.renderer.Renderer(@)

    @reload = false

    # FIXME: TODO: consider loading state from url parameters (planet_id)

  land_metadata_for_planet_by_color: () ->
    @land_metadata_manager.planet_type_metadata_by_color[@planet.planet_type] || {}


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
    console.debug "[starpeace] proceeding with planetary system <#{@planetary_system}>"

  reset_planetary_system: () ->
    @planetary_system = null
    @planet = null
    @game_state.initialized = false
    # FIXME: TODO: what other state should be reset?
    console.debug "[starpeace] resetting planetary system back to empty, will need to re-select"

  select_planet: (planet_id) ->
    planet = @planetary_metadata_manager.planet_for_id(planet_id)
    throw "unknown planet id <#{planetary_system_id}>" unless planet?
    @planet = planet
    console.debug "[starpeace] proceeding with planet <#{@planet}>"
    @asset_manager.load_planet_assets(@planet.planet_type, @planet.map_id)


  notify_assets_changed: () ->
    return unless @ui_state.vue_application.has_planet_assets
    @renderer.initialize()

  tick: () ->

  