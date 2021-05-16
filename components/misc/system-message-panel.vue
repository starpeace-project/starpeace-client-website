<template lang='pug'>
#system-message-container(v-if='visible')
  template(v-if='visible')
    div(v-for='message in messages' :key='message.id')
      | {{message.time.format('hh:mm:ss A')}}: {{message.message}}

</template>

<script lang='coffee'>
export default
  props:
    clientState: Object
    managers: Object

  computed:
    visible: -> @clientState.initialized && @clientState.workflow_status == 'ready'
    messages: -> @clientState.recent_system_messages

  methods:
    translate: (key) -> if @managers? then @managers.translation_manager.text(key) else key
</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace'

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
