<template lang='haml'>
#webgl-warning-container{'v-show':'is_visible'}
  .card.is-starpeace.has-header
    .card-header
      .card-header-title
        WebGL support not found
      .card-header-icon.card-close{'v-on:click.stop.prevent':"dismissed = true"}
        %font-awesome-icon{':icon':"['fas', 'times']"}
    .card-content.sp-menu-background
      .card-description
        WebGL support was not found, client functionality and experience will be severely reduced. Please either re-open client in new tab, restart browser session, or try a different browser.

</template>

<script lang='coffee'>
export default
  props:
    client_state: Object

  data: ->
    dismissed: false

  computed:
    is_visible: -> !@dismissed && (@client_state?.initialized || false) && (@client_state?.webgl_warning || false)

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace'

#webgl-warning-container
  align-items: center
  display: flex
  grid-column-start: 1
  grid-column-end: 4
  grid-row-start: 2
  grid-row-end: 4
  justify-content: center
  margin: 0
  position: relative
  z-index: 1100

</style>
