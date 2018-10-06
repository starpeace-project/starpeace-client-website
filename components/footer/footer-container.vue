<template lang='haml'>
%no-ssr
  %transition{name:'fade'}
    #footer-container{'v-show':'is_ready', 'v-cloak':true}
      %table.table.row-inspect
        %tbody
          %tr
            %td.column-camera-controls
              %a.button.is-starpeace.is-small{'v-on:click.stop.prevent':'camera_manager.zoom_in()'}
                %font-awesome-icon{':icon':"['fas', 'plus']"}
            %td.column-camera-controls
              %a.button.is-starpeace.is-small{'v-on:click.stop.prevent':'camera_manager.zoom_out()'}
                %font-awesome-icon{':icon':"['fas', 'minus']"}
            %td.column-overlays
              %a.button.is-starpeace.is-starpeace-light.is-small{'v-bind:class':'menu_class_overlay', 'v-on:click.stop.prevent':'ui_state.toggle_overlay()'}
                Overlay
            %td.column-inspect{rowspan: 2}
              %a.button.is-starpeace.is-starpeace-light.is-small
                Inspect
            %td.column-details-ticker.primary
              Welcome to STARPEACE! If you enjoy your time as a Visitor, become a Tycoon!
            %toolbar-minimap{'v-bind:mini_map_renderer':'mini_map_renderer', 'v-bind:options':'options', 'v-bind:ui_state':'ui_state'}
          %tr
            %td.column-camera-controls
              %a.button.is-starpeace.is-small{}
                %font-awesome-icon{':icon':"['fas', 'redo-alt']"}
            %td.column-camera-controls
              %a.button.is-starpeace.is-small{}
                %font-awesome-icon{':icon':"['fas', 'undo-alt']"}
            %td.column-overlays
              %a.button.is-starpeace.is-starpeace-light.is-small{'v-bind:class':'menu_class_zones', 'v-on:click.stop.prevent':'ui_state.toggle_zones()'}
                City Zones
            %td.column-details-ticker.secondary
              HINT: Tycoons can start companies and invest in different industries and real estate.
      .row.row-details
        .col-2.column-detail-logo
        .col-10.column-detail-container
      %table.table.row-footer-primary
        %tbody
          %tr.row-menu
            %toolbar-menubar{'v-bind:game_state':'game_state', 'v-bind:menu_state':'menu_state', 'v-bind:ui_state':'ui_state'}
            %td.column-tycoon
              %span.column-tycoon-name
                Visitor
              %span.column-tycoon-buildings
                %span.count 0 / 0
                %font-awesome-icon{':icon':"['far', 'building']"}
              .column-notification-icons.level
                .level-item.client-version
                  %a{'v-bind:class':'menu_class_release_notes', 'v-on:click.stop.prevent':'menu_state.toggle_menu_release_notes()'} {{client_version}}
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
                    %td.column-tycoon-corporation
                      [VISITOR VISA]
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
import interact from 'interactjs'
import moment from 'moment'

import ToolbarMenubar from '~/components/footer/toolbar-menubar.vue'
import ToolbarMinimap from '~/components/footer/toolbar-minimap.vue'

MIN_MINI_MAP_WIDTH = 300
MIN_MINI_MAP_HEIGHT = 200

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
    'toolbar-minimap': ToolbarMinimap

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

    menu_class_overlay: -> { 'is-active': @ui_state?.show_overlay || false }
    menu_class_zones: -> { 'is-active': @ui_state?.show_zones || false }
    menu_class_release_notes: -> { 'is-active': @menu_state?.show_menu_release_notes || false }

    game_music_class: -> if @game_state.game_music_playing then 'music-pause' else 'music-play'
    game_music_volume_class: -> if @game_state.game_music_volume then 'music-volume' else 'music-mute'

    notification_loading_css_class: -> { 'ajax-loading': (@game_state?.ajax_requests || 0) > 0 }

  methods:
    toggle_zones: -> @ui_state.show_zones = !@ui_state.show_zones

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

#footer-container
  grid-column-start: 1
  grid-column-end: 4
  grid-row-start: 4
  grid-row-end: 5
  margin: 0

  table
    width: 100%

    td
      border: 0

  .row-inspect
    background-color: #000
    margin-bottom: 0

    tr
      &:first-child
        .column-camera-controls
          vertical-align: bottom

        .column-overlays
          vertical-align: bottom

      &:last-child
        .column-camera-controls
          vertical-align: top

        .column-overlays
          vertical-align: top

    .column-camera-controls
      height: 2rem
      padding: .25rem
      width: 2rem

      .button
        display: block

      .fa-redo-alt
        transform: rotate(-20deg)

      .fa-undo-alt
        transform: rotate(20deg)

    .column-overlays
      padding: .25rem
      text-transform: uppercase
      width: 8rem

      .button
        display: block
        height: 2rem
        padding-top: .3rem

    .column-inspect
      padding: .25rem .5rem .25rem .25rem
      text-transform: uppercase
      vertical-align: middle
      width: 10rem

      .button
        display: block
        height: 4.5rem
        font-size: 1.25rem
        font-weight: 1000
        letter-spacing: .2rem
        line-height: 3.75rem

    .column-details-ticker
      background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAMAAAADCAYAAABWKLW/AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAEElEQVQI12NgYGD4z0AQAAAjBAEAIsfjuAAAAABJRU5ErkJggg==')
      background-repeat: space
      font-weight: 1000
      letter-spacing: .05rem
      overflow: hidden
      padding: .35rem .5rem .25rem
      text-overflow: ellipsis
      vertical-align: middle
      white-space: nowrap

      &.primary
        background-color: rgba(0, 255, 0, .3)
        color: #00ff00

      &.secondary
        background-color: rgba(255, 128, 0, .3)
        color: #ff8000

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
          font-size: 1.2rem
          margin-left: 1.5rem

          &.music-pause
            opacity: .5

          &.music-play
            opacity: .8

        .game-music-next
          color: $sp-primary
          font-size: 1.5rem
          margin-left: .75rem
          opacity: .5

        .game-music-volume
          color: $sp-primary
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
