<template lang='pug'>
.universe-multiverse-actions
  .galaxy-list.sp-scrollbar

    template(v-for="galaxy in galaxies")
      .columns.is-vcentered.galaxy-row
        .column.is-5
          h3.galaxy-name(:class="galaxy_name_is_long(galaxy) ? 'is-smaller' : ''")
            .galaxy-name-text {{galaxy_name(galaxy)}}
        .column.is-2
          .content
            .galaxy-planets
              span {{translate('ui.menu.galaxy.details.planets.label')}}:
              span.planet-value {{planet_count(galaxy)}}
            .galaxy-online
              span {{translate('ui.menu.galaxy.details.online.label')}}:
              span.planet-value {{online_count(galaxy)}}

        .column.is-5.has-text-right.galaxy-actions
          a.button.is-medium.is-starpeace.is-inverted.is-outlined(v-on:click.stop.prevent="proceed_as_visitor(galaxy.id)", :disabled='!visitor_enabled(galaxy)') {{translate('identity.visitor')}}
          a.button.is-medium.is-starpeace.is-inverted(v-on:click.stop.prevent="proceed_as_tycoon(galaxy.id)", :disabled='!tycoon_enabled(galaxy)') {{translate('identity.tycoon')}}

        .galaxy-loading-modal(v-show='is_galaxy_loading(galaxy.id) || is_galaxy_error(galaxy.id)')
          img.starpeace-logo(v-show='is_galaxy_loading(galaxy.id)')
          .galaxy-error-message(v-show='is_galaxy_error(galaxy.id)')
            | {{translate('misc.unable_to_connect.label')}}
            a(v-on:click.stop.prevent='refresh_galaxy(galaxy.id)') {{translate('misc.try_again.label')}}

  .level.galaxy-actions-level
    .level-left
      .level-item
        a.button.is-small.is-starpeace(v-on:click.stop.prevent='toggle_remove_galaxy', :disabled='!galaxies.length') {{translate('ui.workflow.universe.galaxy.remove.label')}}
    .level-right
      .level-item
        a.button.is-small.is-starpeace(v-on:click.stop.prevent='toggle_add_galaxy') {{translate('ui.workflow.universe.galaxy.add.label')}}

</template>

<script lang='coffee'>
import Vue from 'vue'

export default
  props:
    managers: Object
    ajax_state: Object
    client_state: Object

  data: ->
    show_remove_galaxy: false
    show_add_galaxy: false

    galaxies: []
    galaxy_errors: {}

  computed:
    is_visible: -> @client_state.workflow_status == 'pending_universe'

  mounted: ->
    @galaxies = @client_state.options.get_galaxies()

    @client_state.options.subscribe_galaxies_listener =>
      @galaxies = @client_state.options.get_galaxies()
    @client_state.core.galaxy_cache.subscribe_configuration_listener =>
      @$forceUpdate() if @is_visible
    @client_state.core.galaxy_cache.subscribe_metadata_listener =>
      @$forceUpdate() if @is_visible

  watch:
    is_visible: (new_value, old_value) ->
      @galaxies = @client_state.options.get_galaxies() if @is_visible

    galaxies: (new_value, old_value) ->
      pending_galaxies = _.reject(@galaxies, (galaxy) => @client_state.core.galaxy_cache.has_galaxy_metadata(galaxy.id) || @is_galaxy_loading(galaxy.id))
      Promise.all(_.map(pending_galaxies, (galaxy) => new Promise (done, error) =>
        Vue.set(@galaxy_errors, galaxy.id, false) if @galaxy_errors[galaxy.id]
        @managers.galaxy_manager.load_metadata(galaxy.id)
          .then => done()
          .catch (e) =>
            Vue.set(@galaxy_errors, galaxy.id, true)
            done()
      ))

  methods:
    translate: (key) -> if @managers? then @managers.translation_manager.text(key) else key

    is_galaxy_loading: (galaxy_id) -> @ajax_state.is_locked('galaxy_metadata', galaxy_id)
    is_galaxy_error: (galaxy_id) -> @galaxy_errors[galaxy_id]

    metadata_for_galaxy: (galaxy_id) -> if @client_state.core.galaxy_cache.has_galaxy_metadata(galaxy_id) then @client_state.core.galaxy_cache.galaxy_metadata(galaxy_id) else null


    galaxy_name_is_long: (galaxy) -> (@galaxy_name(galaxy)?.length || 0) > 20
    galaxy_name: (galaxy) ->
      metadata = @metadata_for_galaxy(galaxy.id)
      if metadata? then metadata.name else "#{galaxy.api_url}:#{galaxy.api_port}"

    planet_count: (galaxy) -> @metadata_for_galaxy(galaxy.id)?.planet_count || 0
    online_count: (galaxy) -> @metadata_for_galaxy(galaxy.id)?.online_count || 0

    visitor_enabled: (galaxy) -> @metadata_for_galaxy(galaxy.id)?.visitor_enabled || false
    tycoon_enabled: (galaxy) -> @metadata_for_galaxy(galaxy.id)?.tycoon_enabled || false


    refresh_galaxy: (galaxy_id) ->
      return if @is_galaxy_loading(galaxy_id)
      Vue.set(@galaxy_errors, galaxy_id, false) if @galaxy_errors[galaxy_id]
      @managers.galaxy_manager.load_metadata(galaxy_id)
        .then => @$forceUpdate() if @is_visible
        .catch =>
          Vue.set(@galaxy_errors, galaxy_id, true)
          @$forceUpdate() if @is_visible


    toggle_remove_galaxy: () ->
      return unless @galaxies.length
      @client_state?.interface?.show_remove_galaxy = true

    toggle_add_galaxy: () ->
      @client_state?.interface?.show_add_galaxy = true

    proceed_as_visitor: (galaxy_id) ->
      metadata = @metadata_for_galaxy(galaxy_id)
      return unless metadata? && metadata?.visitor_enabled
      @client_state.identity.set_visa_type(galaxy_id, 'visitor')

    proceed_as_tycoon: (galaxy_id) ->
      metadata = @metadata_for_galaxy(galaxy_id)
      return unless metadata? && metadata?.tycoon_enabled
      @client_state.identity.set_visa_type(galaxy_id, 'tycoon')
</script>

<style lang='sass' scoped>
@import '~bulma/sass/utilities/_all'
@import '~assets/stylesheets/starpeace-variables'

.universe-multiverse-actions
  position: relative

  .galaxy-list
    background-color: darken($sp-primary-bg, 17.5%)
    border-left: 1px solid darken($sp-primary-bg, 15%)
    border-top: 1px solid darken($sp-primary-bg, 15%)
    border-right: 1px solid darken($sp-primary-bg, 5%)
    border-bottom: 1px solid darken($sp-primary-bg, 5%)
    max-height: 20.25rem
    min-height: 15rem
    padding: .25rem 0
    overflow-y: scroll

  .galaxy-row
    background-color: opacify(lighten($sp-primary-bg, 1%), .3)
    border: 1px solid rgba(110, 161, 146, .2)
    color: #fff
    margin: 0
    padding: 0
    position: relative

    &:not(:last-child)
      margin-bottom: .25rem

    .galaxy-name-text
      overflow: hidden
      text-overflow: ellipsis
      white-space: nowrap

    .is-smaller
      font-size: 1.25rem

    .planet-value
      margin-left: .5rem

    .galaxy-actions
      .button
        &:not(:first-child)
          margin-left: .5rem

    .galaxy-loading-modal
      background-color: #000
      border: 1px solid #000
      height: calc(100% + 2px)
      left: -1px
      opacity: .85
      position: absolute
      top: -1px
      width: calc(100% + 2px)

      .starpeace-logo
        animation: spin-and-blink 1.5s linear infinite
        background-size: 2rem
        filter: $sp-filter-primary
        height: 2rem
        left: calc(50% - 1rem)
        opacity: .7
        position: absolute
        top: calc(50% - 1rem)
        width: 2rem

      .galaxy-error-message
        font-size: 1.1rem
        left: calc(50% - 20rem)
        position: absolute
        text-align: center
        top: calc(50% - 1rem)
        width: 40rem

        a
          margin-left: .5rem

  .galaxy-actions-level
    margin-top: .5rem
    margin-bottom: 1rem

</style>
