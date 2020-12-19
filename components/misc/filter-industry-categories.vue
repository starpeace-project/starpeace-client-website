<template lang='pug'>
.filter-items
  a.filter-toggle.tooltip.is-tooltip-top(
    v-for='category in bookmark_categories'
    :class="filter_class(category)"
    :data-tooltip="text_for_category(category)"
    @click.stop.prevent="toggle_filter(category)"
  )
    industry-category-icon(:category="category")

</template>

<script lang='coffee'>
import IndustryCategoryIcon from '~/components/misc/industry-category-icon.vue'

export default
  components: {
    IndustryCategoryIcon
  }

  props:
    managers: Object
    client_state: Object

  computed:
    bookmark_categories: -> [ 'SERVICE', 'INDUSTRY', 'LOGISTICS', 'CIVIC', 'COMMERCE', 'REAL_ESTATE' ]

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)
    text_for_category: (category_id) -> if category_id? then @managers.translation_manager.text(@client_state.core.planet_library.category_for_id(category_id)?.label) else category_id

    filter_class: (type) ->
      ""
    toggle_filter: (type) ->
      console.log "toggle #{type}"

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

.filter-items
  height: 2.6rem
  margin-bottom: .5rem
  position: relative
  text-align: center

  .filter-toggle
    border: 1px solid lighten($sp-primary-bg, 5%)
    display: inline-flex
    padding: .4rem

    &:not(:first-child)
      margin-left: .5rem

    ::v-deep img
      filter: invert(75%) sepia(8%) saturate(1308%) hue-rotate(111deg) brightness(93%) contrast(83%)
      height: 1.6rem
      width: 1.6rem

      path
        fill: $sp-primary !important

    &:hover
      background-color: lighten($sp-primary-bg, 2.5%)

    &:active
      background-color: lighten($sp-primary-bg, 7.5%)

      ::v-deep img
        filter: invert(100%)

</style>
