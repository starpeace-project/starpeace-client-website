<template lang='haml'>
.card.has-header
  .card-header
    .card-header-title
      Map Locations
    .card-header-icon.card-close{'v-on:click.stop.prevent':'menu_state.toggle_menu_favorites()'}
      %font-awesome-icon{':icon':"['fas', 'times']"}

  .card-content
</template>

<script lang='coffee'>
export default
  props:
    menu_state: Object
</script>

<style lang='sass' scoped>
.card
  height: 100%
  max-width: 25rem
  overflow: hidden
  position: absolute
  width: 100%
  z-index: 1050

  .card-content
    height: calc(100% - 3.2rem)

</style>
