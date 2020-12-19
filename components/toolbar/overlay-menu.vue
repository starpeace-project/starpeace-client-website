<template lang='pug'>
#overlay-menu(v-show='show_overlay_menu', v-cloak=true)
  .dropdown.is-up.is-hoverable
    .dropdown-trigger
      button.button.is-starpeace(aria-haspopup='true', aria-controls='overlays')
        span {{translate(current_overlay.label_key)}}
        span.icon.is-small
          font-awesome-icon(:icon="['fas', 'angle-up']")

    #overlays.dropdown-menu(role='menu')
      .dropdown-content
        a.dropdown-item(v-for='overlay in overlays()' :class='overlay_item_css_class(overlay)' @click.stop.prevent='change_overlay(overlay)')
          span {{translate(overlay.label_key)}}

  #flag-losing
    span(v-on:click.stop.prevent='toggle_losing_facilities()')
      | {{translate('overlay.signal_losing.label')}}:
    .toggle-icons
      a.toggle-on(v-show="show_losing_facilities" @click.stop.prevent='toggle_losing_facilities()')
        font-awesome-icon(:icon="['fas', 'toggle-on']")
      a.toggle-off(v-show="!show_losing_facilities" @click.stop.prevent='toggle_losing_facilities()')
        font-awesome-icon(:icon="['fas', 'toggle-off']")

</template>

<script lang='coffee'>
import Overlay from '~/plugins/starpeace-client/overlay/overlay.coffee'

export default
  props:
    managers: Object
    client_state: Object

  data: ->
    interface_state: @client_state?.interface

  computed:
    show_overlay_menu: -> if @interface_state?.show_overlay? then @interface_state.show_overlay else false
    current_overlay: -> if @interface_state?.current_overlay? then @interface_state.current_overlay else Overlay.TYPES.NONE
    current_overlay_value: -> @current_overlay.type

    show_losing_facilities: -> if @interface_state?.show_losing_facilities? then @interface_state?.show_losing_facilities else false

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    overlays: ->
      overlays = []
      for key,overlay of Overlay.TYPES
        overlays.push(overlay) unless key == 'NONE' || key == 'ZONES'
      overlays

    overlay_item_css_class: (overlay) -> { 'is-active': @current_overlay_value == overlay.type }
    change_overlay: (overlay) -> @interface_state?.current_overlay = overlay

    toggle_losing_facilities: () -> @interface_state.show_losing_facilities = !@interface_state.show_losing_facilities
</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

#overlay-menu
  background-color: #000
  grid-column-start: 1
  grid-column-end: 2
  grid-row-start: 3
  grid-row-end: 3
  padding: .5rem .25rem
  min-width: 38rem
  z-index: 1125

.dropdown-trigger
  button
    justify-content: flex-start
    width: 16rem

    .icon
      position: absolute
      right: .75rem

.dropdown-menu
  min-width: 16rem
  width: 16rem

#flag-losing
  color: $sp-primary
  display: inline-block
  padding: 0 0 0 .75rem
  text-align: center
  width: 21rem

  span
    line-height: 2rem

  .toggle-icons
    cursor: pointer
    display: inline-block
    font-size: 1.5rem
    line-height: 2rem
    margin-left: .5rem
    vertical-align: bottom

    a
      &:hover,
      &:active
        color: lighten(#6ea192, 5%)

    .toggle-on
      color: #fff
      font-weight: 1000

      &:hover,
      &:active
        color: #fff

    .toggle-off
      color: $sp-primary

</style>
