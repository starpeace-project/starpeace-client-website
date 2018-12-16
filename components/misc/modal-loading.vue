<template lang='haml'>
#loading-modal{'v-show':'is_visible'}
</template>

<script lang='coffee'>
export default
  props:
    client_state: Object

  computed:
    is_visible: -> (@client_state?.initialized || false) && (@client_state?.loading || false)
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
