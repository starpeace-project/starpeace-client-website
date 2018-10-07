<template lang='haml'>
#mail-container
  .card.has-header
    .card-header
      .card-header-title
        Mail
      .card-header-icon.card-close{'v-on:click.stop.prevent':"menu_state.toggle_menu('mail')"}
        %font-awesome-icon{':icon':"['fas', 'times']"}

    .card-content.sp-menu-background
</template>

<script lang='coffee'>
export default
  props:
    menu_state: Object
</script>

<style lang='sass' scoped>
#mail-container
  align-items: center
  display: flex
  grid-column-start: 2
  grid-column-end: 3
  grid-row-start: 2
  grid-row-end: 4
  justify-content: center
  z-index: 1100

.card
  max-width: 50rem
  width: 100%

  .card-content
    min-height: 20rem
</style>
