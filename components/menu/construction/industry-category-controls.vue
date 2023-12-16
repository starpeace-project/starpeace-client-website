<template lang='pug'>
aside.sp-menu-overall.sp-scrollbar
  .tile.is-ancestor
    .tile.is-6.is-vertical.is-parent
      .tile.is-child(v-for='categoryId in lhsCategories')
        a.construction-toggle(@click.stop.prevent='selectCategoryId(categoryId)' :class="{'disabled': !companyBuildingsByCategoryId[categoryId]}")
          misc-industry-category-icon(:category='categoryId')
          span.toggle-label {{ $industryCategoryLabel(categoryId) }}
          .disabled-overlay

    .tile.is-6.is-vertical.is-parent
      .tile.is-child(v-for='categoryId in rhsCategories')
        a.construction-toggle(@click.stop.prevent='selectCategoryId(categoryId)' :class="{'disabled': !companyBuildingsByCategoryId[categoryId]}")
          misc-industry-category-icon(:category='categoryId')
          span.toggle-label {{ $industryCategoryLabel(categoryId) }}
          .disabled-overlay
</template>

<script lang='ts'>
import Company from '~/plugins/starpeace-client/company/company';
import ClientState from '~/plugins/starpeace-client/state/client-state';

export default {
  props: {
    clientState: { type: ClientState, required: true },

    company: { type: Company, required: false },
    companyBuildingsByCategoryId: { type: Object, required: true }
  },

  computed: {
    lhsCategories (): Array<string> {
      return ['SERVICE', 'INDUSTRY', 'LOGISTICS'];
    },
    rhsCategories (): Array<string> {
      return ['CIVIC', 'COMMERCE', 'REAL_ESTATE'];
    }
  },

  methods: {
    selectCategoryId (categoryId: string): void {
      this.$emit('select', categoryId);
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.sp-menu-overall
  height: calc(100% - 4.75rem - 2.75rem - 3.5rem)
  overflow-y: auto
  padding: 0 1.25rem
  position: absolute
  overflow-x: hidden
  width: 100%

  li
    padding: 0 1.25rem

.construction-toggle
  border: 1px solid lighten($sp-primary-bg, 5%)
  display: inline-block
  padding: 1rem .5rem
  position: relative
  text-align: center

  &:not(.disabled)
    &:hover
      background-color: lighten($sp-primary-bg, 2.5%)

    &:active
      background-color: lighten($sp-primary-bg, 7.5%)

  :deep(img)
    filter: invert(75%) sepia(8%) saturate(1308%) hue-rotate(111deg) brightness(93%) contrast(83%)
    width: 50%

  .toggle-label
    display: block
    font-size: 1.1rem
    margin-top: .5rem

  .disabled-overlay
    background-color: #000
    cursor: not-allowed
    display: none
    height: 100%
    left: 0
    opacity: .5
    position: absolute
    top: 0
    width: 100%

  &.disabled
    .disabled-overlay
      display: block

</style>
