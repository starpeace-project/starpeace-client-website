<template lang='pug'>
.filter-items
  a.filter-toggle.tooltip.is-tooltip-top(
    v-for='category in bookmark_categories'
    :class="filter_class(category)"
    :data-tooltip="text_for_category(category)"
    @click.stop.prevent="toggle_filter(category)"
  )
    misc-industry-category-icon(:category="category")

</template>

<script lang='ts'>
import ClientState from '~/plugins/starpeace-client/state/client-state.coffee';
import Managers from '~/plugins/starpeace-client/managers.coffee';

export default {
  props: {
    client_state: { type: ClientState, required: true }
  },

  computed: {
    bookmark_categories (): Array<string> { return [ 'SERVICE', 'INDUSTRY', 'LOGISTICS', 'CIVIC', 'COMMERCE', 'REAL_ESTATE' ]; }
  },

  methods: {
    text_for_category (category_id: string): string {
      const category = category_id ? this.client_state.core.planet_library.category_for_id(category_id) : null;
      return category ? this.$translate(category.label) : category_id;
    },

    filter_class (type: string): string {
      return "";
    },

    toggle_filter (type: string) {
      console.log(`toggle ${type}`);
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

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

    :deep(img)
      filter: invert(75%) sepia(8%) saturate(1308%) hue-rotate(111deg) brightness(93%) contrast(83%)
      height: 1.6rem
      width: 1.6rem

      path
        fill: $sp-primary !important

    &:hover
      background-color: lighten($sp-primary-bg, 2.5%)

    &:active
      background-color: lighten($sp-primary-bg, 7.5%)

      :deep(img)
        filter: invert(100%)

</style>
