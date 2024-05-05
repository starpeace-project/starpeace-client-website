<template lang='pug'>
#toolbar-ribbon(v-show='is_ready' v-cloak='true' :oncontextmenu="'return ' + !$config.public.disableRightClick")
  .action-camera-in
    button.button.is-fullwidth.is-fullheight.is-small.is-starpeace(@click.stop.prevent='client_state.camera.camera_zoom_in()')
      font-awesome-icon(:icon="['fas', 'plus']")
  .action-camera-out
    button.button.is-fullwidth.is-fullheight.is-small.is-starpeace(@click.stop.prevent='client_state.camera.camera_zoom_out()')
      font-awesome-icon(:icon="['fas', 'minus']")

  .action-rotate-ccw
    button.button.is-fullwidth.is-fullheight.is-small.is-starpeace
      font-awesome-icon(:icon="['fas', 'redo-alt']")
  .action-rotate-cw
    button.button.is-fullwidth.is-fullheight.is-small.is-starpeace
      font-awesome-icon(:icon="['fas', 'undo-alt']")

  .action-overlays
    button.button.is-fullwidth.is-fullheight.is-small.is-uppercase.is-light(:class="{ 'is-active': show_overlay }" @click.stop.prevent='toggle_overlay()')
      | {{$translate('footer.ribbon.overlay')}}
  .action-zones
    button.button.is-fullwidth.is-fullheight.is-small.is-uppercase.is-light(:class="{ 'is-active': show_zones }" @click.stop.prevent='toggle_zones')
      | {{$translate('footer.ribbon.city_zones')}}

  .action-inspect
    button.button.is-fullwidth.is-fullheight.is-small.is-uppercase.is-light.is-transitionless(:class="{ 'is-active': show_inspect }" :disabled='!can_inspect' @click.stop.prevent='toggle_inspect')
      | {{ $translate('footer.ribbon.inspect') }}

  .details-ticker.primary
    | {{$translate('footer.ribbon.message.welcome')}}
  .details-ticker.secondary
    | {{$translate('footer.ribbon.hint.tycoon')}}

  .action-jump-back
    button.button.is-fullwidth.is-fullheight.is-small.is-uppercase.is-starpeace(:disabled='!can_jump_back' @click.stop.prevent='jump_back')
      font-awesome-icon(:icon="['fas', 'chevron-left']")
      | {{$translate('footer.ribbon.jump_back')}}
  .action-jump-next
    button.button.is-fullwidth.is-fullheight.is-small.is-uppercase.is-starpeace(:disabled='!can_jump_next' @click.stop.prevent='jump_next')
      | {{$translate('footer.ribbon.jump_next')}}
      font-awesome-icon(:icon="['fas', 'chevron-right']")
  .action-jump-town
    button.button.is-fullwidth.is-fullheight.is-small.is-uppercase.is-starpeace(@click.stop.prevent='jump_town')
      | {{$translate('footer.ribbon.jump_town')}}

</template>

<script lang='ts'>
import _ from 'lodash';
import ClientState from '~/plugins/starpeace-client/state/client-state';

export default {
  props: {
    client_state: { type: ClientState, required: true }
  },

  computed: {
    is_ready () { return this.client_state.initialized && this.client_state?.workflow_status === 'ready'; },

    show_overlay () { return this.client_state.interface?.show_overlay ?? false; },
    show_zones () { return this.client_state.interface?.show_zones ?? false; },
    show_inspect () { return this.client_state.interface?.show_inspect ?? false; },

    can_inspect () {
      return this.client_state.interface?.selected_building_id?.length && !!this.client_state.selected_building();
    },
    can_jump_back () {
      if (!_.isNumber(this.client_state.camera.view_offset_x) || !_.isNumber(this.client_state.camera.view_offset_y) || !this.client_state.interface.location_history.length) return false;
      if (this.client_state.interface.location_index < this.client_state.interface.location_history.length - 1) return true;
      const location = this.client_state.current_location();
      if (!location) return false;
      return !this.client_state.matches_jump_history(location.i, location.j);
    },
    can_jump_next () { return this.client_state.interface.location_index > 0; }
  },

  methods: {
    toggle_overlay () { this.client_state.interface.toggle_overlay(); },
    toggle_zones () { this.client_state.interface.toggle_zones(); },
    toggle_inspect () {
      if (this.can_inspect) {
        this.client_state.interface.toggle_inspect();
      }
    },

    jump_back () {
      if (this.can_jump_back) {
        this.client_state.jump_back();
      }
    },
    jump_next () {
      if (this.can_jump_next) {
        this.client_state.jump_next();
      }
    },
    jump_town () {
      const town = this.client_state.town_for_location();
      if (town?.building_id && _.isNumber(town?.map_x) && _.isNumber(town?.map_y)) {
        this.client_state.jump_to(town.map_x, town.map_y, town.building_id);
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.button
  &.is-starpeace
    &.is-small
      font-size: .875rem
      line-height: 1.5
      border-radius: .2rem

  &.is-fullheight
    height: 100%

#toolbar-ribbon
  background-color: #000
  display: grid
  grid-column: start-left / end-render
  grid-row: start-ribbon / end-ribbon
  grid-template-columns: [start-camera-1] 3rem [end-camera-1 start-camera-2] 3rem [end-camera-2 start-overlay] min-content [end-overlay start-inspect] min-content [end-inspect start-ticker] auto [end-ticker start-jump-1] 9rem [end-jump-1 start-jump-2] 9rem [end-jump-2]
  grid-template-rows: [start-row-1] 50% [end-row-1 start-row-2] 50% [end-row-2]
  margin: 0
  pointer-events: auto
  z-index: 1050

  .action-camera-in
    grid-area: start-row-1 / start-camera-1 / end-row-1 / end-camera-1
    padding: .25rem .125rem .125rem
  .action-camera-out
    grid-area: start-row-1 / start-camera-2 / end-row-1 / end-camera-2
    padding: .25rem .125rem .125rem

  .action-rotate-ccw
    grid-area: start-row-2 / start-camera-1 / end-row-2 / end-camera-1
    padding: .125rem
    .fa-redo-alt
      transform: rotate(-20deg)
  .action-rotate-cw
    grid-area: start-row-2 / start-camera-2 / end-row-2 / end-camera-2
    padding: .125rem
    .fa-undo-alt
      transform: rotate(20deg)

  .action-overlays
    grid-area: start-row-1 / start-overlay / end-row-1 / end-overlay
    padding: .25rem .125rem .125rem

    .button
      letter-spacing: .1rem

  .action-zones
    grid-area: start-row-2 / start-overlay / end-row-2 / end-overlay
    padding: .125rem

    .button
      letter-spacing: .1rem

  .action-inspect
    grid-area: start-row-1 / start-inspect / end-row-2 / end-inspect
    padding: .25rem .125rem .125rem

    .button
      font-size: 1.25rem
      font-weight: 750
      letter-spacing: .2rem

  .details-ticker
    align-items: center
    background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAMAAAADCAYAAABWKLW/AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAEElEQVQI12NgYGD4z0AQAAAjBAEAIsfjuAAAAABJRU5ErkJggg==')
    background-repeat: space
    display: flex
    font-weight: 1000
    letter-spacing: .05rem
    overflow: hidden
    padding: .35rem .5rem .25rem
    text-overflow: ellipsis
    white-space: nowrap

    &.primary
      background-color: rgba(0, 255, 0, .3)
      color: #00ff00
      grid-area: start-row-1 / start-ticker / end-row-1 / end-ticker

    &.secondary
      background-color: rgba(255, 128, 0, .3)
      color: #ff8000
      grid-area: start-row-2 / start-ticker / end-row-2 / end-ticker

  .action-jump-back
    grid-area: start-row-1 / start-jump-1 / end-row-1 / end-jump-1
    padding: .125rem

    .button
      letter-spacing: .1rem

    .fa-chevron-left
      margin-right: .5rem

  .action-jump-next
    grid-area: start-row-1 / start-jump-2 / end-row-1 / end-jump-2
    padding: .125rem

    .button
      letter-spacing: .1rem

    .fa-chevron-right
      margin-left: .5rem

  .action-jump-town
    grid-area: start-row-2 / start-jump-1 / end-row-2 / end-jump-2
    padding: .125rem

    .button
      letter-spacing: .1rem


</style>
