<template lang='pug'>
.inspect-container(v-show='show_inspect' :oncontextmenu="'return ' + !$config.public.disableRightClick")

  .inspect-preview.is-marginless
    #inspect-image-webgl-container(ref='previewContainer')

  template(v-if='!building_type')
    .loading-container
      img.loading-image.starpeace-logo.logo-loading

  template(v-else-if="building_type == 'PORTAL'")
    toolbar-inspect-portal(:client-state='client_state' :key='selected_building_id')

  template(v-else-if="building_type == 'TOWNHALL'")
    toolbar-inspect-townhall(:client-state='client_state' :key='selected_building_id')

  template(v-else-if="building_type == 'TRADECENTER'")
    toolbar-inspect-trade-center(
      :key='selected_building_id'
      :client-state='client_state'
      :building='selected_building'
      :definition='selected_building_definition'
      :simulation='selected_building_simulation'
    )

  template(v-else)
    toolbar-inspect-building(:client-state='client_state' :key='selected_building_id')

</template>

<script lang='ts'>
import ClientState from '~/plugins/starpeace-client/state/client-state.coffee';

export default {
  props: {
    client_state: { type: ClientState, required: true }
  },

  data () {
    return {
      tab_index: 0
    };
  },

  computed: {
    is_ready () { return this.client_state.initialized && this.client_state?.workflow_status == 'ready'; },

    show_inspect () { return this.client_state.interface?.selected_building_id?.length > 0 && this.client_state.interface?.show_inspect; },

    selected_building_id () { return this.client_state.interface?.selected_building_id; },
    selected_building () { return this.show_inspect ? this.client_state.core.building_cache.building_for_id(this.selected_building_id) : null; },
    selected_building_definition () { return this.selected_building ? this.client_state.core.building_library.definition_for_id(this.selected_building.definition_id) : null; },
    selected_building_simulation () { return this.selected_building ? this.client_state.core.building_library.simulation_definition_for_id(this.selected_building.definition_id) : null; },

    building_type () { return this.selected_building_simulation?.type; }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.inspect-container
  background-color: #000
  display: grid
  grid-column: start-left / end-render
  grid-row: start-inspect / end-inspect
  grid-template-columns: [start-preview] 10rem [end-preview start-details] auto [end-details]
  grid-template-rows: auto
  pointer-events: auto
  position: relative
  z-index: 1050

.inspect-preview
  border-right: 1px solid $sp-primary-bg
  grid-column: start-preview / end-preview
  grid-row: 1 / 2
  position: relative

#inspect-image-webgl-container
  left: 0
  position: absolute
  height: 100%
  top: 0
  width: 100%

.loading-container
  grid-column: start-details / end-details
  grid-row: 1 / 2
  position: relative

  .loading-image
    background-size: 8rem
    height: 8rem
    left: calc(50% - 4rem)
    margin: 1rem 0
    position: absolute
    top: calc(40% - 4rem)
    width: 8rem

</style>
