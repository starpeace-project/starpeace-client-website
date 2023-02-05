<template lang='pug'>
.remove-galaxy-dialog
  .card.is-starpeace.has-header
    .card-header
      .card-header-title {{translate('ui.workflow.universe.galaxy.add.label')}}
      .card-header-icon.card-close(v-on:click.stop.prevent="close_sub_menu")
        font-awesome-icon(:icon="['fas', 'times']")

    .card-content.sp-menu-background
      form
        .field.is-horizontal
          .field-label.is-normal
            label.label Protocol:
          .field-body
            .field
              .control
                button.button.is-medium.is-fullwidth.is-starpeace(:class="protocol == 'http' ? 'is-active' : ''", v-on:click.stop.prevent="protocol = 'http'") HTTP
            .field
              .control
                button.button.is-medium.is-fullwidth.is-starpeace(:class="protocol == 'https' ? 'is-active' : ''", v-on:click.stop.prevent="protocol = 'https'") HTTPS

        .field.is-horizontal
          .field-label.is-normal
            label.label Host / IP:
          .field-body
            .field
              .control
                input.input(type='text', v-model='host')

        .field.is-horizontal
          .field-label.is-normal
            label.label Port:
          .field-body
            .field
              .control
                input.input(type='number', placeholder='19160', v-model='port')

      .level.is-mobile.galaxy-actions
        .level-item
          button.button.is-medium.is-fullwidth.is-starpeace.is-square(v-on:click.stop.prevent="close_sub_menu") {{translate('misc.action.cancel')}}
        .level-item
          button.button.is-medium.is-fullwidth.is-starpeace.is-square(v-on:click.stop.prevent="add_galaxy", :disabled='!has_form_data') {{translate('misc.action.add')}}


</template>

<script lang='coffee'>
export default
  props:
    client_state: Object
    managers: Object

  data: ->
    protocol: 'http'
    host: null
    port: null

  computed:
    is_visible: -> @client_state?.interface?.show_add_galaxy

    port_as_number: ->
      try
        value = parseInt(@port)
        if isNaN(value) || !isFinite(value) then 0 else value
      catch
        0

    has_form_data: ->
      @is_visible && (@protocol == 'http' || @protocol == 'https') && !!@host?.length && (@port_as_number > 0)

  watch:
    is_visible: (new_value, old_value) ->
      if @is_visible
        @protocol = 'http'
        @host = null
        @port = null

  methods:
    translate: (key) -> if @managers? then @managers.translation_manager.text(key) else key

    close_sub_menu: () -> @client_state?.interface?.show_add_galaxy = false

    add_galaxy: () ->
      return unless @has_form_data

      galaxy = @client_state.options.add_galaxy(@protocol, @host, @port)
      @client_state.core.galaxy_cache.load_galaxy_configuration(galaxy.id, galaxy)

      @client_state.interface.show_add_galaxy = false

</script>

<style lang='sass' scoped>
@import 'bulma/sass/utilities/_all'
@import '~/assets/stylesheets/starpeace-variables'

.remove-galaxy-dialog
  position: fixed
  left: calc(50% - 20rem)
  width: 40rem
  height: 16rem
  top: calc(50% - 8rem - 3rem)
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

  form
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
