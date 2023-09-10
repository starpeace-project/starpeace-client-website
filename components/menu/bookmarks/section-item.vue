<template lang='pug'>
a.is-menu-item(:style="css_style_for_item" @click.stop.prevent='select')
  span.link-image
    template(v-if="item.type == 'TOWN'")
      misc-city-icon

    template(v-else)
      font-awesome-icon(:icon="['fas', 'map-marker-alt']")

  span.link-label {{label}}

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
    select () {
      this.$emit('select', this.item.id);
    }
  }
}
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
