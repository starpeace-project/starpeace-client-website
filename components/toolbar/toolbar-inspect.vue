<template lang='pug'>
.inspect-container(v-show='show_inspect' oncontextmenu='return true')

  .inspect-preview.is-marginless
    #inspect-image-webgl-container(ref='previewContainer')

  template(v-if='!building_type')
    .loading-container
      img.loading-image.starpeace-logo.logo-loading

  template(v-else-if="building_type == 'PORTAL'")
    toolbar-inspect-portal(:client-state='client_state' :managers='managers' :key='selected_building_id')

  template(v-else-if="building_type == 'TOWNHALL'")
    toolbar-inspect-townhall(:client-state='client_state' :managers='managers' :key='selected_building_id')

  template(v-else-if="building_type == 'TRADECENTER'")
    toolbar-inspect-trade-center(
      :key='selected_building_id'
      :client-state='client_state'
      :managers='managers'
      :building='selected_building'
      :definition='selected_building_definition'
      :simulation='selected_building_simulation'
    )

  template(v-else)
    toolbar-inspect-building(:client-state='client_state' :managers='managers' :key='selected_building_id')

</template>

<script lang='coffee'>
import ToolbarInspectBuilding from '~/components/toolbar/inspect/toolbar-inspect-building.vue'
import ToolbarInspectPortal from '~/components/toolbar/inspect/toolbar-inspect-portal.vue'
import ToolbarInspectTownhall from '~/components/toolbar/inspect/toolbar-inspect-townhall.vue'
import ToolbarInspectTradeCenter from '~/components/toolbar/inspect/toolbar-inspect-trade-center.vue'

export default
  components: {
    ToolbarInspectBuilding
    ToolbarInspectPortal
    ToolbarInspectTownhall
    ToolbarInspectTradeCenter
  }

  props:
    client_state: Object
    managers: Object

  data: ->
    tab_index: 0

  computed:
    is_ready: -> @client_state.initialized && @client_state?.workflow_status == 'ready'

    show_inspect: -> @client_state.interface?.selected_building_id? && @client_state.interface?.show_inspect

    selected_building_id: -> @client_state.interface?.selected_building_id
    selected_building: -> if @show_inspect then @client_state.core.building_cache.building_for_id(@selected_building_id) else null
    selected_building_definition: -> if @selected_building then @client_state.core.building_library.definition_for_id(@selected_building.definition_id) else null
    selected_building_simulation: -> if @selected_building then @client_state.core.building_library.simulation_definition_for_id(@selected_building.definition_id) else null

    building_type: -> @selected_building_simulation?.type

  methods:
    translate: (key) -> if @managers? then @managers.translation_manager.text(key) else key

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

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
