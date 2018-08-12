<template lang='haml'>
%ul
  %li.planet-item{'v-for':'planet in planets_for_system()'}
    .columns.planet-column.is-mobile.is-centered.is-marginless.is-vcentered
      .column.is-narrow.is-hidden-mobile
        %img.planet-image.starpeace-logo.logo-loading{'v-bind:src':"planet_animation_url(planet)", 'v-on:load':"$event.target.classList.remove('starpeace-logo', 'logo-loading')"}

      .column.planet-info
        %h3 {{planet.name}}
        .columns
          .column.is-paddingless-mobile
            %ul
              %li
                %span Population:
                %span.planet-value {{0}}
              %li
                %span Investments:
                %span.planet-value {{0}}
              %li
                %span Tycoons:
                %span.planet-value {{0}}
              %li
                %span Online:
                %span.planet-value {{0}}

          .column.is-paddingless-mobile.planet-description {{planet_description(planet)}}

      .column.is-narrow.planet-select
        %img.planet-image.starpeace-logo.logo-loading.is-hidden-tablet{'v-bind:src':"planet_animation_url(planet)", 'v-on:load':"$event.target.classList.remove('starpeace-logo', 'logo-loading')"}
        %a.button.is-primary.is-medium.choose-system{'v-on:click.stop.prevent':'select_planet(planet.id)', href:'#'} Select
</template>

<script lang='coffee'>
export default
  props:
    event_listener: Object
    game_state: Object
    planetary_metadata_manager: Object

  methods:
    select_planet: (planet_id) ->
      planet = @planetary_metadata_manager.planet_for_id(planet_id)
      throw "unknown planet id <#{planetary_system_id}>" unless planet?

      @game_state.set_planet(planet)
      @event_listener.notify_planet_listeners()
      window.document.title = "#{@game_state.current_planet.name} - STARPEACE" if window?.document?

    planet_animation_url: (planet) -> "https://cdn.starpeace.io/planet.#{planet.id}.animation.gif"
    planet_description: (planet) ->
      size = if planet.width < 1000 then 'Small' else if planet.width > 1000 then 'Large' else 'Average'
      seasons = if planet.temperature_baseline < 50 then 'only cold' else if planet.temperature_baseline > 50 then 'only hot' else 'average'

      planet_modifier = ''
      planet_modifier = 'desert ' if planet.moisture_baseline < 50
      planet_modifier = 'tropical ' if planet.moisture_baseline > 50 && planet.temperature_baseline > 50

      "#{size} sized #{planet_modifier}planet with #{seasons} seasons"

    planets_for_system: -> @game_state?.current_planetary_system?.planets || []
</script>

<style lang='sass' scoped>
@import '~bulma/sass/utilities/_all'

.planet-image
  +mobile
    width: 20vw

  +tablet
    width: 7.5rem

  &.starpeace-logo
    +mobile
      background-size: 20vw
      height: 20vw
      width: 20vw

    +tablet
      background-size: 7.5rem
      height: 7.5rem
      width: 7.5rem

.planet-description
  border: 0
  font-size: 1rem
  vertical-align: top

  +tablet
    max-width: 10rem
    padding-left: 1.5rem

.planet-select
  max-width: 10rem
  padding-left: 1rem
  text-align: center

  +tablet
    width: 10rem

  .planet-image
    padding-bottom: 2rem

.planet-item
  background-color: opacify(lighten(#395950, 1%), .3)
  border: 1px solid rgba(110, 161, 146, .2)
  padding-bottom: .25rem

  &:not(:first-child)
    margin-top: .25rem

.planet-info
  color: #fff
  font-size: 1rem

  li
    border-bottom: 1px solid #CCC
    padding-bottom: .25rem

    &:not(:last-child)
      margin-bottom: .25rem

  .planet-value
    float: right

</style>
