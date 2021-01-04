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

.inspect-details
  display: grid
  grid-column: start-details / end-details
  grid-row: 1 / 2
  grid-template-columns: auto
  grid-template-rows: [start-tabs] 2rem [end-tabs start-details] auto [end-details]

.inspect-tabs
  grid-column: 1 / 2
  grid-row: start-tabs / end-tabs

  ul
    border-bottom-color: $sp-primary-bg

  a
    border-bottom-color: $sp-primary-bg
    color: $sp-primary
    letter-spacing: .05rem
    text-transform: uppercase

    &:active,
    &:hover
      background-color: $sp-light-bg
      border-bottom-color: $sp-primary-bg
      color: #fff

  li
    &.is-active
      a
        background-color: $sp-primary-bg
        border-bottom-color: $sp-dark-bg
        color: #fff

.inspect-body
  grid-column: 1 / 2
  grid-row: start-details / end-details

</style>
