<template lang='pug'>
#server-connection-warning-container(v-show='is_visible')
  .modal-background
  .card.is-starpeace.has-header
    .card-header
      .card-header-title {{translate('misc.server_connection.warning.header')}}

    .card-content.sp-menu-background
      .card-description
        | {{translate('misc.server_connection.warning.description')}}

</template>

<script lang='coffee'>
export default
  props:
    managers: Object
    client_state: Object

  computed:
    is_visible: -> @client_state?.initialized && @client_state?.server_connection_warning

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace'

#server-connection-warning-container
  align-items: center
  display: flex
  grid-column-start: 1
  grid-column-end: 4
  grid-row-start: start-render
  grid-row-end: end-toolbar
  justify-content: center
  margin: 0
  position: relative
  z-index: 1100

</style>
