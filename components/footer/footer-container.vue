sp-primary-color<template lang='haml'>
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

            %td.column-mini-map{rowspan: 2, 'v-show':'ui_state.show_mini_map', 'v-bind:style':'mini_map_column_css_style'}
              #mini-map-container{'v-bind:style':'mini_map_container_css_style'}
                #mini-map-webgl-container
                %a.zoom.zoom-out{'v-on:click.stop.prevent':'mini_map_renderer.zoom_in()'}
                  %font-awesome-icon{':icon':"['fas', 'plus']"}
                %a.zoom.zoom-in{'v-on:click.stop.prevent':'mini_map_renderer.zoom_out()'}
                  %font-awesome-icon{':icon':"['fas', 'minus']"}

          %tr
            %td.column-camera-controls
              %a.button.is-starpeace.is-small
                %font-awesome-icon{':icon':"['fas', 'redo-alt']"}
            %td.column-camera-controls
              %a.button.is-starpeace.is-small
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
            %td.column-menu
              %a.button.is-starpeace.is-small.tooltip{'v-bind:class':'menu_class_planetary', 'v-on:click.stop.prevent':'menu_state.toggle_menu_planetary()', 'data-tooltip':'Planetary Systems'}
                %font-awesome-icon{':icon':"['fas', 'globe']"}
              %a.button.is-starpeace.is-small.tooltip{'v-bind:class':'menu_class_favorites', 'v-on:click.stop.prevent':'menu_state.toggle_menu_favorites()', 'data-tooltip':'Map Locations'}
                %font-awesome-icon{':icon':"['fas', 'map-pin']"}
              %a.button.is-starpeace.is-small.tooltip{'v-on:click.stop.prevent':'menu_state.hide_all_menus()', 'data-tooltip':'Hide Menus'}
                %font-awesome-icon{':icon':"['far', 'eye']"}
              %a.button.is-starpeace.is-small.tooltip{'v-bind:class':'menu_class_tycoon', 'v-on:click.stop.prevent':'menu_state.toggle_menu_tycoon()', 'data-tooltip':'Tycoon Details'}
                %font-awesome-icon{':icon':"['fas', 'user-tie']"}
              %a.button.is-starpeace.is-small.tooltip{'v-bind:class':'menu_class_building', 'v-on:click.stop.prevent':'menu_state.toggle_menu_building()', 'data-tooltip':'Construction'}
                %font-awesome-icon{':icon':"['fas', 'toolbox']"}
              %a.button.is-starpeace.is-small.tooltip{'v-bind:class':'menu_class_mail', 'v-on:click.stop.prevent':'menu_state.toggle_menu_mail()', 'data-tooltip':'Mail'}
                %font-awesome-icon{':icon':"['far', 'envelope']"}
              %a.button.is-starpeace.is-small.tooltip{'v-bind:class':'menu_class_chat', 'v-on:click.stop.prevent':'menu_state.toggle_menu_chat()', 'data-tooltip':'Chat'}
                %font-awesome-icon{':icon':"['far', 'comments']"}
              %a.button.is-starpeace.is-small.tooltip{'v-bind:class':'menu_class_options', 'v-on:click.stop.prevent':'menu_state.toggle_menu_options()', 'data-tooltip':'Options'}
                %font-awesome-icon{':icon':"['fas', 'cogs']"}
              %a.button.is-starpeace.is-small.tooltip{'v-bind:class':'menu_class_help', 'v-on:click.stop.prevent':'menu_state.toggle_menu_help()', 'data-tooltip':'Help'}
                %font-awesome-icon{':icon':"['far', 'question-circle']"}

            %td.column-tycoon
              %span.column-tycoon-name
                Visitor
              %span.column-tycoon-buildings.sp-primary-color
                %span.count 0 / 0
                %font-awesome-icon{':icon':"['far', 'building']"}

              .column-notification-icons.level
                .level-item.client-version
                  %a{'v-bind:class':'menu_class_release_notes', 'v-on:click.stop.prevent':'menu_state.toggle_menu_release_notes()'} {{client_version}}

                .level-item.game-music.sp-primary-color{'v-bind:class':'game_music_class', 'v-show':"ui_state.game_music"}
                  %font-awesome-icon{':icon':"['fas', 'play']", 'v-show':'!game_state.game_music_playing', 'v-on:click.stop.prevent':'toggle_game_music()'}
                  %font-awesome-icon{':icon':"['fas', 'pause']", 'v-show':'game_state.game_music_playing', 'v-on:click.stop.prevent':'toggle_game_music()'}
                .level-item.game-music-next.sp-primary-color{'v-bind:class':'game_music_volume_class', 'v-show':"ui_state.game_music"}
                  %font-awesome-icon{':icon':"['fas', 'fast-forward']", 'v-on:click.stop.prevent':'toggle_next_game_music()'}
                .level-item.game-music-volume.sp-primary-color{'v-bind:class':'game_music_volume_class', 'v-show':"ui_state.game_music"}
                  %font-awesome-icon{':icon':"['fas', 'volume-up']", 'v-show':'game_state.game_music_volume', 'v-on:click.stop.prevent':'toggle_game_music_volume()'}
                  %font-awesome-icon{':icon':"['fas', 'volume-off']", 'v-show':'!game_state.game_music_volume', 'v-on:click.stop.prevent':'toggle_game_music_volume()'}

                .level-item.notification-mail.sp-primary-color
                  %font-awesome-icon{':icon':"['far', 'envelope']"}

                .level-item.notification-loading
                  %img.starpeace-logo{'v-bind:class':'notification_loading_css_class'}

          %tr
            %td.column-news-ticker.sp-primary-color {{ ticker_message }}

            %td.column-tycoon-details
              %table
                %tbody
                  %tr
                    %td.column-tycoon-corporation
                      [VISITOR VISA]
                  %tr
                    %td.column-tycoon-cash.sp-primary-color
                      $0
                  %tr
                    %td.column-tycoon-cashflow.sp-primary-color
                      ($0/h)
                  %tr
                    %td.column-date.sp-primary-color {{ current_date }}
</template>

<script lang='coffee'>
import interact from 'interactjs'
import moment from 'moment'

MIN_MINI_MAP_WIDTH = 300
MIN_MINI_MAP_HEIGHT = 200

export default
  props:
    camera_manager: Object
    game_state: Object
    menu_state: Object
    mini_map_renderer: Object
    music_manager: Object
    ui_state: Object

  data: ->
    client_version: process.env.CLIENT_VERSION

  updated: ->
    element = @.$el.querySelector('#mini-map-container') if process.browser
    return unless element? && !element.dataset.interactSetup?

    interact(element)
      .resizable({
        edges: { left: true, right: false, bottom: false, top: true }
        inertia: true
        restrictSize: {
          min: {
            width: MIN_MINI_MAP_WIDTH
            height: MIN_MINI_MAP_HEIGHT
          }
        }
      })
      .on('resizemove', (event) =>
        @ui_state.update_mini_map(event.rect.width, event.rect.height)
      )
    element.dataset.interactSetup = true

  computed:
    is_ready: -> @game_state?.initialized
    ticker_message: -> @ui_state?.event_ticker_message || ''
    current_date: -> moment(@game_state?.current_date).format('MMM D, YYYY')

    menu_class_overlay: -> { 'is-active': @ui_state?.show_overlay || false }
    menu_class_zones: -> { 'is-active': @ui_state?.show_zones || false }
    menu_class_planetary: -> { 'is-active': @menu_state?.main_menu == 'planetary' }
    menu_class_favorites: -> { 'is-active': @menu_state?.show_menu_favorites || false }
    menu_class_tycoon: -> { 'is-active': @menu_state?.main_menu == 'tycoon' }
    menu_class_building: -> { 'is-active': @menu_state?.main_menu == 'building' }
    menu_class_mail: -> { 'is-active': @menu_state?.main_menu == 'mail' }
    menu_class_chat: -> { 'is-active': @menu_state?.main_menu == 'chat' }
    menu_class_options: -> { 'is-active': @menu_state?.main_menu == 'options' }
    menu_class_help: -> { 'is-active': @menu_state?.main_menu == 'help' }
    menu_class_release_notes: -> { 'is-active': @menu_state?.show_menu_release_notes || false }

    game_music_class: -> if @game_state.game_music_playing then 'music-pause' else 'music-play'
    game_music_volume_class: -> if @game_state.game_music_volume then 'music-volume' else 'music-mute'

    notification_loading_css_class: -> { 'ajax-loading': (@game_state?.ajax_requests || 0) > 0 }

    mini_map_column_css_style: -> "width:#{@ui_state.mini_map_width}px"
    mini_map_container_css_style: -> "width:#{@ui_state.mini_map_width}px;height:#{@ui_state.mini_map_height}px"
  methods:
    toggle_zones: -> @ui_state.show_zones = !@ui_state.show_zones

    toggle_game_music: -> @music_manager.toggle_music()
    toggle_next_game_music: -> @music_manager.next_song()
    toggle_game_music_volume: -> @music_manager.toggle_volume()
</script>

<style lang='sass' scoped>
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

    .column-mini-map
      position: relative

      #mini-map-container
        background-color: #000
        bottom: 0
        min-height: 200px
        min-width: 300px
        padding: 6px
        position: absolute
        right: 0
        z-index: 1050

        #mini-map-webgl-container
          height: 100%
          width: 100%

        .zoom
          background-color: #000
          color: #FFF
          bottom: 5px
          padding: .25rem .75rem 0
          position: absolute

        .zoom-out
          left: 5px

        .zoom-in
          right: 5px


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

    .column-menu
      background: linear-gradient(to top, #395950, #000)
      max-width: 32rem
      padding: .25rem
      text-align: center
      width: 32rem

      .button
        height: 2.5rem
        font-size: 1.25rem
        padding: 0 .65rem

        &:not(:first-child)
          margin-left: .5rem

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
          font-size: 1.2rem
          margin-left: 1.5rem

          &.music-pause
            opacity: .5

          &.music-play
            opacity: .8

        .game-music-next
          font-size: 1.5rem
          margin-left: .75rem
          opacity: .5

        .game-music-volume
          font-size: 1.5rem
          margin-left: .5rem
          min-width: 1.75rem
          opacity: .5

        .notification-mail
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
        font-size: 1.5rem
        font-weight: 1000
        line-height: 1.25rem

      .column-tycoon-cashflow
        padding-bottom: 0
        padding-top: .25rem
        vertical-align: bottom

      .column-date
        padding-top: 0
        padding-bottom: 1rem
        vertical-align: top

    .column-news-ticker
      background-color: #2a453f
      font-size: .85rem
      font-weight: 1000
      height: 6rem
      padding: .5rem

</style>
