<template lang='haml'>
%transition{name:'fade'}
  #render-parent-container{'v-show':'is_ready', 'v-cloak':true}
    #fps-container{'v-show':'show_fps'}
    #render-container{':class':'render_css_class'}
</template>

<script lang='coffee'>
export default
  props:
    client_state: Object
    options: Object

  mounted: ->
    @options?.subscribe_options_listener =>
      @show_fps = @options?.option('general.show_fps')

  data: ->
    show_fps: @options?.option('general.show_fps')

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
  grid-column-start: 1
  grid-column-end: 4
  grid-row-start: 2
  grid-row-end: 4
  position: relative


#fps-container
  left: .5rem
  position: absolute
  top: .5rem
  z-index: 1015

#render-container
  height: 100%
  left: 0
  position: absolute
  top: 0
  width: 100%
  z-index: 1000

  &.construction-mode
    cursor: crosshair

</style>
