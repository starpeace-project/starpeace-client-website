<template lang='pug'>
.research-container
  .field.is-marginless.filter-input-container
    .control.has-icons-left.is-expanded
      input.input(type="text" :placeholder="$translate('misc.filter')")
      span.icon.is-left
        font-awesome-icon(:icon="['fas', 'search-location']")

  misc-filter-industry-categories(:client_state='client_state')

  aside.sp-menu.sp-scrollbar
    p.sp-section(v-for='item in sections')
      a(@click.stop.prevent="item.expanded = !item.expanded")
        span(v-show="item.children.length && !item.expanded")
          font-awesome-icon(:icon="['fas', 'plus-square']")
        span(v-show="item.children.length && item.expanded")
          font-awesome-icon(:icon="['fas', 'minus-square']")
        span.sp-folder-icon(v-show="!item.children.length")
          font-awesome-icon(:icon="['fas', 'square']")
        span.sp-section-label {{item.name}}

      ul.sp-section-items(v-show="item.children.length && item.expanded")
        li(v-for="child in item.children")
          a.is-menu-item(@click.stop.prevent="select_inventions(item.industry_category_id, child.industry_type_id)", :class="section_item_class(item, child)")
            misc-industry-type-icon(:industry_type="child.industry_type_id", :class="['sp-section-item-image', 'sp-indusry-icon']", :default_research='true')
            span.sp-section-item-label {{child.name}}

</template>

<script lang='ts'>
import _ from 'lodash';
import ClientState from '~/plugins/starpeace-client/state/client-state.coffee';

declare interface SectionsData {
  filter_input_value: string;
  sections: Array<any>;
}

export default {
  props: {
    client_state: { type: ClientState, required: true },
    isVisible: Boolean
  },

  data (): SectionsData {
    return {
      filter_input_value: '',

      sections: []
    };
  },

  mounted () {
    this.client_state?.options?.subscribe_options_listener(() => this.refresh_sections());
  },

  watch: {
    isVisible (new_value, old_value) {
      this.refresh_sections();
    },
    selected_category_id (new_value, old_value) {
      this.refresh_sections();
    },
    company_id (new_value, old_value) {
      this.refresh_sections();
    }
  },

  computed: {
    selected_category_id (): string | null { return this.client_state.interface.inventions_selected_category_id; },
    selected_industry_type_id (): string | null { return this.client_state.interface.inventions_selected_industry_type_id; },

    company_id (): string | null { return this.client_state.player.company_id; }
  },

  methods: {
    filter_class (type: any) {
      return '';
    },
    section_item_class (item: any, child: any) {
      return {
        'is-active': this.selected_category_id == item.industry_category_id && this.selected_industry_type_id == child.industry_type_id
      };
    },

    refresh_sections () {
      if (!this.isVisible) return;
      const sections_by_category: Record<string, any> = {}
      for (const invention of this.inventions_for_company()) {
        if (!sections_by_category[invention.industry_category_id]) {
          const category = this.client_state.core.planet_library.category_for_id(invention.industry_category_id);
          sections_by_category[invention.industry_category_id] = {
            name: category ? this.$translate(category.label) : invention.industry_category_id,
            industry_category_id: invention.industry_category_id,
            expanded: invention.industry_category_id == this.selected_category_id,
            children_by_type: {}
          };
        }

        const type_id = invention.industry_type_id ?? 'GENERAL';
        if (!sections_by_category[invention.industry_category_id].children_by_type[type_id]) {
          const industry_type = this.client_state.core.planet_library.type_for_id(type_id);
          sections_by_category[invention.industry_category_id].children_by_type[type_id] = {
            name: industry_type ? this.$translate(industry_type.label) : type_id,
            industry_type_id: invention.industry_type_id
          };
        }
      }

      const sections = [];
      for (const category_id of this.client_state.core.planet_library.categories_for_inventions()) {
        if (sections_by_category[category_id]) {
          const section = sections_by_category[category_id];
          section.children = _.sortBy(_.values(section.children_by_type), (child) => child.name);
          sections.push(section);
        }
      }
      this.sections = sections;
    },

    inventions_for_company () { return this.client_state.inventions_for_company(); },

    select_inventions (industry_category_id: string, industry_type_id: string) {
      this.client_state.interface.inventions_selected_category_id = industry_category_id;
      this.client_state.interface.inventions_selected_industry_type_id = industry_type_id;
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
