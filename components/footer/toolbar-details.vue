<template lang='haml'>
%no-ssr
  %transition{name:'fade'}
    #toolbar-details{'v-show':'is_ready', 'v-cloak':'true'}
      .row.row-details
        .col-2.column-detail-logo
        .col-10.column-detail-container
      %table.table.row-footer-primary
        %tbody
          %tr.row-menu
            %toolbar-menubar{'v-bind:client_state':'client_state'}
            %td.column-tycoon
              %span.column-tycoon-name {{tycoon_name}}
              %span.column-tycoon-buildings
                %span.count 0 / 0
                %font-awesome-icon{':icon':"['far', 'building']"}
              .column-notification-icons.level
                .level-item.client-version
                  %a{'v-bind:class':'menu_class_release_notes', 'v-on:click.stop.prevent':"client_state.menu.toggle_menu('release_notes')"} {{client_version}}
                .level-item.game-music{'v-bind:class':'game_music_class', 'v-show':"show_game_music"}
                  %font-awesome-icon{':icon':"['fas', 'play']", 'v-show':'!music_state.game_music_playing', 'v-on:click.stop.prevent':'music_state.toggle_music()'}
                  %font-awesome-icon{':icon':"['fas', 'pause']", 'v-show':'music_state.game_music_playing', 'v-on:click.stop.prevent':'music_state.toggle_music()'}
                .level-item.game-music-next{'v-bind:class':'game_music_volume_class', 'v-show':"show_game_music"}
                  %font-awesome-icon{':icon':"['fas', 'fast-forward']", 'v-on:click.stop.prevent':'music_state.next_song()'}
                .level-item.game-music-volume{'v-bind:class':'game_music_volume_class', 'v-show':"show_game_music"}
                  %font-awesome-icon{':icon':"['fas', 'volume-up']", 'v-show':'music_state.game_music_volume', 'v-on:click.stop.prevent':'music_state.toggle_volume()'}
                  %font-awesome-icon{':icon':"['fas', 'volume-off']", 'v-show':'!music_state.game_music_volume', 'v-on:click.stop.prevent':'music_state.toggle_volume()'}
                .level-item.notification-mail
                  %font-awesome-icon{':icon':"['far', 'envelope']"}
                .level-item.notification-loading
                  %img.starpeace-logo{'v-bind:class':'notification_loading_css_class'}
          %tr
            %td.column-news-ticker {{ ticker_message }}
            %td.column-tycoon-details
              %toolbar-corporation{'v-bind:client_state':'client_state'}
</template>

<script lang='coffee'>
import moment from 'moment'

import ToolbarCorporation from '~/components/footer/toolbar-corporation.vue'
import ToolbarMenubar from '~/components/footer/toolbar-menubar.vue'
import MoneyText from '~/components/misc/money-text.vue'

export default
  props:
    ajax_state: Object
    client_state: Object
    options: Object

  components:
    'toolbar-corporation': ToolbarCorporation
    'toolbar-menubar': ToolbarMenubar
    'money-text': MoneyText

  data: ->
    client_version: process.env.CLIENT_VERSION
    show_game_music: @options?.option('music.show_game_music')

  mounted: ->
    @options?.subscribe_options_listener =>
      @show_game_music = @options?.option('music.show_game_music')

  computed:
    music_state: -> @client_state?.music

    is_ready: -> @client_state.initialized && @client_state?.workflow_status == 'ready'
    ticker_message: -> @client_state?.interface?.event_ticker_message || ''

    menu_class_release_notes: -> { 'is-active': @client_state?.menu?.is_visible('release_notes') || false }

    game_music_class: -> if @music_state.game_music_playing then 'music-pause' else 'music-play'
    game_music_volume_class: -> if @music_state.game_music_volume then 'music-volume' else 'music-mute'

    notification_loading_css_class: -> { 'ajax-loading': (@ajax_state?.ajax_requests || 0) > 0 }

    tycoon_name: -> if @is_ready && @client_state?.identity?.identity?.is_tycoon() then @client_state?.current_tycoon_metadata()?.name || '' else 'Visitor'
</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

.button
  &.is-starpeace
    &.is-small
      font-size: .875rem
      line-height: 1.5
      border-radius: .2rem

#toolbar-details
  grid-column-start: 1
  grid-column-end: 4
  grid-row-start: 5
  grid-row-end: 6
  margin: 0
  position: relative

  table
    width: 100%

    td
      border: 0

  .row-details
    background-color: #000

  .row-footer-primary
    td
      border-top: 0

    .column-detail-logo
      max-width: 20rem

    .column-tycoon
      background: linear-gradient(to right, #395950, #000)
      padding: 0 .75rem
      vertical-align: middle

      td
        padding: .25rem

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

    .column-tycoon-details
      background: linear-gradient(to right, #395950, #000)
      padding: 0

    .column-news-ticker
      background-color: #2a453f
      color: $sp-primary
      font-size: .85rem
      font-weight: 1000
      height: 6rem
      padding: .5rem

</style>
