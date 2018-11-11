<template lang='haml'>
.content.is-marginless
  .card.planet{'v-for':'planet in planets', 'v-bind:class':"planet.enabled ? '' : 'is-disabled'"}
    .card-content
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
        .level-item.planet-item.description
          .content
            .planet-description {{planet_description(planet)}}
        .level-right
          .level-item
            %a.button.is-primary.is-medium.is-outlined.workflow-action{'v-on:click.stop.prevent':'select_planet(planet)', 'v-bind:disabled':'!planet.enabled'} Select
    .disabled-overlay
</template>

<script lang='coffee'>
import MoneyText from '~/components/misc/money-text.vue'

export default
  components:
    'money-text': MoneyText

  props:
    client: Object
    game_state: Object

  computed:
    planets: ->
      if @game_state?.common_metadata?.state_counter? && @game_state.has_planets_metadata_fresh_for_current_system()
        _.sortBy(_.values(@game_state.common_metadata.planets_metadata_by_system_id[@game_state.session_state.system_id]), (planet) -> planet.name)
      else
        []

  methods:
    select_planet: (planet) ->
      return unless planet.enabled
      if @game_state.session_state.identity.is_tycoon()
        corporation = @game_state.session_state.corporation_metadata_for_system_and_planet_id(planet.system_id, planet.id)
        if corporation?
          @client.select_corporation(corporation)
          return
      @client.select_planet_id(planet.id)

    planet_animation_url: (planet) -> "https://cdn.starpeace.io/animations/planet.#{planet.id}.animation.gif"
    planet_description: (planet) ->
      size = if planet.width < 1000 then 'Small' else if planet.width > 1000 then 'Large' else 'Average'
      seasons = if planet.temperature_baseline < 50 then 'only cold' else if planet.temperature_baseline > 50 then 'only hot' else 'average'

      planet_modifier = ''
      planet_modifier = 'desert ' if planet.moisture_baseline < 50
      planet_modifier = 'tropical ' if planet.moisture_baseline > 50 && planet.temperature_baseline > 50

      "#{size} sized #{planet_modifier}planet with #{seasons} seasons"
</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

.workflow-action
  &.button
    min-width: 7rem

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
  &.planet
    background-color: opacify(lighten($sp-primary-bg, 1%), .3)
    border: 1px solid rgba(110, 161, 146, .2)
    padding-bottom: .25rem

    &.is-disabled
      border: 1px solid rgba(8, 59, 44, .8)

      .disabled-overlay
        display: block

    &:not(:first-child)
      margin-top: .25rem

    > .card-content
      padding: 1rem

    .planet-row
      min-height: 5rem

      .planet-image
        background-size: 7.5rem
        height: 7.5rem
        width: 7.5rem

      .planet-item
        color: #fff

        &.info
          margin-left: 1rem
          justify-content: left

        &.description
          padding-left: 1rem
          margin-right: 2rem
          max-width: 14rem

        > .content
          width: 100%

        .planet-info-row
          border-bottom: 1px solid darken($sp-primary, 10%)
          padding-bottom: .25rem
          margin-bottom: .25rem

        .planet-name
          font-size: 1.5rem
          font-weight: 1000
          margin-bottom: .25rem

        .planet-value
          margin-left: .5rem
</style>
