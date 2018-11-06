<template lang='haml'>
#help-container
  .card.is-starpeace.has-header
    .card-header
      .card-header-title
        Help
      .card-header-icon.card-close{'v-on:click.stop.prevent':"menu_state.toggle_menu('help')"}
        %font-awesome-icon{':icon':"['fas', 'times']"}
    .card-content.sp-menu-background
      Full documentation can be&nbsp;
      %a{href:'https://docs.starpeace.io', target:'_blank'} found in the user guide

</template>

<script lang='coffee'>
export default
  props:
    menu_state: Object
</script>

<style lang='sass' scoped>
#help-container
  align-items: center
  display: flex
  grid-column-start: 2
  grid-column-end: 3
  grid-row-start: 2
  grid-row-end: 4
  justify-content: center
  z-index: 1100

.card
  max-width: 40rem
  width: 100%

</style>
