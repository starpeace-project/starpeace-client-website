<template lang='pug'>
#establish-corporation-container(oncontextmenu='return false')
  .modal-background
  .card.is-starpeace.has-header
    .card-header
      .card-header-title {{translate('ui.menu.corporation.establish.header')}}
    .card-content.sp-menu-background
      .content
        p.intro
          | {{translate('ui.menu.corporation.establish.planet.welcome')}}
          |
          span.planet-name {{planet_name()}}
          | ,
          |
          | {{translate('identity.tycoon')}}!
        p.info
          | {{translate('ui.menu.corporation.establish.description')}}

        form.corporation-form
          .field.is-horizontal
            .field-body
              .field
                .control.is-expanded
                  input.input.is-large(type='text' v-model='corporation_name' :disabled='saving' :placeholder="translate('ui.menu.corporation.establish.field.name')")

          .field.is-horizontal(v-show='error_message')
            .field-body
              .field
                .control.is-narrow
                  span.has-text-danger {{translate('ui.menu.corporation.establish.error.general')}}

    footer.card-footer
      .card-footer-item.level.is-mobile
        .level-left
          a.button.is-primary.is-medium.is-outlined(@click.stop.prevent='cancel') {{translate('ui.menu.corporation.establish.action.cancel')}}
        .level-right
          a.button.is-primary.is-medium(@click.stop.prevent='establish' :disabled='!can_establish') {{translate('ui.menu.corporation.establish.action.establish')}}

</template>

<script lang='coffee'>
export default
  props:
    managers: Object
    client_state: Object

  data: ->
    saving: false
    error_message: null

    corporation_name: ''

  computed:
    is_visible: -> @client_state.initialized && @client_state.workflow_status == 'ready' && @client_state.is_tycoon() && !@client_state.player.corporation_id?.length
    can_establish: -> @is_visible && !@saving && _.trim(@corporation_name).length

  watch:
    is_visible: (new_value, old_value) ->
      if @is_visible
        @saving = false
        @error_message = null
        @corporation_name = ''

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    planet_name: -> @client_state?.current_planet_metadata().name

    cancel: () ->
      @client_state.reset_to_galaxy()
      window.document.title = "STARPEACE" if window?.document?

    establish: () ->
      return unless @can_establish
      @saving = true
      @managers.corporation_manager.create(_.trim(@corporation_name))
        .then (corporation) =>
          @client_state.player.set_planet_corporation_id(corporation.id)
          @saving = false

        .catch (err) =>
          @client_state.add_error_message('Failure establishing corporation, please try again', err)
          @saving = false
          @error_message = true
          @$forceUpdate() if @is_visible

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

#establish-corporation-container
  align-items: center
  display: flex
  grid-column: start-left / end-right
  grid-row: start-render / end-toolbar
  justify-content: center
  position: relative
  overflow: hidden
  z-index: 1500

  > .card
    background-color: $sp-dark-bg
    max-width: 50rem
    z-index: 1500

    .content
      color: $sp-primary

      .intro
        font-size: 1.3rem
        font-weight: bold

      .info
        font-size: 1.15rem

      .planet-name
        color: #fff

      .corporation-form
        margin-bottom: 1rem
        margin-top: 2rem

</style>
