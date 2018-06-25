<template lang='haml'>
.level-item
  .card.has-header
    .card-header
      .card-header-title
        Help
      .card-header-icon.card-close{'v-on:click.stop.prevent':'menu_state.toggle_menu_help()'}
        %font-awesome-icon{':icon':"['fas', 'times']"}
    .card-content
      Full documentation can be&nbsp;
      %a{href:'https://docs.starpeace.io', target:'_blank'} found in the user guide

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
  max-width: 40rem
  width: 100%
  z-index: 1050

</style>
