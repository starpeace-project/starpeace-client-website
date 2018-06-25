<template lang='haml'>
.level-item
  .card.has-header
    .card-header
      .card-header-title
        Construction
      .card-header-icon.card-close{'v-on:click.stop.prevent':'menu_state.toggle_menu_building()'}
        %font-awesome-icon{':icon':"['fas', 'times']"}

    .card-content

</template>

<script lang='coffee'>
export default
  props:
    client: Object

  computed:
    menu_state: -> @client?.menu_state

</script>

<style lang='sass' scoped>
.card
  height: 100%
  max-width: 35rem
  overflow: hidden
  position: absolute
  right: 0
  width: 100%
  z-index: 1050

  .card-content
    height: calc(100% - 3.2rem)

</style>
