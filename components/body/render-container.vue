<template lang='haml'>
%transition{name:'fade'}
  #render-parent-container{'v-show':'is_ready', 'v-cloak':true}
    #fps-container{'v-show':'show_fps'}
    #render-container
</template>

<script lang='coffee'>
export default
  props:
    game_state: Object
    ui_state: Object

  computed:
    is_ready: -> @game_state.initialized
    show_fps: -> @ui_state?.show_fps

</script>

<style lang='sass' scoped>
#render-parent-container
  grid-column-start: 1
  grid-column-end: 4
  grid-row-start: 2
  grid-row-end: 4
  position: relative

.no-header
  #render-parent-container
    grid-row-start: 1

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

</style>
