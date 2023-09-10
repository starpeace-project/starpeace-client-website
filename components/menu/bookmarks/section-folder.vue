<template lang='pug'>
.sp-folder
  template(v-if="item")
    a.is-folder-item(:class="{'is-empty-folder': !item.hasChildren}" :style="css_style_for_item" @click.stop.prevent='toggle')
      template(v-if="item.type == 'CORPORATION' && item.sealId")
        span.company-icon-wrapper
          misc-company-seal-icon(:seal_id='item.sealId' with_min_size)

      template(v-else-if="item.type == 'INDUSTRY' && item.industryTypeId")
        misc-industry-type-icon(:industry_type='item.industryTypeId' small)

      template(v-else-if="item.type == 'TOWN'")
        misc-city-icon

      template(v-else-if='!item.hasChildren')
        span.sp-folder-icon
          font-awesome-icon(:icon="['far', 'folder']")

      template(v-else)
        span.sp-folder-icon(v-show="!item.expanded")
          font-awesome-icon(:icon="['fas', 'folder']")
        span.sp-folder-icon(v-show="item.expanded")
          font-awesome-icon(:icon="['fas', 'folder-open']")

      span.sp-folder-label {{label}}
</template>

<script lang='ts'>
import BookmarkMenuItem from '~/plugins/starpeace-client/bookmark/bookmark-menu-item';

export default {
  props: {
    item: { type: BookmarkMenuItem, required: true },
  },

  computed: {
    label (): string {
      return this.item.itemNameKey ? this.$translate(this.item.itemNameKey) : (this.item.itemName ?? '');
    },

    css_style_for_item () {
      return `padding-left: ${(this.item.level + 1) * 0.75}rem;`;
    }
  },

  methods: {
    toggle () {
      this.$emit('toggle', this.item.id);
    }
  }
}
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
