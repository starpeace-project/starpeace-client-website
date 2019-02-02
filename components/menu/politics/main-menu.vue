<template lang='pug'>
#politics-container.card.is-starpeace.has-header
  .card-header
    .card-header-title {{translate('ui.menu.politics.header')}}
    .card-header-icon.card-close(v-on:click.stop.prevent="client_state.menu.toggle_menu('politics')")
      font-awesome-icon(:icon="['fas', 'times']")

  .card-content.sp-menu-background.overall-container

</template>

<script lang='coffee'>

export default
  props:
    client_state: Object
    managers: Object

  computed:
    is_ready: -> @client_state?.workflow_status == 'ready'

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)
</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

#politics-container
  grid-column-start: 1
  grid-column-end: 4
  grid-row-start: 2
  grid-row-end: 4
  margin: 0
  overflow: hidden
  z-index: 1100

  &.card
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
