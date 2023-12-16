<template lang='pug'>
.sp-tree-menu-item(:class='container_class')
  a.is-folder-item(:class='link_class' :style='link_style' @click.stop.prevent='toggle')
    span.sp-tree-menu-item-icon
      template(v-if="item.type == 'COMPANY'")
        misc-company-seal-icon(:seal_id='item.seal_id' with_min_size=true)

      template(v-else-if="item.type == 'INDUSTRY_TYPE'")
        misc-industry-type-icon(:industry_type='item.industryTypeId' small=true)

      template(v-else-if="item.type == 'INDUSTRY_CATEGORY'")
        misc-industry-category-icon(:category='item.industryCategoryId' small=true)

      template(v-else-if="item.type == 'TOWN'")
        misc-city-icon

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
      menu-shared-tree-menu-item(
        :client-state='clientState'
        :item='child'
        :visible='visible && expanded'
        :level='level + (item.primary ? 0 : 1)'
      )

  .loading-children-container(v-else-if='might_have_children' v-show='expanded')
    img.starpeace-logo

</template>

<script lang='ts'>
import _ from 'lodash';
import ClientState from '~/plugins/starpeace-client/state/client-state';

export default {
  props: {
    clientState: { type: ClientState, required: true },

    visible: Boolean,
    level: Number,
    item: Object
  },

  data () {
    return {
      loading_error: false,
      expanded: false,
      children: null
    };
  },

  computed: {
    is_folder () { return this.item?.type == 'FOLDER'; },

    might_have_children () { return !!this.item?.load_children_callback && !this.children; },
    has_children () { return this.all_children.length > 0; },
    all_children () { return _.concat(this.item?.children ?? [], this.children ?? []); },

    link_style () { return `padding-left: ${this.level * 0.75}rem;`; },
    link_class () {
      return {
        disabled: (this.is_folder || !this.item.action) && !(this.has_children || this.might_have_children)
      };
    },

    container_class () {
      return {
        'is-primary': this.item?.primary
      };
    },

    label () { return this.item?.labelKey?.length ? this.$translate(this.item.labelKey) : (this.item?.label ?? ''); }
  },

  watch: {
    visible () {
      if (this.visible) {
        this.expanded = false;
        this.loading_error = false;
        this.children = null;
      }
    },

    expanded () {
      if (this.visible && this.expanded && this.might_have_children) {
        this.refresh_buildings();
      }
    }
  },

  methods: {
    toggle () {
      if (this.item.action) {
        this.item.action();
      }
      else if (this.has_children || this.might_have_children) {
        this.expanded = !this.expanded;
      }
    },

    async refresh_buildings () {
      try {
        const buildings: Array<any> = await this.item.load_children_callback();
        this.children = this.item.convert_children_callback(buildings);
      }
      catch (err) {
        this.clientState.add_error_message('Failure loading details from server', err);
        this.loading_error = true;
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

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
