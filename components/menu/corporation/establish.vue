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

          .field.is-horizontal(v-show='error_code')
            .field-body
              .field
                .control.is-narrow
                  span.has-text-danger {{translate(error_code_key)}}

    footer.card-footer
      .card-footer-item.level.is-mobile
        .level-left
          button.button.is-primary.is-medium.is-outlined(@click.stop.prevent='cancel') {{translate('ui.menu.corporation.establish.action.cancel')}}
        .level-right
          button.button.is-primary.is-medium(@click.stop.prevent='establish' :disabled='!can_establish') {{translate('ui.menu.corporation.establish.action.establish')}}

</template>

<script lang='coffee'>
import _ from 'lodash';

ERROR_CODE_GENERAL = 'GENERAL'
ERROR_CODE_INVALID_NAME = 'INVALID_NAME'
ERROR_CODE_TYCOON_LIMIT = 'TYCOON_LIMIT'
ERROR_CODE_NAME_CONFLICT = 'NAME_CONFLICT'
ERROR_CODES = [ERROR_CODE_GENERAL, ERROR_CODE_INVALID_NAME, ERROR_CODE_TYCOON_LIMIT, ERROR_CODE_NAME_CONFLICT]

export default
  props:
    managers: Object
    client_state: Object

  data: ->
    saving: false
    error_code: null

    corporation_name: ''

  computed:
    is_visible: -> @client_state.initialized && @client_state.workflow_status == 'ready' && @client_state.is_tycoon() && !@client_state.player.corporation_id?.length
    can_establish: -> @is_visible && !@saving && _.trim(@corporation_name).length >= 3

    error_code_key: ->
      return 'ui.menu.corporation.establish.error.general' if @error_code == ERROR_CODE_GENERAL
      return 'ui.menu.corporation.establish.error.name' if @error_code == ERROR_CODE_INVALID_NAME
      return 'ui.menu.corporation.establish.error.limit' if @error_code == ERROR_CODE_TYCOON_LIMIT
      return 'ui.menu.corporation.establish.error.conflict' if @error_code == ERROR_CODE_NAME_CONFLICT
      ''

  watch:
    is_visible: (new_value, old_value) ->
      if @is_visible
        @saving = false
        @error_code = null
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
          @error_code = if ERROR_CODES.indexOf(err?.response?.data?.code) >= 0 then err?.response?.data?.code else ERROR_CODE_GENERAL
          @$forceUpdate() if @is_visible

</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

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
