<template lang='pug'>
#toolbar-header(v-show='is_ready' v-cloak=true oncontextmenu='return false')
  .columns.row-menu
    .column.column-menu
      .toolbar-menu
        a.button.is-starpeace.is-small.tooltip(:class="{'is-active':is_menu_visible('galaxy')}" @click.stop.prevent="toggle_menu('galaxy')" :data-tooltip="translate('ui.menu.galaxy.header')")
          font-awesome-icon(:icon="['fas', 'satellite']")
        a.button.is-starpeace.is-small.tooltip(:class="{'is-active':is_menu_visible('bookmarks')}" @click.stop.prevent="toggle_menu('bookmarks')" :data-tooltip="translate('ui.menu.bookmarks.header')")
          font-awesome-icon(:icon="['fas', 'map-marker-alt']")
        a.button.is-starpeace.is-small.tooltip(:class="{'is-active':is_menu_visible('tycoon')}" @click.stop.prevent='toggle_tycoon_details' :data-tooltip="translate('ui.menu.tycoon_details.header')" :disabled='!is_tycoon')
          font-awesome-icon(:icon="['fas', 'user-tie']")
        a.button.is-starpeace.is-small.tooltip(:class="{'is-active':is_menu_visible('politics')}" @click.stop.prevent="toggle_menu('politics')" :data-tooltip="translate('ui.menu.politics.header')")
          font-awesome-icon(:icon="['fas', 'landmark']")
        a.button.is-starpeace.is-small.tooltip(:class="{'is-active':is_menu_visible('rankings')}" @click.stop.prevent="toggle_menu('rankings')" :data-tooltip="translate('ui.menu.rankings.header')")
          font-awesome-icon(:icon="['fas', 'medal']")
        a.button.is-starpeace.is-small.tooltip(:class="{'is-active':is_menu_visible('hide_all')}" @click.stop.prevent="toggle_menu('hide_all')" :data-tooltip="translate('misc.hide_menus.label')")
          font-awesome-icon(:icon="['far', 'eye']")
        a.button.is-starpeace.is-small.tooltip(:class="{'is-active':is_menu_visible('town_search')}" @click.stop.prevent="toggle_menu('town_search')" :data-tooltip="translate('ui.menu.town_search.header')")
          font-awesome-icon(:icon="['fas', 'search-location']")
        a.button.is-starpeace.is-small.tooltip(:class="{'is-active':is_menu_visible('tycoon_search')}" @click.stop.prevent="toggle_menu('tycoon_search')" :data-tooltip="translate('ui.menu.tycoon_search.header')")
          font-awesome-icon(:icon="['fas', 'search']")
        a.button.is-starpeace.is-small.tooltip(:class="{'is-active':is_menu_visible('research')}" @click.stop.prevent="toggle_menu('research')" :data-tooltip="translate('ui.menu.research.header')")
          font-awesome-icon(:icon="['fas', 'flask']")
        a.button.is-starpeace.is-small.tooltip(:class="{'is-active':is_menu_visible('construction')}" @click.stop.prevent="toggle_menu('construction')" :data-tooltip="translate('ui.menu.construction.header')")
          font-awesome-icon(:icon="['fas', 'hammer']")
        a.button.is-starpeace.is-small.tooltip(:class="{'is-active':is_menu_visible('mail')}" @click.stop.prevent="toggle_menu('mail')" :data-tooltip="translate('ui.menu.mail.header')")
          font-awesome-icon(:icon="['far', 'envelope']")
        a.button.is-starpeace.is-small.tooltip(:class="{'is-active':is_menu_visible('chat')}" @click.stop.prevent="toggle_menu('chat')" :data-tooltip="translate('ui.menu.chat.header')")
          font-awesome-icon(:icon="['far', 'comments']")
        a.button.is-starpeace.is-small.tooltip(:class="{'is-active':is_menu_visible('options')}" @click.stop.prevent="toggle_menu('options')" :data-tooltip="translate('ui.menu.options.header')")
          font-awesome-icon(:icon="['fas', 'cogs']")
        a.button.is-starpeace.is-small.tooltip(:class="{'is-active':is_menu_visible('help')}" @click.stop.prevent="toggle_menu('help')" :data-tooltip="translate('ui.menu.help.header')")
          font-awesome-icon(:icon="['far', 'question-circle']")

    .column.column-tycoon
      span.column-tycoon-name
        template(v-if='is_tycoon')
          | {{tycoon_name}}
        template(v-else-if='!is_tycoon')
          | {{translate('identity.visitor')}}

      span.column-tycoon-buildings
        span.count 0 / 0
        font-awesome-icon(:icon="['far', 'building']")

      .column-notification-icons.level
        .level-item.client-version
          a(:class='menu_class_release_notes' @click.stop.prevent="client_state.menu.toggle_menu('release_notes')") {{client_version}}

        template(v-if='show_game_music')
          .level-item.game-music(:class='game_music_class')
            font-awesome-icon(:icon="['fas', 'play']" v-show='!game_music_playing' @click.stop.prevent='music_state.toggle_music()')
            font-awesome-icon(:icon="['fas', 'pause']" v-show='game_music_playing' @click.stop.prevent='music_state.toggle_music()')
          .level-item.game-music-next(:class='game_music_volume_class')
            font-awesome-icon(:icon="['fas', 'fast-forward']" @click.stop.prevent='music_state.next_song()')
          .level-item.game-music-volume(:class='game_music_volume_class')
            font-awesome-icon(:icon="['fas', 'volume-up']" v-show='music_state.game_music_volume' @click.stop.prevent='music_state.toggle_volume()')
            font-awesome-icon(:icon="['fas', 'volume-off']" v-show='!music_state.game_music_volume' @click.stop.prevent='music_state.toggle_volume()')

        .level-item.notification-mail(:class="{'has-unread':unread_mail.length>0}" @click.stop.prevent='toggle_mail()')
          font-awesome-icon(:icon="['far', 'envelope']")

        .level-item.notification-loading
          img.starpeace-logo(:class='notification_loading_css_class')

</template>

<script lang='coffee'>
import moment from 'moment'

export default
  props:
    ajax_state: Object
    client_state: Object
    managers: Object

  data: ->
    client_version: process.env.CLIENT_VERSION
    show_game_music: @client_state.options?.option('music.show_game_music')

  computed:
    music_state: -> @client_state?.music

    is_ready: -> @client_state.initialized && @client_state?.workflow_status == 'ready'
    is_tycoon: -> @is_ready && @client_state?.is_tycoon()
    ticker_message: -> @client_state?.interface?.event_ticker_message || ''

    unread_mail: -> _.filter(_.values(@client_state.player.mail_by_id), (m) -> !m.read)

    menu_class_release_notes: -> { 'is-active': @client_state?.menu?.is_visible('release_notes') || false }

    game_music_playing: -> @music_state.game_music_playing
    game_music_class: -> if @music_state.game_music_playing then 'music-pause' else 'music-play'
    game_music_volume_class: -> if @music_state.game_music_volume then 'music-volume' else 'music-mute'

    notification_loading_css_class: -> { 'ajax-loading': (@ajax_state?.ajax_requests || 0) > 0 }

    tycoon_name: -> if @is_tycoon then @client_state?.identity?.galaxy_tycoon?.name else ''

  mounted: ->
    @client_state.options?.subscribe_options_listener =>
      @show_game_music = @client_state.options?.option('music.show_game_music')

  methods:
    translate: (key) -> if @managers? then @managers.translation_manager.text(key) else key

    is_menu_visible: (option_type) -> @client_state.menu.is_visible(option_type)
    toggle_menu: (option_type) ->
      @client_state.interface.hide_inspect() if option_type == 'hide_all' && @client_state.interface.show_inspect
      @client_state.menu.toggle_menu(option_type)

    toggle_tycoon_details: () ->
      return unless @client_state.is_tycoon()
      if @client_state.menu.is_visible('tycoon')
        @client_state.menu.toggle_menu('tycoon')
      else
        @client_state.show_tycoon_profile(@client_state.player.tycoon_id)

    toggle_mail: () ->
      return unless @unread_mail.length
      @client_state.menu.toggle_menu('mail')

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

@keyframes opacity-blink
  0%
    opacity: .5
  25%
    opacity: 1
  75%
    opacity: 1
  100%
    opacity: .5

.button
  &.is-starpeace
    &.is-small
      font-size: .875rem
      line-height: 1.5
      border-radius: .2rem

#toolbar-header
  grid-column: start-left / end-right
  grid-row: start-menu / end-menu
  margin: 0
  position: relative
  pointer-events: auto

  .row-menu
    margin: 0

    .column-menu
      padding: 0
      max-width: 46rem

  .column-tycoon
    background: linear-gradient(to right, #395950, #000)
    padding: .5rem .75rem
    vertical-align: middle

    .column-tycoon-name
      color: #fff
      font-size: 1.25rem
      font-weight: 1000
      line-height: 1.8rem
      margin-right: 1rem
      vertical-align: bottom

    .column-tycoon-buildings
      color: $sp-primary

      .count
        margin-right: .5rem

    .column-notification-icons
      float: right

      .client-version
        font-style: italic

        a
          color: #6ea192
          opacity: .5

          &:hover
            color: #6ea192
            opacity: .7

          &:active,
          &.is-active
            color: #6ea192
            opacity: 1

      .game-music
        color: $sp-primary
        cursor: pointer
        font-size: 1.2rem
        margin-left: 1.5rem

        &.music-pause
          opacity: .5

        &.music-play
          opacity: .8

      .game-music-next
        color: $sp-primary
        cursor: pointer
        font-size: 1.5rem
        margin-left: .75rem
        opacity: .5

      .game-music-volume
        color: $sp-primary
        cursor: pointer
        font-size: 1.5rem
        margin-left: .5rem
        min-width: 1.75rem
        opacity: .5

      .notification-mail
        color: $sp-primary
        font-size: 1.5rem
        margin-left: 1rem
        opacity: .5

        &.has-unread
          animation: opacity-blink 3s linear infinite
          cursor: pointer

      .notification-loading
        margin-left: .75rem
        opacity: .5
        position: relative
        z-index: 1500 /* higher than others for animation */

        .starpeace-logo
          filter: invert(38%) sepia(9%) saturate(1145%) hue-rotate(112deg) brightness(101%) contrast(86%)
          background-size: 1.4rem
          height: 1.4rem
          width: 1.4rem
          vertical-align: middle

          &.ajax-loading
            animation: spin 1.5s linear infinite

.toolbar-menu
  background: linear-gradient(to top, darken($sp-primary-bg, 5%), #06261D)
  display: inline-block
  padding: .25rem
  text-align: center
  width: 46rem

  .button
    height: 2.5rem
    font-size: 1.25rem
    padding: 0 .65rem

    &.is-starpeace
      &.is-small
        border-radius: .2rem
        height: 2.5rem
        font-size: 1.25rem
        line-height: 1.5
        padding: 0 .65rem

    &:first-child
      &.tooltip
        &.is-tooltip-active::before,
        &:focus::before,
        &:hover::before
          left: 75%

    &:not(:first-child)
      margin-left: .5rem

    &.tooltip
      &.is-tooltip-active::before,
      &:focus::before,
      &:hover::before
        z-index: 1200

</style>
