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
              span.planet-label {{translate('ui.menu.galaxy.details.planets.label')}}:
              span.planet-value {{planet_count(galaxy)}}
            .galaxy-online
              span.planet-label {{translate('ui.menu.galaxy.details.online.label')}}:
              span.planet-value {{online_count(galaxy)}}

        .column.is-5.has-text-right.galaxy-actions
          button.button.is-medium.is-starpeace.is-inverted.is-outlined(v-on:click.stop.prevent="proceed_as_visitor(galaxy.id)" :disabled='!visitor_enabled(galaxy)') {{translate('identity.visitor')}}
          button.button.is-medium.is-starpeace.is-inverted(:class="{'is-outlined': tycoon_galaxy_id != galaxy.id}" v-on:click.stop.prevent="toggle_tycoon_galaxy(galaxy.id)" :disabled='!tycoon_enabled(galaxy)') {{translate('identity.tycoon')}}

        .galaxy-loading-modal(v-show='is_galaxy_loading(galaxy.id) || is_galaxy_error(galaxy.id)')
          img.starpeace-logo(v-show='is_galaxy_loading(galaxy.id)')
          .galaxy-error-message(v-show='is_galaxy_error(galaxy.id)')
            | {{translate('misc.unable_to_connect.label')}}
            a(@click.stop.prevent='refresh_galaxy(galaxy.id)') {{translate('misc.try_again.label')}}

      .columns.is-vcentered.galaxy-login-row(v-show="tycoon_galaxy_id && galaxy.id == tycoon_galaxy_id && !is_galaxy_loading(galaxy.id) && !is_galaxy_error(galaxy.id)")
        .column.is-12
          form
            .field.is-horizontal
              .field-body
                .field.is-grouped
                  template(v-if='tycoon_authenticated(galaxy) != null')
                    .control
                      button.button.is-starpeace.is-inverted.is-outlined(@click.stop.prevent="logout_tycoon(galaxy.id)") {{translate('ui.workflow.universe.signout.label')}}
                    .control.is-expanded
                      | Signed in as {{tycoon_authenticated(galaxy).username}}
                    .control
                      button.button.is-starpeace.is-inverted(@click.stop.prevent="proceed_as_tycoon(galaxy.id)") Proceed

                  template(v-else)
                    .control
                      button.button.is-starpeace.is-inverted.is-outlined(
                        @click.stop.prevent="toggle_create_tycoon(galaxy.id)"
                        :disabled='!tycoon_creation_enabled(galaxy.id)'
                      ) {{translate('misc.action.create')}}
                    .control.has-icons-left.is-expanded
                      input.input(type='text' autocomplete='username' :placeholder="translate('ui.workflow.universe.username.label')" v-model='username' :disabled='!!authorizing')
                      span.icon.is-small.is-left
                        font-awesome-icon(:icon="['fas', 'user-tie']")
                    .control.has-icons-left.is-expanded
                      input.input(type='password' autocomplete='current-password' :placeholder="translate('ui.workflow.universe.password.label')" v-model='password' :disabled='!!authorizing')
                      span.icon.is-small.is-left
                        font-awesome-icon(:icon="['fas', 'lock']")
                    .control
                      misc-toggle-option(:value='remember_me' @toggle="remember_me=!remember_me")
                      span.toggle-label(@click.stop.prevent="remember_me=!remember_me") {{translate('ui.workflow.universe.remember_tycoon.label')}}
                    .control
                      button.button.is-starpeace.is-inverted(@click.stop.prevent="login_tycoon(galaxy.id)" :disabled='!tycoon_enabled(galaxy) || !has_tycoon_credentials || authorizing') {{translate('ui.workflow.universe.signin.label')}}

            .field.is-horizontal(v-if='error_code')
              .field-body
                .field.is-grouped
                  .control.is-narrow
                    span.has-text-danger {{translate(error_code_key)}}

  .level.galaxy-actions-level
    .level-left
      .level-item
        button.button.is-small.is-starpeace(@click.stop.prevent='toggle_remove_galaxy' :disabled='!galaxies.length') {{translate('ui.workflow.universe.galaxy.remove.label')}}
    .level-right
      .level-item
        button.button.is-small.is-starpeace(@click.stop.prevent='toggle_add_galaxy') {{translate('ui.workflow.universe.galaxy.add.label')}}

</template>

<script lang='coffee'>
import _ from 'lodash';

MIN_USERNAME = 1 # TODO: raise to like 3+ in future
MIN_PASSWORD = 1 # TODO: raise to like 3+ in future

ERROR_CODE_GENERAL = 'GENERAL'
ERROR_CODE_INVALID = 'INVALID'
ERROR_CODES = [ERROR_CODE_GENERAL, ERROR_CODE_INVALID]

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

    authorizing: false
    username: ''
    password: ''
    remember_me: true
    error_code: null

    tycoon_galaxy_id: null

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
      if @is_visible
        @galaxies = @client_state.options.get_galaxies()
        @refresh_galaxies()

    tycoon_galaxy_id: (new_value, old_value) ->
      @clear_tycoon_credentials()

      if new_value == 'browser-sandbox'
        @username = 'test'
        @password = 'test'

    galaxies: (new_value, old_value) -> @refresh_galaxies()


  computed:
    is_visible: -> @client_state.workflow_status == 'pending_universe'

    has_tycoon_credentials: -> _.trim(@username).length >= MIN_USERNAME && _.trim(@password).length >= MIN_PASSWORD

    error_code_key: ->
      return 'ui.workflow.universe.error.signin_problem.label' if @error_code == ERROR_CODE_GENERAL
      return 'ui.workflow.universe.error.signin_invalid.label' if @error_code == ERROR_CODE_INVALID
      ''

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
    tycoon_creation_enabled: (galaxy_id) -> @metadata_for_galaxy(galaxy_id)?.tycoon_creation_enabled || false

    tycoon_authenticated: (galaxy) -> @metadata_for_galaxy(galaxy.id)?.tycoon

    refresh_galaxies: () ->
      pending_galaxies = _.reject(@galaxies, (galaxy) => @client_state.core.galaxy_cache.has_galaxy_metadata(galaxy.id) || @is_galaxy_loading(galaxy.id))
      Promise.all(_.map(pending_galaxies, (galaxy) => new Promise (done, error) =>
        @galaxy_errors[galaxy.id] = false if @galaxy_errors[galaxy.id]
        @managers.galaxy_manager.load_metadata(galaxy.id)
          .then => done()
          .catch (e) =>
            @galaxy_errors[galaxy.id] = true
            done()
      ))

    refresh_galaxy: (galaxy_id) ->
      return if @is_galaxy_loading(galaxy_id)
      @galaxy_errors[galaxy_id] = false if @galaxy_errors[galaxy_id]
      @managers.galaxy_manager.load_metadata(galaxy_id)
        .then => @$forceUpdate() if @is_visible
        .catch (err) =>
          @galaxy_errors[galaxy_id] = true
          @$forceUpdate() if @is_visible


    toggle_remove_galaxy: () ->
      return unless @galaxies.length
      return if @client_state?.interface?.show_add_galaxy || @client_state?.interface?.show_create_tycoon
      @client_state?.interface?.show_remove_galaxy = true

    toggle_add_galaxy: () ->
      return if @client_state?.interface?.show_remove_galaxy || @client_state?.interface?.show_create_tycoon
      @client_state?.interface?.show_add_galaxy = true

    toggle_tycoon_galaxy: (galaxy_id) ->
      return if @client_state?.interface?.show_remove_galaxy || @client_state?.interface?.show_add_galaxy || @client_state?.interface?.show_create_tycoon
      @tycoon_galaxy_id = if @tycoon_galaxy_id == galaxy_id then null else galaxy_id

    toggle_create_tycoon: (galaxy_id) ->
      return if @client_state?.interface?.show_remove_galaxy || @client_state?.interface?.show_add_galaxy
      return unless @tycoon_creation_enabled(galaxy_id)
      @client_state?.interface?.show_create_tycoon = true
      @client_state?.interface?.create_tycoon_galaxy_id = galaxy_id

    clear_tycoon_credentials: () ->
      @username = ''
      @password = ''
      @remember_me = true
      @error_code = null

    login_tycoon: (galaxy_id) ->
      return if @authorizing
      metadata = @metadata_for_galaxy(galaxy_id)
      return unless metadata? && metadata?.tycoon_enabled

      @authorizing = true
      try
        tycoon = await @managers.galaxy_manager.login(galaxy_id, @username, @password, @remember_me)
        @clear_tycoon_credentials()
        @authorizing = false
        @client_state.identity.set_visa(galaxy_id, 'tycoon', tycoon)
        @client_state.player.tycoon_id = tycoon.id
        @refresh_galaxy(galaxy_id)

      catch e
        @authorizing = false
        @error_code = if ERROR_CODES.indexOf(e?.data?.code) >= 0 then e?.data?.code else ERROR_CODE_GENERAL
        @$forceUpdate() if @is_visible

    logout_tycoon: (galaxy_id) ->
      @clear_tycoon_credentials()

      try
        await @managers.galaxy_manager.logout(galaxy_id)
        @client_state.reset_full_state()
        @refresh_galaxies()

      catch e
        @error_code = if ERROR_CODES.indexOf(e?.data?.code) >= 0 then e?.data?.code else ERROR_CODE_GENERAL
        @$forceUpdate() if @is_visible

    proceed_as_visitor: (galaxy_id) ->
      metadata = @metadata_for_galaxy(galaxy_id)
      return unless metadata? && metadata?.visitor_enabled
      @client_state.identity.set_visa(galaxy_id, 'visitor', null)

    proceed_as_tycoon: (galaxy_id) ->
      metadata = @metadata_for_galaxy(galaxy_id)
      return unless metadata? && metadata?.tycoon_enabled && metadata?.tycoon?
      @client_state.identity.set_visa(galaxy_id, 'tycoon', metadata.tycoon)
      @client_state.player.tycoon_id = metadata.tycoon.id

</script>

<style lang='sass' scoped>
@import 'bulma/sass/utilities/_all'
@import '~/assets/stylesheets/starpeace-variables'

.universe-multiverse-actions
  position: relative

  .galaxy-list
    background-color: darken($sp-primary-bg, 17.5%)
    border-left: 1px solid darken($sp-primary-bg, 15%)
    border-top: 1px solid darken($sp-primary-bg, 15%)
    border-right: 1px solid darken($sp-primary-bg, 5%)
    border-bottom: 1px solid darken($sp-primary-bg, 5%)
    min-height: 20rem
    padding: .25rem 0
    overflow-y: scroll

  .galaxy-row
    background-color: opacify(lighten($sp-primary-bg, 1%), .3)
    border: 1px solid rgba(110, 161, 146, .2)
    color: #fff
    margin: 0
    padding: 0
    position: relative

    &:not(:first-child)
      margin-top: .25rem

    .galaxy-name-text
      overflow: hidden
      text-overflow: ellipsis
      white-space: nowrap

    .is-smaller
      font-size: 1.25rem

    .planet-label
      display: inline-block
      min-width: 4rem
      text-align: right

    .planet-value
      margin-left: .75rem

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

  .galaxy-login-row
    background-color: opacify(darken($sp-primary-bg, 5%), .3)
    border: 1px solid rgba(110, 161, 146, .2)
    margin: 0
    padding: 0
    position: relative

    label
      color: #fff

    .control
      display: flex
      align-items: center

      .checkbox
        align-items: flex-end
        display: flex

        &:hover
          color: lighten($sp-primary-bg, 40%)

        input
          margin-right: .25rem

    .toggle-label
      cursor: pointer
      margin-left: .5rem

  .galaxy-actions-level
    margin-top: .5rem
    margin-bottom: 1rem

</style>
