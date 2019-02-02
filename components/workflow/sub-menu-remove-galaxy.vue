<template lang='pug'>
.remove-galaxy-dialog
  .card.is-starpeace.has-header
    .card-header
      .card-header-title {{translate('ui.workflow.universe.galaxy.remove.label')}}
      .card-header-icon.card-close(v-on:click.stop.prevent="close_sub_menu")
        font-awesome-icon(:icon="['fas', 'times']")

    .card-content.sp-menu-background
      .galaxies-container.sp-scrollbar
        .columns.is-vcentered.galaxy-row(v-for='galaxy,index in galaxies')
          .column.is-1.has-text-centered
            span.select-galaxy-toggle(v-on:click.stop.prevent="toggle_galaxy_index(index)")
              font-awesome-icon(v-show="selected_indices.indexOf(index) >= 0", :icon="['fas', 'square']")
              font-awesome-icon(v-show="selected_indices.indexOf(index) < 0", :icon="['far', 'square']")
          .column.is-11
            .galaxy-name(v-on:click.stop.prevent="toggle_galaxy_index(index)") {{galaxy_name(galaxy)}}

      .level.is-mobile.galaxy-actions
        .level-item
          a.button.is-medium.is-fullwidth.is-starpeace.is-square(v-on:click.stop.prevent="close_sub_menu") {{translate('misc.action.cancel')}}
        .level-item
          a.button.is-medium.is-fullwidth.is-starpeace.is-square(v-on:click.stop.prevent="remove_galaxies", :disabled='selected_indices.length == 0') {{translate('misc.action.remove')}}


</template>

<script lang='coffee'>
export default
  props:
    client_state: Object
    managers: Object

  data: ->
    selected_indices: []
    galaxies: []

  computed:
    is_visible: -> @client_state?.interface?.show_remove_galaxy

  mounted: ->
    @galaxies = @client_state.options.get_galaxies()

    @client_state.options.subscribe_galaxies_listener =>
      @galaxies = @client_state.options.get_galaxies()
      @selected_indices = []
    @client_state.core.galaxy_cache.subscribe_configuration_listener =>
      @$forceUpdate() if @is_visible
    @client_state.core.galaxy_cache.subscribe_metadata_listener =>
      @$forceUpdate() if @is_visible

  watch:
    is_visible: (new_value, old_value) ->
      if @is_visible
        @galaxies = @client_state.options.get_galaxies()
      else
        @selected_indices = []

  methods:
    translate: (key) -> if @managers? then @managers.translation_manager.text(key) else key

    metadata_for_galaxy: (galaxy_id) -> if @client_state.core.galaxy_cache.has_galaxy_metadata(galaxy_id) then @client_state.core.galaxy_cache.galaxy_metadata(galaxy_id) else null

    galaxy_name: (galaxy) ->
      metadata = @metadata_for_galaxy(galaxy.id)
      if metadata? then metadata.name else "#{galaxy.api_url}:#{galaxy.api_port}"

    toggle_galaxy_index: (index) ->
      array_index = @selected_indices.indexOf(index)
      if array_index >= 0
        @selected_indices.splice(array_index, 1)
      else
        @selected_indices.push index

    close_sub_menu: () -> @client_state?.interface?.show_remove_galaxy = false

    remove_galaxies: () ->
      return unless @selected_indices.length

      galaxies = []
      galaxies.push @galaxies[index] for index in @selected_indices

      for galaxy in galaxies
        @client_state.core.galaxy_cache.remove_galaxy(galaxy.id)
        @client_state.options.remove_galaxy(galaxy.id)

      @galaxies = @client_state.options.get_galaxies()
      @selected_indices = []

</script>

<style lang='sass' scoped>
@import '~bulma/sass/utilities/_all'
@import '~assets/stylesheets/starpeace-variables'

.remove-galaxy-dialog
  position: fixed
  left: calc(50% - 20rem)
  width: 40rem
  height: 30rem
  top: calc(50% - 15rem - 3rem)
  z-index: 2000

  .card
    height: 100%

  .card-content
    height: calc(100% - 3.5rem)
    padding: 0

  .galaxies-container
    height: calc(100% - 3rem)
    overflow-y: scroll
    padding: 1rem

    > .columns
      margin: 0

      > .column
       padding: .5rem

  .select-galaxy-toggle
    cursor: pointer

  .galaxy-name
    font-size: 1.25rem
    cursor: pointer

  .galaxy-actions
    height: 3rem

    .level-item
      margin: 0

</style>
