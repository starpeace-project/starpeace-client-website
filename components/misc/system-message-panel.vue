<template lang='pug'>
#system-message-container(v-if='visible')
  template(v-if='visible')
    div(v-for='message in messages' :key='message.id')
      | {{message.time.toFormat('hh:mm:ss a')}}: {{message.message}}

</template>

<script lang='ts'>
import ClientState from '~/plugins/starpeace-client/state/client-state.coffee';
import Managers from '~/plugins/starpeace-client/managers.coffee';

export default {
  props: {
    clientState: { type: ClientState, required: true }
  },

  computed: {
    visible (): boolean { return this.clientState.initialized && this.clientState.workflow_status === 'ready'; },
    messages (): Array<string> { return this.clientState.recent_system_messages; }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace'

#system-message-container
  color: #00ff00
  font-size: 1.25rem
  font-style: italic
  font-weight: bold
  grid-column: 2 / 3
  grid-row: start-render / end-render
  padding: .5rem
  pointer-events: none
  position: relative
  text-shadow: -1px 1px 2px #000, 1px 1px 2px #000, 1px -1px 0 #000, -1px -1px 0 #000
  z-index: 1050

</style>
