<template lang='pug'>
#mini-map-container(ref='mini_map_container' v-show='is_ready && show_mini_map' :style='mini_map_container_css_style' :oncontextmenu="'return ' + !$config.public.disableRightClick")
  #mini-map-webgl-container
  a.zoom.zoom-out(@click.stop.prevent='client_state.interface.mini_map_zoom_in()')
    font-awesome-icon(:icon="['fas', 'plus']")
  a.zoom.zoom-in(@click.stop.prevent='client_state.interface.mini_map_zoom_out()')
    font-awesome-icon(:icon="['fas', 'minus']")
</template>

<script lang='ts'>
import interact from 'interactjs';
import ClientState from '~/plugins/starpeace-client/state/client-state';

const MIN_MINI_MAP_WIDTH = 300;
const MIN_MINI_MAP_HEIGHT = 200;

export default {
  props: {
    client_state: { type: ClientState, required: true }
  },

  data () {
    return {
      show_mini_map: this.client_state.options?.option('general.show_mini_map'),
      mini_map_width: this.client_state.options?.option('mini_map.width'),
      mini_map_height: this.client_state.options?.option('mini_map.height')
    };
  },

  mounted () {
    this.client_state?.options?.subscribe_options_listener(() => {
      this.show_mini_map = this.client_state.options?.option('general.show_mini_map');
    });

    this.client_state?.interface?.subscribe_mini_map_size_listener(() => {
      this.mini_map_width = this.client_state.options?.option('mini_map.width');
      this.mini_map_height = this.client_state.options?.option('mini_map.height');
    });

    if (this.$refs.mini_map_container && !this.$refs.mini_map_container.dataset.interactSetup) {
      interact(this.$refs.mini_map_container)
        .resizable({
          edges: { left: true, right: false, bottom: false, top: true },
          inertia: true,
          modifiers: [
            interact.modifiers.restrictSize({
              min: {
                width: MIN_MINI_MAP_WIDTH,
                height: MIN_MINI_MAP_HEIGHT
              }
            })
          ]
        })
        .on('resizemove', (event) => {
          this.client_state.interface.update_mini_map(event.rect.width, event.rect.height);
        });
      this.$refs.mini_map_container.dataset.interactSetup = true;
    }
  },

  computed: {
    is_ready () { return this.client_state.initialized && this.client_state?.workflow_status === 'ready'; },

    mini_map_column_css_style () { return `width:${this.mini_map_width}px`; },
    mini_map_container_css_style () { return `width:${this.mini_map_width}px;height:${this.mini_map_height}px`; }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

#mini-map-container
  background-color: #000
  grid-column: start-render / end-render
  grid-row: start-overlay / end-overlay
  justify-self: end
  align-self: end
  min-height: 200px
  min-width: 300px
  padding: 6px
  position: relative
  pointer-events: auto
  touch-action: none
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
    touch-action: unset

  .zoom-out
    left: 5px

  .zoom-in
    right: 5px

</style>
