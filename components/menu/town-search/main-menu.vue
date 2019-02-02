<template lang='pug'>
#search-container.card.is-starpeace.has-header
  .card-header
    .card-header-title {{translate('ui.menu.town_search.header')}}
    .card-header-icon.card-close(v-on:click.stop.prevent="client_state.menu.toggle_menu('town_search')")
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

#search-container
  grid-column-start: 3
  grid-row-start: 2
  grid-column-end: 4
  grid-row-end: 5
  overflow: hidden
  width: 30rem
  z-index: 1100

  .card-content
    height: calc(100% - 3.2rem)
    padding: 0

</style>
