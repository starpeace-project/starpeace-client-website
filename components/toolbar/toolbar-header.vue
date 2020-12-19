<template lang='pug'>
transition(name='fade')
  #toolbar-header(v-show='is_ready' v-cloak=true)
    .columns.row-menu
      .column.column-menu
        toolbar-menubar(:managers='managers' :client_state='client_state')

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

import ToolbarCorporation from '~/components/toolbar/toolbar-corporation.vue'
import ToolbarMenubar from '~/components/toolbar/toolbar-menubar.vue'
import MoneyText from '~/components/misc/money-text.vue'

export default
  components:
    'toolbar-corporation': ToolbarCorporation
    'toolbar-menubar': ToolbarMenubar
    'money-text': MoneyText

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

    tycoon_name: -> if @is_tycoon then @client_state?.current_tycoon_metadata()?.name else ''

  mounted: ->
    @client_state.options?.subscribe_options_listener =>
      @show_game_music = @client_state.options?.option('music.show_game_music')

  methods:
    translate: (key) -> if @managers? then @managers.translation_manager.text(key) else key

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
  grid-column-start: 1
  grid-column-end: 4
  grid-row-start: 5
  grid-row-end: 6
  margin: 0
  position: relative

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

        .starpeace-logo
          filter: invert(38%) sepia(9%) saturate(1145%) hue-rotate(112deg) brightness(101%) contrast(86%)
          background-size: 1.4rem
          height: 1.4rem
          width: 1.4rem
          vertical-align: middle

          &.ajax-loading
            animation: spin 1.5s linear infinite

</style>
