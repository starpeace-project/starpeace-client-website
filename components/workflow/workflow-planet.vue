<template lang='pug'>
.content.is-marginless

  .tile.is-ancestor(v-for='planet_chunk in sorted_planet_chunks')
    .tile.is-parent.planet(v-for="planet in planet_chunk")
      article.tile.is-child.planet-row
        .columns.is-vcentered
          .column.is-narrow
            img.planet-image.starpeace-logo.logo-loading(:src="planet_animation_url(planet)", v-on:load="$event.target.classList.remove('starpeace-logo', 'logo-loading')")

          .column.planet-item.info
            .planet-name {{planet.name}}
            .planet-population.planet-info-row
              span {{translate('ui.menu.galaxy.details.population.label')}}:
              span.planet-value {{planet.population}}
            .planet-investments.planet-info-row
              span {{translate('ui.menu.galaxy.details.investments.label')}}:
              span.planet-value
                money-text(:value='planet.investment_value')
            .planet-tycoons.planet-info-row
              span {{translate('ui.menu.galaxy.details.tycoons.label')}}:
              span.planet-value {{planet.tycoon_count}}
            .planet-online.planet-info-row
              span {{translate('ui.menu.galaxy.details.online.label')}}:
              span.planet-value {{planet.online_count}}

        .columns
          .column.is-5
            a.button.is-primary.is-fullwidth.is-outlined.workflow-action.visitor-action(v-on:click.stop.prevent='select_visitor(planet)', :disabled='!planet.enabled') {{translate('identity.visitor')}} {{translate('identity.visa')}}
          .column.is-7
            template(v-if='corporations_by_planet_id[planet.id]')
              a.button.is-primary.is-fullwidth.workflow-action.corporation-action(v-on:click.stop.prevent='select_tycoon(planet)', :disabled='!planet.enabled')
                .action-text {{corporations_by_planet_id[planet.id].name}}
            template(v-else)
              a.button.is-primary.is-fullwidth.is-outlined.workflow-action.corporation-action(v-on:click.stop.prevent='select_tycoon(planet)', :disabled='!planet.enabled || !is_tycoon_in_galaxy')
                .action-text {{translate('ui.workflow.planet.form_corporation')}}

      .disabled-overlay(v-show='!planet.enabled')
        .disabled-text {{translate('ui.menu.galaxy.planet_not_available.label')}}

</template>

<script lang='coffee'>
import MoneyText from '~/components/misc/money-text.vue'

export default
  components:
    'money-text': MoneyText

  props:
    managers: Object
    client_state: Object

  computed:
    galaxy_id: -> @client_state.identity.galaxy_id
    galaxy_metadata: -> if @galaxy_id? && @client_state.core.galaxy_cache.has_galaxy_metadata(@galaxy_id) then @client_state.core.galaxy_cache.galaxy_metadata(@galaxy_id) else

    is_tycoon_in_galaxy: -> @client_state.identity?.galaxy_visa_type == 'tycoon' && @tycoon_id?.length
    tycoon_id: -> @client_state.session?.tycoon_id

    planets: ->
      return [] unless @galaxy_metadata?
      _.sortBy(@galaxy_metadata.planets_metadata || [], (planet) -> planet.name)
    sorted_planet_chunks: -> _.chunk(@planets, 3)

    corporations_by_planet_id: ->
      return [] unless @tycoon_id?.length
      _.keyBy(@client_state.core.corporation_cache.corporations_for_tycoon_id(@client_state.session.tycoon_id), 'planet_id')

  methods:
    translate: (key) -> if @managers? then @managers.translation_manager.text(key) else key

    planet_animation_url: (planet) -> "https://cdn.starpeace.io/animations/planet.#{planet.id}.animation.gif"
    planet_description: (planet) ->
      size = if planet.width < 1000 then 'Small' else if planet.width > 1000 then 'Large' else 'Average'
      seasons = if planet.temperature_baseline < 50 then 'only cold' else if planet.temperature_baseline > 50 then 'only hot' else 'average'

      planet_modifier = ''
      planet_modifier = 'desert ' if planet.moisture_baseline < 50
      planet_modifier = 'tropical ' if planet.moisture_baseline > 50 && planet.temperature_baseline > 50

      "#{size} sized #{planet_modifier}planet with #{seasons} seasons"


    select_visitor: (planet) ->
      return unless planet.enabled

      @client_state.player.planet_visa_type = 'visitor'
      @client_state.player.set_planet_id(planet.id)
      window.document.title = "#{planet.name} - STARPEACE" if window?.document?

    select_tycoon: (planet) ->
      return unless planet.enabled && @is_tycoon_in_galaxy

      @client_state.player.planet_visa_type = 'tycoon'
      @client_state.player.set_corporation_id(@corporations_by_planet_id[planet.id].id) if @corporations_by_planet_id[planet.id]?
      @client_state.player.set_planet_id(planet.id)
      window.document.title = "#{planet.name} - STARPEACE" if window?.document?

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

.workflow-action
  &.button
    min-width: 7rem

.disabled-overlay
  background-color: #000
  border: 1px solid rgba(8, 59, 44, .8)
  cursor: not-allowed
  height: calc(100% + 2px)
  left: -1px
  opacity: .85
  position: absolute
  text-align: center
  top: -1px
  width: calc(100% + 2px)

  .disabled-text
    color: #ddd
    font-size: 1.25rem
    font-style: italic
    left: calc(50% - 10rem)
    position: absolute
    top: calc(50% - 1rem)
    width: 20rem

.tile
  &.planet
    background-color: opacify(lighten($sp-primary-bg, 1%), .3)
    border: 1px solid rgba(110, 161, 146, .2)
    padding: 0
    position: relative

    .columns
      margin: 0

    .planet-row
      .planet-image
        background-size: 7.5rem
        height: 7.5rem
        width: 7.5rem

      .planet-item
        color: #fff

        &.description
          padding-left: 1rem
          margin-right: 2rem
          max-width: 14rem

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

  .action-text
    overflow: hidden
    text-overflow: ellipsis
    white-space: nowrap

</style>
