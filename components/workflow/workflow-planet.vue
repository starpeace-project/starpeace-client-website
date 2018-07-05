<template lang='haml'>
.columns
  .column
    %ul
      %li.planet-item{'v-for':'planet in planets_for_system()'}
        %table.table.planet-table
          %tbody
            %tr
              %td.planet-image{rowspan:5}
                %img.planet-image.starpeace-logo.logo-loading{'v-bind:src':"planet_animation_url(planet)", 'v-on:load':"$event.target.classList.remove('starpeace-logo', 'logo-loading')"}
              %td{colspan:3}
                %h3 {{planet.name}}
              %td.planet-select{rowspan:5}
                %a.button.is-primary.is-medium.choose-system{'v-on:click.stop.prevent':'select_planet(planet.id)', href:'#'} Select
            %tr.planet-info-row
              %td Population:
              %td.planet-value {{0}}
              %td.planet-description{rowspan:4} {{planet_description(planet)}}
            %tr.planet-info-row
              %td Investments:
              %td.planet-value ${{0}}
            %tr.planet-info-row
              %td Tycoons:
              %td.planet-value {{0}}
            %tr.planet-info-row
              %td Online:
              %td.planet-value {{0}}
</template>

<script lang='coffee'>
export default
  props:
    client: Object

  computed:
    game_state: -> @client.game_state

  methods:
    select_planet: (planet_id) ->
      planet = @client.planetary_metadata_manager.planet_for_id(planet_id)
      throw "unknown planet id <#{planetary_system_id}>" unless planet?
      @client.select_planet(planet)
      window.document.title = "#{@client.game_state.current_planet.name} - STARPEACE" if window?.document?

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
.columns
  margin: 0

  .column
    padding: 0

.planet-item
  background-color: opacify(lighten(#395950, 1%), .3)
  border: 1px solid rgba(110, 161, 146, .2)
  padding-bottom: .25rem

  &:not(:first-child)
    margin-top: .25rem

.planet-table
  background-color: transparent
  color: #fff
  margin: 0
  width: 100%

  tr
    &:first-child
      td
        border: 0

    &.planet-info-row
      font-size: 1rem

  td
    padding: .25rem
    vertical-align: middle

    &.planet-image
      padding: .5rem 1.5rem 0 1rem
      text-align: center
      width: 10rem

      .starpeace-logo
        background-size: 7.5rem
        height: 7.5rem
        width: 7.5rem

  .planet-value
    text-align: right

  .planet-description
    border: 0
    max-width: 10rem
    font-size: 1rem
    padding-left: 1.5rem
    vertical-align: top

  .planet-select
    max-width: 10rem
    padding-left: 1rem
    text-align: center
    width: 10rem
</style>
