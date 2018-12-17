<template lang='haml'>
#session-expired-warning-container{'v-show':'is_visible'}
  .modal-background
  .card.is-starpeace.has-header
    .card-header
      .card-header-title
        Session has expired
    .card-content.sp-menu-background
      .card-description
        Your playing session has expired. Please login again.

</template>

<script lang='coffee'>
export default
  props:
    client_state: Object

  computed:
    is_visible: -> @client_state?.initialized && @client_state?.session_expired_warning

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace'

#session-expired-warning-container
  align-items: center
  display: flex
  grid-column-start: 1
  grid-column-end: 4
  grid-row-start: 2
  grid-row-end: 6
  justify-content: center
  margin: 0
  position: relative
  z-index: 1100

</style>
