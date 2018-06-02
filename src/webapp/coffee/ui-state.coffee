###
* helper class to provide abstraction for vue ui layer
###

window.starpeace ||= {}
window.starpeace.UIState = class UIState

  constructor: (@client) ->
    @vue_application = new Vue({
      el: '#application'
      data: {
        client: @client
        game_state: @client.game_state
        ui_state: @
      }
      computed: {
        is_visitor: () -> @client.identity?.is_visitor()

        status: () -> @client.status()
        is_loading: () -> @game_state.is_loading()
        is_ready: () -> @status == 'ready'

        loading_has_subprogress: () -> false # FIXME: TODO: might be useful with asset loading

        planetary_systems: () -> @client.metadata_manager.planetary_systems()
        planetary_system: () -> @client.planetary_system
        planetary_system_name: () -> @planetary_system?.name
        planets_for_system: () -> @planetary_system?.planets || []
        planet: () -> @client.planet
        planet_name: () -> @planet?.name
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
      }
    })


