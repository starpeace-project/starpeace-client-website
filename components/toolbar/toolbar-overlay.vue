<template lang='pug'>
#overlay-menu(v-show='show_overlay_menu' v-cloak=true :oncontextmenu="'return ' + !$config.public.disableRightClick")
  .dropdown.is-up.is-hoverable
    .dropdown-trigger
      button.button.is-starpeace(aria-haspopup='true', aria-controls='overlays')
        span {{$translate(current_overlay.label_key)}}
        span.icon.is-small
          font-awesome-icon(:icon="['fas', 'angle-up']")

    #overlays.dropdown-menu(role='menu')
      .dropdown-content
        a.dropdown-item(v-for='overlay in overlays()' :class='overlay_item_css_class(overlay)' @click.stop.prevent='change_overlay(overlay)')
          span {{$translate(overlay.label_key)}}

  #flag-losing
    span(v-on:click.stop.prevent='toggle_losing_facilities()')
      | {{$translate('overlay.signal_losing.label')}}:
    .toggle-icons
      a.toggle-on(v-show="show_losing_facilities" @click.stop.prevent='toggle_losing_facilities()')
        font-awesome-icon(:icon="['fas', 'toggle-on']")
      a.toggle-off(v-show="!show_losing_facilities" @click.stop.prevent='toggle_losing_facilities()')
        font-awesome-icon(:icon="['fas', 'toggle-off']")

</template>

<script lang='ts'>
import Overlay from '~/plugins/starpeace-client/overlay/overlay.coffee';
import ClientState from '~/plugins/starpeace-client/state/client-state.coffee';

export default {
  props: {
    client_state: { type: ClientState, required: true }
  },

  computed: {
    show_overlay_menu () { return this.client_state.interface?.show_overlay ? this.client_state.interface.show_overlay : false; },
    current_overlay () { return this.client_state.interface?.current_overlay ? this.client_state.interface.current_overlay : Overlay.TYPES.NONE; },
    current_overlay_value () { return this.current_overlay.type; },

    show_losing_facilities () { return this.client_state.interface?.show_losing_facilities ? this.client_state.interface?.show_losing_facilities : false; }
  },

  methods: {
    overlays () {
      const overlays = [];
      for (const [key, overlay] of Object.entries(Overlay.TYPES)) {
        if (key !== 'NONE' && key !== 'ZONES') {
          overlays.push(overlay);
        }
      }
      return overlays;
    },

    overlay_item_css_class (overlay: Overlay): Record<string, boolean> {
      return { 'is-active': this.current_overlay_value == overlay.type };
    },
    change_overlay (overlay: Overlay): void {
      this.client_state.interface.current_overlay = overlay;
    },

    toggle_losing_facilities () {
      this.client_state.interface.show_losing_facilities = !this.client_state.interface.show_losing_facilities;
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

#overlay-menu
  background-color: #000
  grid-column: start-left / end-left
  grid-row: start-overlay / end-overlay
  padding: .5rem .25rem
  min-width: 38rem
  pointer-events: auto
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
