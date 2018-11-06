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
            %toolbar-menubar{'v-bind:game_state':'game_state', 'v-bind:menu_state':'menu_state', 'v-bind:ui_state':'ui_state'}
            %td.column-tycoon
              %span.column-tycoon-name {{tycoon_name}}
              %span.column-tycoon-buildings
                %span.count 0 / 0
                %font-awesome-icon{':icon':"['far', 'building']"}
              .column-notification-icons.level
                .level-item.client-version
                  %a{'v-bind:class':'menu_class_release_notes', 'v-on:click.stop.prevent':"menu_state.toggle_menu('release_notes')"} {{client_version}}
                .level-item.game-music{'v-bind:class':'game_music_class', 'v-show':"show_game_music"}
                  %font-awesome-icon{':icon':"['fas', 'play']", 'v-show':'!game_state.game_music_playing', 'v-on:click.stop.prevent':'toggle_game_music()'}
                  %font-awesome-icon{':icon':"['fas', 'pause']", 'v-show':'game_state.game_music_playing', 'v-on:click.stop.prevent':'toggle_game_music()'}
                .level-item.game-music-next{'v-bind:class':'game_music_volume_class', 'v-show':"show_game_music"}
                  %font-awesome-icon{':icon':"['fas', 'fast-forward']", 'v-on:click.stop.prevent':'toggle_next_game_music()'}
                .level-item.game-music-volume{'v-bind:class':'game_music_volume_class', 'v-show':"show_game_music"}
                  %font-awesome-icon{':icon':"['fas', 'volume-up']", 'v-show':'game_state.game_music_volume', 'v-on:click.stop.prevent':'toggle_game_music_volume()'}
                  %font-awesome-icon{':icon':"['fas', 'volume-off']", 'v-show':'!game_state.game_music_volume', 'v-on:click.stop.prevent':'toggle_game_music_volume()'}
                .level-item.notification-mail
                  %font-awesome-icon{':icon':"['far', 'envelope']"}
                .level-item.notification-loading
                  %img.starpeace-logo{'v-bind:class':'notification_loading_css_class'}
          %tr
            %td.column-news-ticker {{ ticker_message }}
            %td.column-tycoon-details
              %table
                %tbody
                  %tr
                    %td.column-tycoon-corporation {{corporation_name}}
                  %tr
                    %td.column-tycoon-cash
                      $0
                  %tr
                    %td.column-tycoon-cashflow
                      ($0/h)
                  %tr
                    %td.column-date {{ current_date }}
</template>

<script lang='coffee'>
import moment from 'moment'

import ToolbarMenubar from '~/components/footer/toolbar-menubar.vue'

export default
  props:
    camera_manager: Object
    game_state: Object
    menu_state: Object
    mini_map_renderer: Object
    music_manager: Object
    options: Object
    ui_state: Object

  components:
    'toolbar-menubar': ToolbarMenubar

  data: ->
    client_version: process.env.CLIENT_VERSION
    show_game_music: @options?.option('music.show_game_music')

  watch:
    state_counter: (new_value, old_value) ->
      @show_game_music = @options?.option('music.show_game_music')

  computed:
    state_counter: -> @options?.vue_state_counter

    is_ready: -> @game_state?.initialized
    ticker_message: -> @ui_state?.event_ticker_message || ''
    current_date: -> moment(@game_state?.current_date).format('MMM D, YYYY')

    menu_class_release_notes: -> { 'is-active': @menu_state?.show_menu_release_notes || false }

    game_music_class: -> if @game_state.game_music_playing then 'music-pause' else 'music-play'
    game_music_volume_class: -> if @game_state.game_music_volume then 'music-volume' else 'music-mute'

    notification_loading_css_class: -> { 'ajax-loading': (@game_state?.ajax_requests || 0) > 0 }

    tycoon_name: -> if @game_state?.session_state.state_counter && @game_state?.session_state.identity.is_tycoon() then @game_state?.session_state.tycoon_metadata?.name else 'Visitor'
    corporation_name: ->
      if @is_ready && @game_state?.session_state.state_counter && @game_state?.session_state.identity.is_tycoon()
        if @game_state.session_state.corporation_id? then @game_state.name_for_corporation_id(@game_state.session_state.corporation_id) else '[PENDING]'
      else
        '[VISITOR VISA]'

  methods:
    toggle_game_music: -> @music_manager.toggle_music()
    toggle_next_game_music: -> @music_manager.next_song()
    toggle_game_music_volume: -> @music_manager.toggle_volume()
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

      td
        padding: .25rem .75rem

      .column-tycoon-corporation
        color: #fff

      .column-tycoon-cash
        color: $sp-primary
        font-size: 1.5rem
        font-weight: 1000
        line-height: 1.25rem

      .column-tycoon-cashflow
        color: $sp-primary
        padding-bottom: 0
        padding-top: .25rem
        vertical-align: bottom

      .column-date
        color: $sp-primary
        padding-top: 0
        padding-bottom: 1rem
        vertical-align: top

    .column-news-ticker
      background-color: #2a453f
      color: $sp-primary
      font-size: .85rem
      font-weight: 1000
      height: 6rem
      padding: .5rem

</style>
