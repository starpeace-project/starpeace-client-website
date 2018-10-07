<template lang='haml'>
#construction-container.card.has-header
  .card-header
    .card-header-title
      Construction
    .card-header-icon.card-close{'v-on:click.stop.prevent':"menu_state.toggle_menu('construction')"}
      %font-awesome-icon{':icon':"['fas', 'times']"}

  .card-content.sp-menu-background

</template>

<script lang='coffee'>
export default
  props:
    menu_state: Object
</script>

<style lang='sass' scoped>

#construction-container
  grid-column-start: 3
  grid-row-start: 2
  grid-column-end: 4
  grid-row-end: 5
  overflow: hidden
  width: 30rem
  z-index: 1100

  .card-content
    height: calc(100% - 3.3rem)

</style>
