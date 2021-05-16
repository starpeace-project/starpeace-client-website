<template lang='pug'>
.inspect-details
  .inspect-tabs.tabs.is-small.is-marginless
    ul
      template(v-for='tab,index in tabs')
        li(:class="{ 'is-active': index == tab_index }" @click.stop.prevent='tab_index = index')
          a
            span {{tab}}

  .inspect-body.is-marginless


</template>

<script lang='coffee'>
export default
  props:
    clientState: Object
    managers: Object

  data: ->
    tab_index: 0

  computed:
    interface_state: ->
    is_ready: -> @clientState?.initialized && @clientState?.workflow_status == 'ready'

    show_inspect: -> @clientState?.interface?.selected_building_id? && @clientState?.interface?.show_inspect

    tabs: -> ['General']

  methods:
    translate: (key) -> if @managers? then @managers.translation_manager.text(key) else key

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'
@import '~assets/stylesheets/starpeace-inspect'

</style>
