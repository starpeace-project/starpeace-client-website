<template lang='haml'>
.level-item
  .card.has-header
    .card-header
      .card-header-title
        Mail
      .card-header-icon.card-close{'v-on:click.stop.prevent':'menu_state.toggle_menu_mail()'}
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
  max-width: 50rem
  width: 100%
  z-index: 1050

  .card-content
    min-height: 20rem
</style>
