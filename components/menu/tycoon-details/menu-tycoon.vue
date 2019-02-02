<template lang='pug'>
#tycoon-container.card.is-starpeace.has-header
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
@import '~assets/stylesheets/starpeace-variables'

#tycoon-container
  grid-column-start: 1
  grid-column-end: 4
  grid-row-start: 2
  grid-row-end: 4
  margin: 0
  overflow: hidden
  z-index: 1100

.card
  height: 100%
  max-width: 25rem
  overflow: hidden
  position: absolute
  width: 100%

  .card-content
    height: calc(100% - 3.2rem)
    padding: 0

    &.overall-container
      padding-top: .5rem
      position: relative

</style>
