<template lang='pug'>
#render-parent-container(v-show='is_ready' v-cloak=true oncontextmenu='return false')
  #fps-container(v-show='show_fps')
  #render-container(:class='render_css_class')
</template>

<script lang='coffee'>
export default
  props:
    client_state: Object

  mounted: ->
    @client_state.options?.subscribe_options_listener =>
      @show_fps = @client_state.options?.option('general.show_fps')

  data: ->
    show_fps: @client_state.options?.option('general.show_fps')

  computed:
    is_ready: -> @client_state.initialized && @client_state.workflow_status == 'ready'
    is_construction_mode: -> if @is_ready then @client_state.interface.construction_building_id?.length else false

    render_css_class: ->
      classes = []
      classes.push 'construction-mode' if @is_construction_mode
      classes
</script>

<style lang='sass' scoped>
#render-parent-container
  grid-column: 1 / 4
  grid-row: start-render / end-toolbar
  position: relative

#fps-container
  position: absolute
  right: 9.25rem
  top: .5rem
  z-index: 1015

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
