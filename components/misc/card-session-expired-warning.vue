<template lang='pug'>
#session-expired-warning-container(v-show='is_visible')
  .modal-background
  .card.is-starpeace.has-header
    .card-header
      .card-header-title {{translate('misc.expired_session.warning.header')}}

    .card-content.sp-menu-background
      .card-description
        | {{translate('misc.expired_session.warning.description')}}

</template>

<script lang='coffee'>
export default
  props:
    managers: Object
    client_state: Object

  computed:
    is_visible: -> @client_state?.initialized && @client_state?.session_expired_warning

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace'

#session-expired-warning-container
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
