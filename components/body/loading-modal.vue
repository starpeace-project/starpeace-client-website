<template lang='haml'>
#loading-modal{'v-show':'is_loading && is_ready'}
</template>

<script lang='coffee'>
export default
  props:
    game_state: Object

  computed:
    is_ready: -> @game_state?.initialized || false
    is_loading: -> @game_state?.loading || false
</script>

<style lang='sass' scoped>
#loading-modal
  background-color: #000
  grid-column-start: 1
  grid-column-end: 4
  grid-row-start: 2
  grid-row-end: 5
  opacity: .5
  z-index: 1045


</style>
