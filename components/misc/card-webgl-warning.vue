<template lang='pug'>
#webgl-warning-container(v-show='is_visible')
  .card.is-starpeace.has-header
    .card-header
      .card-header-title {{$translate('misc.webgl.warning.header')}}
      .card-header-icon.card-close(v-on:click.stop.prevent="dismissed = true")
        font-awesome-icon(:icon="['fas', 'times']")

    .card-content.sp-menu-background
      .card-description
        | {{$translate('misc.webgl.warning.description')}}

</template>

<script lang='ts'>
import ClientState from '~/plugins/starpeace-client/state/client-state.coffee';

export default {
  props: {
    client_state: { type: ClientState, required: true }
  },

  data () {
    return {
      dismissed: false
    };
  },

  computed: {
    is_visible (): boolean { return !this.dismissed && this.client_state?.initialized && this.client_state?.webgl_warning; }
  }
}
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
