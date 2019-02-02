<template lang='pug'>
#mail-container
  .card.is-starpeace.has-header
    .card-header
      .card-header-title {{translate('ui.menu.mail.header')}}
      .card-header-icon.card-close(v-on:click.stop.prevent="client_state.menu.toggle_menu('mail')")
        font-awesome-icon(:icon="['fas', 'times']")

    .card-content.sp-menu-background
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
