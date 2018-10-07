<template lang='haml'>
%no-ssr
  #overlay-menu{'v-show':'show_overlay_menu', 'v-cloak':true}
    .dropdown.is-up.is-hoverable
      .dropdown-trigger
        %button.button.is-starpeace{'aria-haspopup':'true', 'aria-controls':'overlays'}
          %span {{current_overlay.label}}
          %span.icon.is-small
            %font-awesome-icon{':icon':"['fas', 'angle-up']"}
      #overlays.dropdown-menu{role:'menu'}
        .dropdown-content
          %a.dropdown-item{'v-for':'overlay in overlays()', 'v-bind:class':'overlay_item_css_class(overlay)', 'v-on:click.stop.prevent':'change_overlay(overlay)', href:'#'}
            %span {{overlay.label}}
    #flag-losing
      %span{'v-on:click.stop.prevent':'toggle_losing_facilities()'}
        Signal Losing Facilities:
      .toggle-icons
        %a.toggle-on{href:'#', 'v-show':"show_losing_facilities", 'v-on:click.stop.prevent':'toggle_losing_facilities()'}
          %font-awesome-icon{':icon':"['fas', 'toggle-on']"}
        %a.toggle-off{href:'#', 'v-show':"!show_losing_facilities", 'v-on:click.stop.prevent':'toggle_losing_facilities()'}
          %font-awesome-icon{':icon':"['fas', 'toggle-off']"}
</template>

<script lang='coffee'>
import Overlay from '~/plugins/starpeace-client/map/types/overlay.coffee'

export default
  props:
    ui_state: Object

  computed:
    show_overlay_menu: -> @ui_state?.show_overlay || false
    current_overlay: -> @ui_state?.current_overlay || Overlay.TYPES.NONE
    current_overlay_value: -> @current_overlay.type

    show_losing_facilities: -> @ui_state?.show_losing_facilities || false
  methods:
    overlays: ->
      overlays = []
      for key,overlay of Overlay.TYPES
        overlays.push(overlay) unless key == 'NONE' || key == 'ZONES'
      overlays

    overlay_item_css_class: (overlay) -> { 'is-active': @ui_state?.current_overlay?.type == overlay.type }
    change_overlay: (overlay) -> @ui_state.current_overlay = overlay

    toggle_losing_facilities: () -> @ui_state.show_losing_facilities = !@ui_state.show_losing_facilities
</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

#overlay-menu
  background-color: #000
  grid-column-start: 1
  grid-column-end: 1
  grid-row-start: 3
  grid-row-end: 3
  padding: .5rem .25rem
  min-width: 28rem
  z-index: 1125

button
  justify-content: flex-start
  width: 13.5rem

  .icon
    position: absolute
    right: .75rem

.dropdown-menu
  min-width: 13.5rem
  width: 13.5rem


#flag-losing
  color: $sp-primary
  display: inline-block
  padding: 0 0 0 .75rem

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
