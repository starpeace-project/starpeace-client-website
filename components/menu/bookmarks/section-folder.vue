<template lang='pug'>
.sp-folder
  template(v-if="item")
    a.is-folder-item(v-on:click.stop.prevent="toggle_item", :class="css_class_for_item", :style="css_style_for_item")
      template(v-if="item.type == 'CORPORATION'")
        span.company-icon-wrapper
          misc-company-seal-icon(:seal_id="item.seal_id", with_min_size=true)
      template(v-else-if="item.type == 'INDUSTRY'")
        misc-industry-type-icon(:industry_type="item.industry_type", :small='true')
      template(v-else-if="item.type == 'TOWN'")
        misc-city-icon
      template(v-else)
        span.sp-folder-icon(v-show="item.has_children && !item.expanded")
          font-awesome-icon(:icon="['fas', 'folder']")
        span.sp-folder-icon(v-show="item.has_children && item.expanded")
          font-awesome-icon(:icon="['fas', 'folder-open']")
        span.sp-folder-icon(v-show="!item.has_children")
          font-awesome-icon(:icon="['far', 'folder']")
      span.sp-folder-label {{item.item_name}}
</template>

<script lang='coffee'>
export default
  props:
    item: Object

    dragging_level: Number

  computed:
    css_class_for_item: -> if @item.has_children then '' else 'is-empty-folder'
    css_style_for_item: ->
      level = if @dragging_level? && @dragging_level >= 0 then @dragging_level else @item.level
      "padding-left: #{(level + 1) * 0.75}rem;"

  methods:
    toggle_item: () ->
      return unless @item.has_children

      @item.expanded = !@item.expanded
      @$emit('toggled')

</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.is-folder-item
  background-color: darken($sp-primary-bg, 9%)
  border-bottom: 1px solid darken($sp-primary-bg, 11%)
  display: inline-block
  padding: .75rem .75rem
  width: 100%

  &:not(.disabled)
    &:hover
      background-color: darken($sp-primary-bg, 6.5%)
      border-bottom: 1px solid darken($sp-primary-bg, 9%)

    &:active
      color: #8bb3a7
      font-weight: normal

    &.active
      background-color: darken($sp-primary-bg, 4%)
      border-bottom: 1px solid darken($sp-primary-bg, 6%)

  &.disabled,
  &.is-empty-folder
    cursor: not-allowed

  .sp-folder-icon
    display: inline-block
    min-width: 1.25rem
    text-align: center

  .sp-folder-label
    margin-left: .5rem

  .company-icon-wrapper
    height: 1.2rem
    width: 1.2rem

.sortable-chosen
  .is-folder-item
    color: #fff !important
    background-color: darken($sp-primary-bg, 4%) !important
    border-bottom: 1px solid darken($sp-primary-bg, 6%) !important
    font-weight: bold !important


</style>
