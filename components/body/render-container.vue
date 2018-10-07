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
    options: Object
    ui_state: Object

  watch:
    state_counter: (new_value, old_value) ->
      @show_fps = @options?.option('general.show_fps')

  data: ->
    show_fps: @options?.option('general.show_fps')

  computed:
    state_counter: -> @options.vue_state_counter
    is_ready: -> @game_state.initialized

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

</style>
