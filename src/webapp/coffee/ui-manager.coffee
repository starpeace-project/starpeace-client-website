###
* helper class to provide abstraction for vue ui layer
###

window.starpeace ||= {}
window.starpeace.UIManager = class UIManager

  constructor: (@client) ->
    @vue_application = new Vue({
      el: '#application'
      data: {
        client: @client

        game_state: @client.game_state
        ui_state: @client.ui_state

        planetary_metadata_manager: @client.planetary_metadata_manager
        asset_manager: @client.asset_manager
        camera_manager: @client.camera_manager
      }
#       watch: {
#         ui_state: () ->
#           console.log "ui_state changed"
#       }
      computed: {
        is_visitor: () -> @client.identity?.is_visitor()

        has_planet_assets: () ->
          @client.planet?.planet_type?.length &&
            @asset_manager.planet_type_metadata[@client.planet.planet_type]? &&
            @asset_manager.planet_type_atlas[@client.planet.planet_type]?.length &&
            @asset_manager.map_id_texture[@client.planet.map_id]?

        status: () ->
          return 'pending_identity' unless @client.identity?
          return 'pending_identity_authentication' unless @client.identity?.is_authenticated()
          return 'pending_account' unless @client.account?
          return 'pending_account_registration' unless @client.account?.is_registered()

          return 'pending_planetary_metadata' unless @planetary_metadata_manager?.has_planetary_metadata()
          return 'pending_planetary_system' unless @client.planetary_system?
          return 'pending_planet' unless @client.planet?

          return 'pending_assets' unless @has_planet_assets
          return 'pending_initialization' unless @game_state.initialized

          'ready'

        is_loading: () -> @game_state.loading
        is_ready: () -> @status == 'ready'

        loading_has_subprogress: () -> false # FIXME: TODO: might be useful with asset loading

        planetary_systems: () -> @planetary_metadata_manager.planetary_systems()
        planetary_system: () -> @client.planetary_system
        planetary_system_name: () -> @planetary_system?.name
        planets_for_system: () -> @planetary_system?.planets || []
        planet: () -> @client.planet
        planet_name: () -> @planet?.name

        current_date: () -> moment(@client.game_state.current_date).format('MMM D, YYYY')
      }
      methods: {
        system_animation_url: (system) -> ''
        planet_animation_url: (planet) -> "https://cdn.starpeace.io/planet.#{planet.id}.animation.gif"
        planet_description: (planet) ->
          size = if planet.width < 1000 then 'Small' else if planet.width > 1000 then 'Large' else 'Average'
          seasons = if planet.temperature_baseline < 50 then 'only cold' else if planet.temperature_baseline > 50 then 'only hot' else 'average'

          planet_modifier = ''
          planet_modifier = 'desert ' if planet.moisture_baseline < 50
          planet_modifier = 'tropical ' if planet.moisture_baseline > 50 && planet.temperature_baseline > 50

          "#{size} sized #{planet_modifier}planet with #{seasons} seasons"

        toggle_header: () ->
          @ui_state.show_header = !@ui_state.show_header
        toggle_fps: () ->
          @ui_state.show_fps = !@ui_state.show_fps

        hide_all_menus: () ->
          @ui_state.show_menu_favorites = false
          @ui_state.main_menu = null
        toggle_menu_planetary: () ->
          @ui_state.main_menu = if @ui_state.main_menu == 'planetary' then null else 'planetary'
          @ui_state.show_menu_favorites = false
        toggle_menu_favorites: () ->
          @ui_state.show_menu_favorites = !@ui_state.show_menu_favorites
        toggle_menu_tycoon: () ->
          @ui_state.main_menu = if @ui_state.main_menu == 'tycoon' then null else 'tycoon'
        toggle_menu_building: () ->
          @ui_state.main_menu = if @ui_state.main_menu == 'building' then null else 'building'
        toggle_menu_mail: () ->
          @ui_state.main_menu = if @ui_state.main_menu == 'mail' then null else 'mail'
        toggle_menu_chat: () ->
          @ui_state.main_menu = if @ui_state.main_menu == 'chat' then null else 'chat'
        toggle_menu_options: () ->
          @ui_state.main_menu = if @ui_state.main_menu == 'options' then null else 'options'
        toggle_menu_help: () ->
          @ui_state.main_menu = if @ui_state.main_menu == 'help' then null else 'help'

      }
    })

