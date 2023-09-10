<template lang='pug'>
.products-tab.columns.is-marginless
  .column.is-narrow.is-paddingless.sp-scrollbar.products
    .product-tabs
      ul
        template(v-for='product,index in sortedProducts')
          li(:class="{ 'is-active': productIndex == index }" @click.stop.prevent='productIndex = index')
            a.sp-kv-key {{resourceTypeLabel(product.resource_id)}}

  .column.connections
    .connection-information(v-if='product')
      span.sp-kv-key {{$translate('toolbar.inspect.products.label.price')}}:
      span.sp-kv-value {{$format_percent(priceRatio)}} ({{$format_money(product.price)}})
      span.sp-kv-key {{$translate('toolbar.inspect.products.label.last_value')}}:
      span.sp-kv-value {{$format_number(product.total_velocity)}} {{resourceTypeLabel(product.resource_id)}}
      span.sp-kv-key {{$translate('toolbar.inspect.products.label.quality')}}:
      span.sp-kv-value {{$format_percent(product.quality)}}

    .connection-details.sp-scrollbar
      table
        thead
          tr
            th.sp-kv-key {{$translate('toolbar.inspect.products.label.customer')}}
            th.sp-kv-key {{$translate('toolbar.inspect.products.label.company')}}
            th.has-text-right.sp-kv-key {{$translate('toolbar.inspect.products.label.sales')}}
            th.has-text-right.sp-kv-key {{$translate('toolbar.inspect.products.label.transport_cost')}}
        tbody
          template(v-if='!connections.length')
            tr.is-empty
              td(colspan=4) {{$translate('ui.misc.none')}}
          template(v-else v-for='connection,index in connections')
            tr(:class="{ 'is-active': selectedIndices[index] }" @click.stop.prevent='clickConnection(connection, index)')
              td.sp-kv-value
                span.validity-icon
                  template(v-if='connection.valid')
                    font-awesome-icon(:icon="['fas', 'check']")
                  template(v-else)
                    font-awesome-icon(:icon="['fas', 'times']")
                | {{connection.sink_building_name}}
              td.sp-kv-value {{connection.sink_company_name}}
              td.has-text-right.sp-kv-value {{$format_number(connection.velocity)}}
              td.has-text-right.sp-kv-value {{$format_money(connection.transport_cost)}}

</template>

<script lang='ts'>
import _ from 'lodash';
import ClientState from '~/plugins/starpeace-client/state/client-state.coffee';

declare interface TabProductsData {
  clickTimeout: ReturnType<typeof setTimeout> | null;

  productIndex: number;
  selectedIndices: Record<string, boolean>;
}

export default {
  props: {
    clientState: { type: ClientState, required: true },

    products: Array,

    building: Object,
    definition: Object,
    simulation: Object
  },

  data (): TabProductsData {
    return {
      clickTimeout: null,

      productIndex: 0,
      selectedIndices: {}
    };
  },

  computed: {
    sortedProducts () { return _.orderBy(this.products, [(t) => this.resourceTypeLabel(t.resource_id)], ['asc']); },

    product () { return this.sortedProducts[this.productIndex]; },

    priceRatio () {
      const ifel_price = this.resourceType(this.product.resource_id)?.price ?? 0;
      return ifel_price > 0 ? (this.product.price / ifel_price) : 0
    },

    connections () { return this.product?.connections ?? []; }
  },

  watch: {
    productIndex () {
      this.selectedIndices = {};
    }
  },

  methods: {
    resourceType (type_id: string) { return this.clientState.core.planet_library.resource_type_for_id(type_id); },
    resourceTypeLabel (type_id: string) { return this.$translate(this.resourceType(type_id)?.label_plural); },

    validConnection (index: number) { return index % 3 == 0; },

    clickConnection (connection, index) {
      if (this.clickTimeout) {
        clearTimeout(this.clickTimeout);
        this.clickTimeout = null;
        this.jumpConnection(connection);
      }
      else {
        const should_deselect = this.selectedIndices[index];
        this.$set(this.selectedIndices, index, true);
        this.clickTimeout = setTimeout(() => {
          if (should_deselect) this.$delete(this.selectedIndices, index);
          this.clickTimeout = null
        }, 250);
      }
    },

    jumpConnection (connection) {
      if (connection?.sink_building_map_x && connection?.sink_building_map_y) {
        this.clientState.jump_to(connection.sink_building_map_x, connection.sink_building_map_y, null);
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.products-tab
  height: 100%
  position: relative
  overflow: hidden
  width: 100%

.button
  letter-spacing: .1rem
  text-transform: uppercase

.column
  &.products
    direction: rtl
    overflow-y: auto

    .product-tabs
      direction: ltr

      ul
        flex-direction: column

        li
          display: flex
          justify-content: flex-end
          margin-left: .25rem
          text-align: right

          a
            border-radius: 0
            color: $sp-primary
            padding: .5rem
            letter-spacing: .05rem
            text-transform: uppercase

            &:hover
              color: $sp-light

            &:active
              color: lighten($sp-light, 10%)

          &.is-active
            a
              background-color: $sp-dark-bg
              color: #fff

  &.connections
    background-color: $sp-dark-bg
    display: grid
    grid-template-columns: auto
    grid-template-rows: [start-information] 2rem [end-information start-details] auto [end-details]
    overflow: hidden
    padding: .25rem
    position: relative

    .connection-information
      grid-column: 1 / 2
      grid-row: start-information / end-information

      .sp-kv-key
        margin-left: 1rem

        &:not(:first-child)
          margin-left: 4rem

    .connection-details
      border: 1px solid $sp-primary-bg
      grid-column: 1 / 2
      grid-row: start-details / end-details
      overflow-y: auto

    table
      position: relative
      width: 100%

      tbody
        tr
          &:not(.is-empty)
            cursor: pointer

          td
            background-color: #fff
            border-bottom: 1px solid lighten($sp-light-bg, 40%)

          &:nth-child(even)
            td
              background-color: lighten($sp-light-bg, 55%)

          &.is-active
            td
              color: #fff
              background-color: $sp-light-bg
              border-bottom: 1px solid $sp-primary-bg

      th
        background-color: $sp-primary-bg
        color: $sp-light
        padding: .5rem
        position: sticky
        top: 0

      td
        color: #000
        padding: .25rem .5rem
        vertical-align: middle

    .validity-icon
      display: inline-block
      text-align: center
      margin-right: .5rem
      width: 1.5rem

</style>
