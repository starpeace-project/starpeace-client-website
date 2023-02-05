<template lang='pug'>
#webgl-warning-container(v-show='is_visible')
  .card.is-starpeace.has-header
    .card-header
      .card-header-title {{translate('misc.webgl.warning.header')}}
      .card-header-icon.card-close(v-on:click.stop.prevent="dismissed = true")
        font-awesome-icon(:icon="['fas', 'times']")

    .card-content.sp-menu-background
      .card-description
        | {{translate('misc.webgl.warning.description')}}

</template>

<script lang='coffee'>
export default
  props:
    managers: Object
    client_state: Object

  data: ->
    dismissed: false

  computed:
    is_visible: -> !@dismissed && (@client_state?.initialized || false) && (@client_state?.webgl_warning || false)

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace'

#webgl-warning-container
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
