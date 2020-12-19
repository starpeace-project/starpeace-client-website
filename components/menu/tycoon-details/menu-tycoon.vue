<template lang='pug'>
.card.has-header.is-starpeace.sp-menu
  .card-header
    .card-header-title {{translate('ui.menu.tycoon_details.header')}}
    .card-header-icon.card-close(v-on:click.stop.prevent="client_state.menu.toggle_menu('tycoon')")
      font-awesome-icon(:icon="['fas', 'times']")

  .card-content.sp-menu-background.overall-container

</template>

<script lang='coffee'>

export default
  props:
    managers: Object
    client_state: Object

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)
</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-menus'

.sp-menu
  grid-column-start: 1
  grid-column-end: 3
  grid-row-start: 2
  grid-row-end: 5

  > .card-content
    grid-template-columns: 25rem auto


</style>
