<template lang='pug'>
a.is-menu-item(v-on:click.stop.prevent="select_item", :style="css_style_for_item")
  span.link-image
    template(v-if="item.type == 'TOWN'")
      misc-city-icon
    template(v-else-if="true")
      font-awesome-icon(:icon="['fas', 'map-marker-alt']")
  span.link-label {{item.item_name}}

</template>

<script lang='coffee'>
export default
  props:
    item: Object

    dragging_level: Number

  computed:
    css_style_for_item: ->
      level = if @dragging_level? && @dragging_level >= 0 then @dragging_level else @item.level
      "padding-left: #{(level + 1) * 0.75}rem;"

  methods:
    select_item: () ->
      return if @item.is_folder
      @$emit('selected', @item.id)
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.is-menu-item
  background-color: darken($sp-primary-bg, 15%)
  border-bottom: 1px solid darken($sp-primary-bg, 17.5%)
  display: inline-block
  padding: .75rem .75rem
  width: 100%

  &.disabled
    cursor: not-allowed

  &:not(.disabled)
    &:hover
      background-color: darken($sp-primary-bg, 12.5%)
      border-bottom: 1px solid darken($sp-primary-bg, 15%)

    &:active
      color: #8bb3a7 !important
      font-weight: normal

.link-image
  border: 0
  display: inline-block
  min-width: 1.25rem
  text-align: center

.link-label
  font-size: 1rem
  padding-left: .5rem

</style>
