<template lang='pug'>
#galaxy-container.card.is-starpeace.has-header(oncontextmenu='return false')
  .card-header
    .card-header-title {{translate('ui.menu.galaxy.header')}}
    .card-header-icon.card-close(v-on:click.stop.prevent="client_state.menu.toggle_menu('galaxy')")
      font-awesome-icon(:icon="['fas', 'times']")

  .card-content.sp-menu-background.overall-container
    aside.sp-scrollbar
      template(v-if='is_loading')
        img.loading-image.starpeace-logo.logo-loading

      template(v-else-if='!is_loading')
        .planet(v-for='planet in planets', :disabled='!planet.enabled', :class="planet.enabled ? '' : 'is-disabled'")
          .columns.is-vcentered
            .column.is-narrow.planet-image
              img.starpeace-logo.logo-loading(:src="planet_animation_url(planet)", v-on:load="$event.target.classList.remove('starpeace-logo', 'logo-loading')")

            .column.planet-item
              .planet-name {{planet.name}}
              .planet-population.planet-info-row
                span {{translate('ui.menu.galaxy.details.population.label')}}:
                span.planet-value {{planet.population}}
              .planet-investments.planet-info-row
                span {{translate('ui.menu.galaxy.details.investments.label')}}:
                span.planet-value
                  misc-money-text(:value='planet.investment_value')
              .planet-tycoons.planet-info-row
                span {{translate('ui.menu.galaxy.details.corporations.label')}}:
                span.planet-value {{planet.corporation_count}}
              .planet-online.planet-info-row
                span {{translate('ui.menu.galaxy.details.online.label')}}:
                span.planet-value {{planet.online_count}}

          .columns
            .column.is-5
              button.button.is-primary.is-fullwidth.is-outlined.workflow-action.visitor-action(v-on:click.stop.prevent='select_visitor(planet)', :disabled='!planet.enabled') {{translate('identity.visitor')}} {{translate('identity.visa')}}
            .column.is-7
              template(v-if='corporations_by_planet_id[planet.id]')
                button.button.is-primary.is-fullwidth.workflow-action.corporation-action(v-on:click.stop.prevent='select_tycoon(planet)', :disabled='!planet.enabled')
                  .action-text {{corporations_by_planet_id[planet.id].name}}
              template(v-else)
                button.button.is-primary.is-fullwidth.is-outlined.workflow-action.corporation-action(v-on:click.stop.prevent='select_tycoon(planet)', :disabled='!planet.enabled || !is_tycoon_in_galaxy')
                  .action-text {{translate('ui.menu.corporation.establish.action.establish')}}

          .disabled-overlay(v-show='!planet.enabled')
            .disabled-text {{translate('ui.menu.galaxy.planet_not_available.label')}}

</template>

<script lang='coffee'>
import _ from 'lodash';

export default
  props:
    client_state: Object
    ajax_state: Object
    managers: Object

  mounted: ->
    @client_state?.menu?.subscribe_menu_listener =>
      @menu_visible = @client_state?.menu?.is_visible('galaxy')

  watch:
    is_visible: (new_value, old_value) ->
      @managers.galaxy_manager.load_metadata(@galaxy_id) if @is_visible && !@is_loading && @galaxy_id?.length

  data: ->
    menu_visible: @client_state?.menu?.is_visible('galaxy')

  computed:
    is_visible: -> if @client_state?.initialized then @menu_visible else false
    is_loading: -> if @galaxy_id?.length then @ajax_state?.is_locked('galaxy_metadata', @galaxy_id) else true

    galaxy_id: -> @client_state.identity.galaxy_id
    galaxy_metadata: -> if @galaxy_id? && @client_state.core.galaxy_cache.has_galaxy_metadata(@galaxy_id) then @client_state.core.galaxy_cache.galaxy_metadata(@galaxy_id) else

    is_tycoon_in_galaxy: -> @client_state.identity?.galaxy_visa_type == 'tycoon' && @tycoon_id?.length
    tycoon_id: -> @client_state.identity?.galaxy_tycoon?.id

    planets: ->
      return [] unless @galaxy_metadata? && @is_visible
      _.sortBy(@galaxy_metadata.planets || [], (planet) -> planet.name)
    sorted_planet_chunks: -> _.chunk(@planets, 3)

    corporations_by_planet_id: ->
      return [] unless @tycoon_id?.length
      _.keyBy(@client_state.core.corporation_cache.corporations_for_tycoon_id(@tycoon_id), 'planet_id')

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    format_money: (value) -> value

    planet_animation_url: (planet) -> @managers.asset_manager.planet_animation_url(planet)


    select_visitor: (planet) ->
      return unless planet.enabled
      @client_state.change_planet_id('visitor', planet.id)
      window.document.title = "#{planet.name} - STARPEACE" if window?.document?

    select_tycoon: (planet) ->
      return unless planet.enabled && @is_tycoon_in_galaxy
      @client_state.change_planet_id('tycoon', planet.id)
      window.document.title = "#{planet.name} - STARPEACE" if window?.document?

</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

#galaxy-container
  grid-column: 1 / 4
  grid-row: start-render / end-render
  margin: 0
  max-width: 25rem
  overflow: hidden
  position: relative
  width: 100%
  z-index: 1100

  .overall-container
    height: calc(100% - 3.2rem)
    padding: 0
    position: relative

    .sp-scrollbar
      height: 100%
      overflow-x: hidden
      overflow-y: scroll

.loading-image
  background-size: 5rem
  height: 5rem
  left: calc(50% - 2.5rem)
  margin: 1rem 0
  position: absolute
  top: calc(25% - 2.5rem)
  width: 5rem

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

.planet
  background-color: opacify(lighten($sp-primary-bg, 1%), .3)
  border: 1px solid rgba(110, 161, 146, .2)
  margin-top: .25rem
  padding-bottom: .25rem
  position: relative

  > .columns
    margin: 0

  .planet-image
    padding-right: .4rem

    img
      background-size: 5rem
      height: 5rem
      width: 5rem

  .planet-item
    color: #fff
    font-size: .9rem
    justify-content: left
    padding-left: .4rem
    text-align: left

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
