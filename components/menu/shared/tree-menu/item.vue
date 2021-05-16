<template lang='pug'>
.sp-tree-menu-item(:class='container_class')
  a.is-folder-item(:class='link_class' :style='link_style' @click.stop.prevent='toggle')
    span.sp-tree-menu-item-icon
      template(v-if="item.type == 'COMPANY'")
        company-seal-icon(:seal_id='item.seal_id' with_min_size=true)

      template(v-else-if="item.type == 'INDUSTRY_TYPE'")
        industry-type-icon(:industry_type='item.industry_type_id' small=true)

      template(v-else-if="item.type == 'INDUSTRY_CATEGORY'")
        industry-category-icon(:category='item.industry_category_id' small=true)

      template(v-else-if="item.type == 'TOWN'")
        city-icon

      template(v-else-if="item.type == 'MAP_LOCATION'")
        font-awesome-icon(:icon="['fas', 'map-marker-alt']")

      template(v-else-if='is_folder')
        template(v-if='item.primary')
          template(v-if='has_children || might_have_children')
            font-awesome-icon(v-show='!expanded' :icon="['fas', 'plus-square']")
            font-awesome-icon(v-show='expanded' :icon="['fas', 'minus-square']")
          template(v-else)
            font-awesome-icon(:icon="['fas', 'square']")

        template(v-else)
          template(v-if='has_children || might_have_children')
            font-awesome-icon(v-show='!expanded' :icon="['fas', 'folder']")
            font-awesome-icon(v-show='expanded' :icon="['fas', 'folder-open']")
          template(v-else)
            font-awesome-icon(:icon="['far', 'folder']")

      template(v-else)
        font-awesome-icon(:icon="['far', 'circle']")

    span.sp-tree-menu-item-label {{label}}

  .sp-menu-list(v-if='has_children' v-show='expanded')
    .menu-item(v-for='child in all_children' :key='child.id')
      tree-menu-item(
        :managers='managers'
        :client-state='clientState'
        :item='child'
        :visible='visible && expanded'
        :level='level + (item.primary ? 0 : 1)'
      )

  .loading-children-container(v-else-if='might_have_children' v-show='expanded')
    img.starpeace-logo

</template>

<script lang='coffee'>
import TreeMenuItem from '~/components/menu/shared/tree-menu/item.vue'

import CityIcon from '~/components/misc/city-icon.vue'
import CompanySealIcon from '~/components/misc/company-seal-icon.vue'
import IndustryCategoryIcon from '~/components/misc/industry-category-icon.vue'
import IndustryTypeIcon from '~/components/misc/industry-type-icon.vue'

export default
  components: {
    CompanySealIcon
    CityIcon
    IndustryCategoryIcon
    IndustryTypeIcon
    TreeMenuItem
  }

  name: 'tree-menu-item'
  props:
    managers: Object
    clientState: Object

    visible: Boolean
    level: Number
    item: Object

  data: ->
    loading_error: false
    expanded: false
    children: null

  computed:
    is_folder: -> @item?.type == 'FOLDER'

    might_have_children: -> @item?.load_children_callback? && !@children?
    has_children: -> @all_children.length > 0
    all_children: -> _.concat(@item?.children || [], @children || [])

    link_style: -> "padding-left: #{@level * 0.75}rem;"
    link_class: ->
      disabled: (@is_folder || !@item.action?) && !(@has_children || @might_have_children)

    container_class: ->
      'is-primary': @item?.primary

    label: -> if @item?.labelKey?.length then @translate(@item.labelKey) else (@item?.label || '')

  watch:
    visible: () ->
      if @visible
        @expanded = false
        @loading_error = false
        @children = null

    expanded: () ->
      if @visible && @expanded && @might_have_children
        @item.load_children_callback()
          .then (buildings) =>
            @children = @item.convert_children_callback(buildings)
          .catch (err) =>
            @clientState.add_error_message('Failure loading details from server', err)
            @loading_error = true

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    toggle: () ->
      if @item.action?
        @item.action()
      else if @has_children || @might_have_children
        @expanded = !@expanded

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

.loading-children-container
  justify-content: center
  display: flex
  margin: 1rem 0

  .starpeace-logo
    animation: spin-and-blink 1.5s linear infinite
    background-size: 5rem
    filter: $sp-filter-primary
    height: 5rem
    opacity: .7
    width: 5rem


.sp-tree-menu-item
  &.is-primary
    border-bottom: 1px solid darken($sp-primary-bg, 7.5%)
    border-left: 0
    border-right: 0

    > a
      background-color: darken($sp-primary-bg, 3%)
      display: inline-block
      font-size: .75em
      letter-spacing: .1em
      padding: .75rem 1rem
      text-transform: uppercase
      width: 100%

      &:not(.disabled)
        &:hover
          background-color: $sp-primary-bg

        &.active
          color: lighten($sp-primary, 20%)

    &:first-child
      border-top: 1px solid darken($sp-primary-bg, 7.5%)



.is-folder-item
  background-color: darken($sp-primary-bg, 9%)
  border-bottom: 1px solid darken($sp-primary-bg, 11%)
  display: inline-block
  padding: .5rem .75rem
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

  &.disabled
    cursor: not-allowed

  .sp-tree-menu-item-icon
    display: inline-block
    min-width: 1.25rem
    text-align: center

  .sp-tree-menu-item-label
    margin-left: .5rem

  .company-icon-wrapper
    height: 1.2rem
    width: 1.2rem


</style>
