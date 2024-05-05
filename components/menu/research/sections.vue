<template lang='pug'>
.research-container
  .field.m-0.filter-input-container
    .control.has-icons-left.is-expanded
      input.input(type='text' :placeholder="$translate('misc.filter')" v-model='filterInputValue')
      span.icon.is-left
        font-awesome-icon(:icon="['fas', 'search-location']")

  misc-filter-industry-categories(:client_state='clientState')

  aside.sp-menu.sp-scrollbar
    p.sp-section(v-for='item in filteredSections')
      a(@click.stop.prevent='toggleSection(item.industryCategoryId)')
        span(v-if='item.children.length && !expandedByIndustryCategoryId[item.industryCategoryId]')
          font-awesome-icon(:icon="['fas', 'plus-square']")
        span(v-else-if='item.children.length && expandedByIndustryCategoryId[item.industryCategoryId]')
          font-awesome-icon(:icon="['fas', 'minus-square']")
        span.sp-folder-icon(v-else)
          font-awesome-icon(:icon="['fas', 'square']")
        span.sp-section-label {{item.name}}

      ul.sp-section-items(v-show='item.children.length && expandedByIndustryCategoryId[item.industryCategoryId]')
        li(v-for='child in item.children')
          a.is-menu-item(
            :class="{'is-active': selectedCategoryId == item.industryCategoryId && selectedIndustryTypeId == child.industryTypeId}"
            @click.stop.prevent='selectCategoryType(item.industryCategoryId, child.industryTypeId)'
          )
            misc-industry-type-icon(:industry_type='child.industryTypeId' :class="['sp-section-item-image', 'sp-indusry-icon']" default_research)
            span.sp-section-item-label {{child.name}}

</template>

<script lang='ts'>
import _ from 'lodash';
import { IndustryCategory, InventionDefinition } from '@starpeace/starpeace-assets-types';

import ClientState from '~/plugins/starpeace-client/state/client-state';

declare interface CategorySection {
  name: string;
  industryCategoryId: string;

  childrenByType: Record<string, IndustryTypeSection>;
  children: Array<IndustryTypeSection>;
}

declare interface IndustryTypeSection {
  name: string;
  industryTypeId: string;
}

declare interface SectionsData {
  filterInputValue: string;
  expandedByIndustryCategoryId: Record<string, boolean>;
}

export default {
  props: {
    clientState: { type: ClientState, required: true },
    inventionDefinitions: { type: Array<InventionDefinition>, required: true }
  },

  data (): SectionsData {
    return {
      filterInputValue: '',

      expandedByIndustryCategoryId: {}
    };
  },

  computed: {
    selectedCategoryId (): string | undefined {
      return this.clientState.interface.inventions_selected_category_id ?? undefined;
    },
    selectedIndustryTypeId (): string | undefined {
      return this.clientState.interface.inventions_selected_industry_type_id ?? undefined;
    },

    filteredSections (): Array<CategorySection> {
      const sectionByCategory: Record<string, CategorySection> = {}
      for (const invention of this.inventionDefinitions) {
        const category: IndustryCategory | undefined = this.clientState.core.planet_library.category_for_id(invention.industryCategoryId);
        if (!category || category.id === 'NONE') {
          continue;
        }

        if (!sectionByCategory[invention.industryCategoryId]) {
          sectionByCategory[invention.industryCategoryId] = {
            name: (category ? this.$translate(category.label) : undefined) ?? invention.industryCategoryId,
            industryCategoryId: invention.industryCategoryId,
            childrenByType: {},
            children: []
          };
        }

        const typeId = invention.industryTypeId ?? 'GENERAL';
        if (!sectionByCategory[invention.industryCategoryId].childrenByType[typeId]) {
          const industryType = this.clientState.core.planet_library.type_for_id(typeId);
          sectionByCategory[invention.industryCategoryId].childrenByType[typeId] = {
            name: (industryType ? this.$translate(industryType.label) : undefined) ?? typeId,
            industryTypeId: invention.industryTypeId
          };
        }
      }

      const sections = [];
      for (const section of Object.values(sectionByCategory)) {
        section.children = _.orderBy(Object.values(section.childrenByType), ['name'], ['asc']);
        sections.push(section);
      }
      return _.orderBy(sections, ['name'], ['asc']);
    }
  },

  watch: {
    selectedCategoryId: {
      immediate: true,
      handler () {
        if (this.selectedCategoryId) {
          this.expandedByIndustryCategoryId[this.selectedCategoryId] = true;
        }
      }
    }
  },

  methods: {
    selectCategoryType (industryCategoryId: string, industryTypeId: string) {
      // TODO: move to method/event
      this.clientState.interface.inventions_selected_category_id = industryCategoryId;
      this.clientState.interface.inventions_selected_industry_type_id = industryTypeId;
    },

    toggleSection (industryCategoryId: string) {
      this.expandedByIndustryCategoryId[industryCategoryId] = !this.expandedByIndustryCategoryId[industryCategoryId];
    }
  }
}
</script>

<style lang='sass' scoped>
$sp-primary: #6ea192
$sp-primary-bg: #395950

.research-container
  display: grid
  position: relative
  grid-column: 1 / 2
  grid-row: 1 / 2
  grid-template-columns: auto
  grid-template-rows: 4rem 3.5rem auto

.filter-input-container
  padding: 1rem 1rem .5rem

  input
    &:focus
      border-color: $sp-primary !important

.sp-menu
  overflow-x: hidden
  overflow-y: scroll

  .sp-section
    border-bottom: 1px solid darken($sp-primary-bg, 7.5%)
    border-left: 0
    border-right: 0

    > a
      background-color: darken($sp-primary-bg, 3%)
      display: inline-block
      font-size: .8em
      letter-spacing: .1em
      padding: .75rem 1rem
      text-transform: uppercase
      width: 100%

      &:not(.disabled)
        &:hover,
        &.is-hover
          background-color: $sp-primary-bg

        &:active,
        &.is-active
          color: lighten($sp-primary, 20%)

    &:first-child
      border-top: 1px solid darken($sp-primary-bg, 7.5%)

    .sp-section-label
      margin-left: 1rem

    .sp-section-items
      a
        &.is-menu-item
          background-color: darken($sp-primary-bg, 15%)
          border-bottom: 1px solid darken($sp-primary-bg, 17.5%)
          display: inline-block
          padding-bottom: .75rem
          padding-top: .75rem
          position: relative
          width: 100%

          &:hover,
          &.is-hover
            background-color: darken($sp-primary-bg, 12.5%)
            border-bottom: 1px solid darken($sp-primary-bg, 15%)

          &:active,
          &.is-active
            background-color: darken($sp-primary-bg, 10%)
            border-bottom: 1px solid darken($sp-primary-bg, 12.5%)

      .sp-section-item-image
        border: 0
        padding: 0
        position: absolute
        left: .5rem
        top: calc(50% - .6rem)

      .sp-section-item-label
        font-size: 1.15rem
        margin-left: 2.3rem
        text-transform: capitalize

</style>
