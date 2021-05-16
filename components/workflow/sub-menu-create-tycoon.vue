<template lang='pug'>
.create-tycoon-dialog
  .card.is-starpeace.has-header
    .card-header
      .card-header-title {{translate('ui.workflow.universe.create_tycoon.label')}}
      .card-header-icon.card-close(v-on:click.stop.prevent="close_sub_menu")
        font-awesome-icon(:icon="['fas', 'times']")

    .card-content.sp-menu-background
      form.tycoon-form
        .field.is-horizontal
          .field-body
            .field
              .control.has-icons-left.is-expanded
                input.input(type='text' v-model='username' :disabled='saving' :placeholder="translate('ui.workflow.universe.username.label')")
                span.icon.is-small.is-left
                  font-awesome-icon(:icon="['fas', 'user-tie']")

        .field.is-horizontal
          .field-body
            .field
              .control.has-icons-left.is-expanded
                input.input(type='password' v-model='password' :disabled='saving' :placeholder="translate('ui.workflow.universe.password.label')")
                span.icon.is-small.is-left
                  font-awesome-icon(:icon="['fas', 'lock']")

        .field.is-horizontal
          .field-body
            .field
              .control.has-icons-left.is-expanded
                input.input(type='password' v-model='password_confirm' :disabled='saving' :placeholder="translate('ui.workflow.universe.confirm_password.label')")
                span.icon.is-small.is-left
                  font-awesome-icon(:icon="['fas', 'lock']")

        .field.is-horizontal
          .field-body
            .field
              .control.remember-toggle
                toggle-option(:value='remember_me' @toggle="remember_me=!remember_me" :disabled='saving')
                span.toggle-label(@click.stop.prevent="remember_me=!remember_me") {{translate('ui.workflow.universe.remember_tycoon.label')}}

        .field.is-horizontal(v-show='error_message')
          .field-body
            .field
              .control.is-narrow
                span.has-text-danger {{translate(error_message_key)}}

      .level.is-mobile.galaxy-actions
        .level-item
          a.button.is-medium.is-fullwidth.is-starpeace.is-square(@click.stop.prevent="close_sub_menu") {{translate('misc.action.cancel')}}
        .level-item
          a.button.is-medium.is-fullwidth.is-starpeace.is-square(@click.stop.prevent="create_tycoon" :disabled='!can_create') {{translate('misc.action.create')}}


</template>

<script lang='coffee'>
import ToggleOption from '~/components/misc/toggle-option.vue'

ERROR_CODE_GENERAL = 'GENERAL'
ERROR_CODE_PASSWORD_MISMATCH = 'PASSWORD_MISMATCH'
ERROR_CODE_USERNAME_CONFLICT = 'USERNAME_CONFLICT'
ERROR_MESSAGES = [ERROR_CODE_GENERAL, ERROR_CODE_PASSWORD_MISMATCH, ERROR_CODE_USERNAME_CONFLICT]

export default
  components:
    'toggle-option': ToggleOption

  props:
    client_state: Object
    managers: Object

  data: ->
    saving: false
    error_message: null

    username: ''
    password: ''
    password_confirm: ''
    remember_me: true

  computed:
    is_visible: -> @client_state?.interface?.show_create_tycoon && @client_state?.interface?.create_tycoon_galaxy_id?

    error_message_key: ->
      return 'ui.workflow.universe.error.general_problem.label' if @error_message == ERROR_CODE_GENERAL
      return 'ui.workflow.universe.error.password_mismatch.label' if @error_message == ERROR_CODE_PASSWORD_MISMATCH
      return 'ui.workflow.universe.error.username_conflict.label' if @error_message == ERROR_CODE_USERNAME_CONFLICT
      ''

    can_create: -> !@saving && @username?.length && @password?.length && @password_confirm?.length

  watch:
    is_visible: (new_value, old_value) ->
      if @is_visible
        @saving = false
        @error_message = null
        @username = ''
        @password = ''
        @password_confirm = ''
        @remember_me = true

  methods:
    translate: (key) -> if @managers? then @managers.translation_manager.text(key) else key

    close_sub_menu: () ->
      @client_state?.interface?.show_create_tycoon = false
      @client_state?.interface?.create_tycoon_galaxy_id = null

    create_tycoon: () ->
      return unless @can_create

      @error_message = null
      if @password != @password_confirm
        @error_message = ERROR_CODE_PASSWORD_MISMATCH
      else
        @saving = true
        galaxy_id = @client_state?.interface?.create_tycoon_galaxy_id
        @managers.galaxy_manager.create(galaxy_id, @username, @password, @remember_me)
          .then (tycoon) =>
            @client_state.identity.set_visa(galaxy_id, 'tycoon', tycoon)
            @client_state.player.tycoon_id = tycoon.id
            @managers.galaxy_manager.load_metadata(galaxy_id)
              .then =>
                @saving = false
                @close_sub_menu()
              .catch (e) =>
                @close_sub_menu()
                @saving = false

          .catch (e) =>
            @saving = false
            @error_message = if ERROR_MESSAGES.indexOf(e) >= 0 then e else ERROR_CODE_GENERAL
            @$forceUpdate() if @is_visible


</script>

<style lang='sass' scoped>
@import '~bulma/sass/utilities/_all'
@import '~assets/stylesheets/starpeace-variables'

.create-tycoon-dialog
  position: fixed
  left: calc(50% - 20rem)
  width: 40rem
  min-height: 20rem
  top: calc(50% - 10rem - 3rem)
  z-index: 2000

  .card
    height: 100%

  .card-content
    height: calc(100% - 3.5rem)
    padding: 0

  .tycoon-form
    padding: 1rem

  .remember-toggle
    align-items: center
    display: flex

    .toggle-label
      cursor: pointer
      margin-left: .5rem

  .galaxy-actions
    height: 3rem

    .level-item
      margin: 0

</style>
