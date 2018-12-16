<template lang='haml'>
#systems-container.card.is-starpeace.has-header
  .card-header
    .card-header-title
      Planetary Systems
    .card-header-icon.card-close{'v-on:click.stop.prevent':"client_state.menu.toggle_menu('systems')"}
      %font-awesome-icon{':icon':"['fas', 'times']"}
  .card-content.sp-menu-background.overall-container
    .content.sp-scrollbar
      %template{'v-if':'is_system_loading'}
        %img.loading-image.starpeace-logo.logo-loading
      %template{'v-else-if':'true'}
        %template{'v-for':'system in systems()', 'v-bind:disabled':'!system.enabled'}
          .card.system{'v-bind:class':"system.enabled ? '' : 'is-disabled'"}
            .card-content
              %a{'v-on:click.stop.prevent':'select_system(system)', 'v-bind:disabled':'!system.enabled'}
                .level.is-mobile.system-row
                  .level-left
                    .level-item
                      %img.system-image.starpeace-logo.logo-loading{'v-bind:src':"system_animation_url(system)", 'v-on:load':"$event.target.classList.remove('logo-loading')"}
                  .level-item.system-item.info
                    .content
                      .system-name {{system.name}}
                      .system-population.system-info-row
                        %span Population:
                        %span.planet-value {{system.population}}
                      .system-planets.system-info-row
                        %span Planets:
                        %span.planet-value {{system.planets_metadata.length}}
                      .system-online.system-info-row
                        %span Online:
                        %span.planet-value {{system.online_count}}
            .disabled-overlay
          %template{'v-if':"system.id == selected_system_id"}
            .card.planet{'v-for':'planet in planets()', 'v-bind:disabled':'!planet.enabled', 'v-bind:class':"planet.enabled ? '' : 'is-disabled'"}
              .card-content
                %a{'v-on:click.stop.prevent':'select_planet(planet)', 'v-bind:disabled':'!planet.enabled'}
                  .level.is-mobile.planet-row
                    .level-left
                      .level-item
                        %img.planet-image.starpeace-logo.logo-loading{'v-bind:src':"planet_animation_url(planet)", 'v-on:load':"$event.target.classList.remove('starpeace-logo', 'logo-loading')"}
                    .level-item.planet-item.info
                      .content
                        .planet-name {{planet.name}}
                        .planet-population.planet-info-row
                          %span Population:
                          %span.planet-value {{planet.population}}
                        .planet-investments.planet-info-row
                          %span Investments:
                          %span.planet-value
                            %money-text{'v-bind:value':'planet.investment_value'}
                        .planet-tycoons.planet-info-row
                          %span Tycoons:
                          %span.planet-value {{planet.tycoon_count}}
                        .planet-online.planet-info-row
                          %span Online:
                          %span.planet-value {{planet.online_count}}
              .disabled-overlay

</template>

<script lang='coffee'>
import MoneyText from '~/components/misc/money-text.vue'

export default
  components:
    'money-text': MoneyText

  props:
    client_state: Object
    ajax_state: Object
    managers: Object

  mounted: ->
    @client_state?.menu?.subscribe_menu_listener =>
      @menu_visible = @client_state?.menu?.is_visible('systems')

  watch:
    is_visible: (new_value, old_value) ->
      @managers.systems_manager.load_metadata() unless !@is_visible || @client_state.core.systems_cache.has_systems_metadata_fresh()

  data: ->
    menu_visible: @client_state?.menu?.is_visible('systems')

  computed:
    is_visible: -> if @client_state?.initialized then @menu_visible else false
    is_system_loading: -> @is_visible && @ajax_state?.is_locked('systems_metadata', 'ALL')

    selected_system_id: -> @client_state?.interface?.systems_menu_selected_system_id

  methods:
    format_money: (value) ->

    system_animation_url: (system) -> ''
    planet_animation_url: (planet) -> "https://cdn.starpeace.io/animations/planet.#{planet.id}.animation.gif"

    systems: ->
      if @client_state.initialized && @client_state.core.systems_cache.has_systems_metadata_any()
        _.sortBy(@client_state.core.systems_cache.all_systems(), (system) -> system.name)
      else
        []

    planets: ->
      if @client_state.initialized && @selected_system_id? && @client_state.core.systems_cache.system_exists(@selected_system_id)
        _.sortBy(@client_state.core.systems_cache.metadata_for_id(@selected_system_id)?.planets_metadata || [], (planet) -> planet.name)
      else
        []

    select_system: (system) ->
      return unless system.enabled
      if @selected_system_id == system.id
        @client_state.interface.systems_menu_selected_system_id = null
      else
        @client_state.interface.systems_menu_selected_system_id = system.id

    select_planet: (planet) ->
      return if !planet.enabled
      @client_state.menu.toggle_menu('systems')
      @client_state.interface.systems_menu_selected_system_id = null
      @client_state.change_planet_id(planet.id) unless @client_state.player.planet_id == planet.id

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

#systems-container
  grid-column-start: 1
  grid-column-end: 4
  grid-row-start: 2
  grid-row-end: 4
  margin: 0
  max-width: 25rem
  overflow: hidden
  position: absolute
  width: 100%
  z-index: 1100

.loading-image
  background-size: 5rem
  height: 5rem
  margin: 1rem 0
  width: 5rem

.disabled-overlay
  background-color: #000
  cursor: not-allowed
  display: none
  height: 100%
  left: 0
  opacity: .5
  position: absolute
  top: 0
  width: 100%

.card
  &#systems-container
    height: 100%

  .card-content
    &.overall-container
      height: calc(100% - 3.2rem)
      padding: 0
      position: relative

  .content
    &.sp-scrollbar
      height: 100%
      width: 100%
      overflow-x: hidden
      overflow-y: scroll
      position: relative
      text-align: center

  a
    &[disabled]
      cursor: not-allowed

  &.system
    background-color: opacify(lighten($sp-primary-bg, 2%), .3)
    border: 1px solid rgba(110, 161, 146, .2)
    margin-top: .25rem

    &.is-disabled
      border: 1px solid rgba(8, 59, 44, .8)

      .disabled-overlay
        display: block

    .card-content
      padding: .5rem
      padding-left: 1rem

    .system-image
      background-size: 5rem
      height: 5rem
      width: 5rem

    .system-item
      color: #ddd

      &.info
        font-size: .9rem
        justify-content: left
        margin-left: 1rem
        text-align: left

      > .content
        width: 100%

      .system-info-row
        border-bottom: 1px solid darken($sp-primary, 10%)
        padding-bottom: .25rem
        margin-bottom: .25rem

      .system-name
        font-size: 1.3rem
        font-weight: 1000
        margin-bottom: .25rem

      .planet-value
        margin-left: .5rem

  &.planet
    background-color: opacify(lighten($sp-primary-bg, 1%), .3)
    border: 1px solid rgba(110, 161, 146, .2)
    margin-top: .25rem
    padding-bottom: .25rem

    &.is-disabled
      border: 1px solid rgba(8, 59, 44, .8)

      .disabled-overlay
        display: block

    .card-content
      padding: .5rem
      padding-left: 1rem

    .planet-row
      min-height: 5rem

      .planet-image
        background-size: 5rem
        height: 5rem
        width: 5rem

      .planet-item
        color: #ddd

        &.info
          font-size: .9rem
          justify-content: left
          margin-left: 1rem
          text-align: left

        > .content
          width: 100%

        .planet-info-row
          border-bottom: 1px solid darken($sp-primary, 10%)
          padding-bottom: .25rem
          margin-bottom: .25rem

        .planet-name
          font-size: 1.3rem
          font-weight: 1000
          margin-bottom: .25rem

        .planet-value
          margin-left: .5rem

</style>
