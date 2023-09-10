<template lang='pug'>
#render-parent-container(v-show='is_ready' v-cloak=true oncontextmenu='return false')
  #fps-container(v-show='show_fps')
  #render-container(:class="{'construction-mode': is_construction_mode}" :data-disable-right-click='$config.public.disableRightClick')
</template>

<script lang='ts'>
import ClientState from '~/plugins/starpeace-client/state/client-state.coffee';

export default {
  props: {
    client_state: { type: ClientState, required: true }
  },

  data () {
    return {
      show_fps: this.client_state.options?.option('general.show_fps') ?? true
    };
  },

  mounted () {
    this.client_state.options?.subscribe_options_listener(() => {
      this.show_fps = this.client_state.options?.option('general.show_fps') ?? true;
    });
  },

  computed: {
    is_ready (): boolean { return this.client_state.initialized && this.client_state.workflow_status == 'ready'; },
    is_construction_mode (): boolean { return this.is_ready && this.client_state.interface.construction_building_id?.length > 0; }
  }
}
</script>

<style lang='sass' scoped>
#render-parent-container
  grid-column: 1 / 4
  grid-row: start-render / end-toolbar
  position: relative

#fps-container
  position: absolute
  right: .5rem
  top: .5rem
  z-index: 1015

  :deep(div)
    position: unset !important

#render-container
  height: calc(100% - 16rem)
  left: 0
  position: absolute
  top: 0
  width: 100%
  z-index: 1000

  &.construction-mode
    cursor: crosshair

</style>
