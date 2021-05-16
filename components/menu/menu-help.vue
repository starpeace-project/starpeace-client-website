<template lang='pug'>
#help-container(oncontextmenu='return false')
  .card.is-starpeace.has-header
    .card-header
      .card-header-title {{translate('ui.menu.help.header')}}
      .card-header-icon.card-close(v-on:click.stop.prevent="client_state.menu.toggle_menu('help')")
        font-awesome-icon(:icon="['fas', 'times']")
    .card-content.sp-menu-background
      | {{translate('ui.menu.help.link.info')}}&nbsp;
      a(href='https://docs.starpeace.io', target='_blank') {{translate('ui.menu.help.link.text')}}

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
#help-container
  align-items: center
  display: flex
  grid-column-start: 2
  grid-column-end: 3
  grid-row-start: start-render
  grid-row-end: end-render
  justify-content: center
  z-index: 1100

.card
  max-width: 40rem
  width: 100%

</style>
