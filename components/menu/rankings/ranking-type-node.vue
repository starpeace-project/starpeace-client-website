<template lang='pug'>
.sp-section(:class="{'is-root':level==0}")
  a(@click.stop.prevent='toggle')
    span.sp-section-indent(:style='level_style')

    template(v-if='node.industry_type_id')
      span.sp-section-icon
        misc-industry-type-icon(:industry_type='node.industry_type_id')

    template(v-else-if='node.industry_category_id')
      span.sp-section-icon
        misc-industry-category-icon(small=true :category='node.industry_category_id')

    template(v-else-if='has_children')
      span.sp-section-icon(v-show='!node.expanded')
        font-awesome-icon(:icon="['fas', 'plus-square']")
      span.sp-section-icon(v-show='node.expanded')
        font-awesome-icon(:icon="['fas', 'minus-square']")

    template(v-else)
      span.sp-section-icon
        font-awesome-icon(:icon="['fas', 'medal']")

    span.sp-section-label {{translate(node.label)}}

  .sp-menu-list(v-if='has_children' v-show='node.expanded')
    menu-rankings-ranking-type-node(
      v-for="child in sorted_children"
      :managers='managers'
      :node='child'
      :level='level+1'
      :key='child.id'
      @select="$emit('select', $event)"
    )

</template>

<script lang='coffee'>
import _ from 'lodash';
export default
  props:
    managers: Object

    node: Object
    level: Number

  computed:
    level_style: -> 'width: ' + Math.max(0, @level - 1) + 'rem'
    has_children: -> @node?.children?.length

    label: -> @label_for_node(@node)

    sorted_children: -> _.orderBy(@node?.children, [((node) -> if node.category_total then 0 else 1), ((node) => @translate(node.label))], ['asc', 'asc'])

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    toggle: () ->
      if @has_children
        @node.expanded = !@node.expanded
      else
        @$emit('select', @node.id)


</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.sp-section
  border-left: 0
  border-right: 0

  > a
    align-items: center
    background-color: darken($sp-primary-bg, 15%)
    border-bottom: 1px solid darken($sp-primary-bg, 17.5%)
    display: inline-flex
    font-size: 1em
    padding: .5rem .75rem
    width: 100%


    &:not(.disabled)
      &:hover,
      &.is-hover
        background-color: darken($sp-primary-bg, 12.5%)

      &:active,
      &.is-active
        background-color: darken($sp-primary-bg, 10%)

  &.is-root
    > a
      background-color: darken($sp-primary-bg, 2.5%)
      border-bottom: 1px solid darken($sp-primary-bg, 5%)
      font-size: .75em
      letter-spacing: .1em
      text-transform: uppercase

      &:hover,
      &.is-hover
        background-color: $sp-primary-bg
        border-bottom: 1px solid darken($sp-primary-bg, 2.5%)

      &.active,
      &.is-active
        background-color: lighten($sp-primary-bg, 2.5%)
        border-bottom: 1px solid $sp-primary-bg
        color: lighten($sp-primary, 20%)

  .sp-section-indent
    display: inline-block

  .sp-section-icon
    display: inline-flex
    min-width: 1.2rem
    text-align: center

  .sp-section-label
    margin-left: .5rem



</style>
