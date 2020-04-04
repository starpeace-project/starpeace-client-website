<template lang='pug'>
client-only
  transition(name='fade')
    #toolbar-ribbon(v-show='is_ready', v-cloak='true')
      table.table.row-inspect(v-cloak=true)
        tbody
          tr
            td.column-camera-controls
              a.button.is-starpeace.is-small(v-on:click.stop.prevent='client_state.camera.camera_zoom_in()')
                font-awesome-icon(:icon="['fas', 'plus']")
            td.column-camera-controls
              a.button.is-starpeace.is-small(v-on:click.stop.prevent='client_state.camera.camera_zoom_out()')
                font-awesome-icon(:icon="['fas', 'minus']")
            td.column-overlays
              a.button.is-starpeace.is-starpeace-light.is-small(:class='menu_class_overlay', v-on:click.stop.prevent='interface_state.toggle_overlay()')
                | {{translate('footer.ribbon.overlay')}}
            td.column-inspect(rowspan=2)
              a.button.is-starpeace.is-starpeace-light.is-small
                | {{translate('footer.ribbon.inspect')}}
            td.column-details-ticker.primary
              | {{translate('footer.ribbon.message.welcome')}}
            toolbar-minimap(:client_state='client_state')

          tr
            td.column-camera-controls
              a.button.is-starpeace.is-small
                font-awesome-icon(:icon="['fas', 'redo-alt']")
            td.column-camera-controls
              a.button.is-starpeace.is-small
                font-awesome-icon(:icon="['fas', 'undo-alt']")
            td.column-overlays
              a.button.is-starpeace.is-starpeace-light.is-small(:class='menu_class_zones', v-on:click.stop.prevent='interface_state.toggle_zones()')
                | {{translate('footer.ribbon.city_zones')}}
            td.column-details-ticker.secondary
              | {{translate('footer.ribbon.hint.tycoon')}}

</template>

<script lang='coffee'>
import ToolbarMinimap from '~/components/toolbar/toolbar-minimap.vue'

export default
  props:
    client_state: Object
    managers: Object

  components:
    'toolbar-minimap': ToolbarMinimap

  computed:
    interface_state: -> @client_state.interface
    is_ready: -> @client_state.initialized && @client_state?.workflow_status == 'ready'

    menu_class_overlay: -> { 'is-active': @interface_state?.show_overlay || false }
    menu_class_zones: -> { 'is-active': @interface_state?.show_zones || false }

  methods:
    translate: (key) -> if @managers? then @managers.translation_manager.text(key) else key
</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

.button
  &.is-starpeace
    &.is-small
      font-size: .875rem
      line-height: 1.5
      border-radius: .2rem

#toolbar-ribbon
  grid-column-start: 1
  grid-column-end: 3
  grid-row-start: 4
  grid-row-end: 5
  margin: 0

  table
    height: 100%
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
