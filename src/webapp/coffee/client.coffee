

window.starpeace ||= {}
window.starpeace.Client = class Client

  constructor: () ->
    @identity = starpeace.identity.Identity.from_local_storage()
    @account = null

    @planetary_system = null
    @planet = null

    @metadata_manager = new starpeace.metadata.MetadataManager(@)
    @asset_manager = new starpeace.asset.AssetManager(@)

    @game_state = new starpeace.GameState(@)
    @ui_state = new starpeace.UIState(@)

    @renderer = new starpeace.renderer.Renderer()

    # FIXME: TODO: consider loading state from url parameters (planet_id)


  status: () ->
    return 'pending_identity' unless @identity?
    return 'pending_identity_authentication' unless @identity?.is_authenticated()
    return 'pending_account' unless @account?
    return 'pending_account_registration' unless @account?.is_registered()

    return 'pending_planetary_metadata' unless @metadata_manager?.has_planetary_metadata()
    return 'pending_planetary_system' unless @planetary_system?
    return 'pending_planet' unless @planet?

    return 'pending_assets' unless @asset_manager.is_loaded()
    return 'pending_initialization' unless @game_state.is_initialized()

    'ready'


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
    system = @metadata_manager.planetary_system_for_id(planetary_system_id)
    throw "unknown planetary system id <#{planetary_system_id}>" unless system?
    @planetary_system = system
    console.debug "[starpeace] proceeding with planetary system <#{@planetary_system}>"
  reset_planetary_system: () ->
    @planetary_system = null
    @planet = null
    # FIXME: TODO: what other state should be reset?
    console.debug "[starpeace] resetting planetary system back to empty, will need to re-select"

  select_planet: (planet_id) ->
    planet = @metadata_manager.planet_for_id(planet_id)
    throw "unknown planet id <#{planetary_system_id}>" unless planet?
    @planet = planet
    console.debug "[starpeace] proceeding with planet <#{@planet}>"

  tick: () ->

  