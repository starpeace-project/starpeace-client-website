<template lang='pug'>
.columns.m-0.is-relative.is-clipped.products-tab
  .column.is-narrow.p-0.sp-scrollbar.sp-sub-tabs
    .sp-tabs-menu
      ul
        template(v-for='product,index in sortedProducts')
          li(:class="{ 'is-active': productIndex == index }" @click.stop.prevent='selectProduct(index)')
            a.sp-kv-key.py-2.px-3 {{$resourceTypeLabel(product.resourceId)}}

  .column.px-3.py-1.sp-has-dark-background.price-settings
    .is-flex.is-flex-direction-column(v-if='product')
      div
        span.sp-kv-key {{ $translate('toolbar.inspect.products.label.local_demand') }}:
        span.sp-kv-value {{ $formatPercent(productDemandRatio) }}
      div
        span.sp-kv-key Supply:
        span.sp-kv-value {{ $formatPercent(productSupplyRatio) }}
      div
        span.sp-kv-key {{$translate('toolbar.inspect.products.label.price')}}:
        span.sp-kv-value {{$format_money(product.price)}} ({{ $formatPercent(product.price, $resourceTypePrice(product.resourceId)) }})
      misc-resource-price-slider(
        :markers='[0, 300, 500]'
        :min='0'
        :max='500'
        :resource-id='product.resourceId'
        :price='product.price'
        :disabled='!canManage'
        @update='updatePrice(product.resourceId, $event)'
        @change='debouncedUpdateBuildingPrice(building.id, product.resourceId, $event)'
      )
</template>

<script lang='ts'>
import _ from 'lodash';

import { BuildingDefinition, SimulationDefinition } from '@starpeace/starpeace-assets-types';

import ClientState from '~/plugins/starpeace-client/state/client-state';
import BuildingOutput from '~/plugins/starpeace-client/building/details/building-output.js';
import Building from '~/plugins/starpeace-client/building/building.js';

declare interface TabStoreProductsData {
  debouncedUpdateBuildingPrice: (buildingId: string, resourceId: string, price: number) => void;

  productIndex: number;
  selectedIndices: Record<string, boolean>;
}

export default {
  props: {
    clientState: { type: ClientState, required: true },

    building: { type: Building, required: true },
    definition: { type: BuildingDefinition, required: true },
    simulation: { type: SimulationDefinition, required: true },

    products: { type: Array<BuildingOutput>, required: true },
  },

  data (): TabStoreProductsData {
    return {
      debouncedUpdateBuildingPrice: this.$debounce(250, async (buildingId: string, resourceId: string, price: number) => {
        await this.$starpeaceClient.managers.building_manager.update_building_settings(buildingId, {
          output: {
            resourceId: resourceId,
            price: price
          }
        });
      }),
      productIndex: 0,
      selectedIndices: {}
    };
  },

  computed: {
    canManage (): boolean {
      return this.clientState.player.corporation_id === this.building.corporationId;
    },

    sortedProducts (): Array<BuildingOutput> {
      return _.orderBy(this.products, [(t) => this.$resourceTypeLabel(t.resourceId)], ['asc']);
    },
    product (): BuildingOutput | undefined {
      return this.productIndex < this.sortedProducts.length ? this.sortedProducts[this.productIndex] : undefined;
    },

    productDemandRatio (): number {
      return 0;
    },
    productSupplyRatio (): number {
      return 0;
    }
  },

  watch: {
    productIndex () {
      this.selectedIndices = {};
    }
  },

  methods: {
    selectProduct (index: number): void {
      this.productIndex = index;
    },

    updatePrice (resourceId: string, price: number) {
      if (this.product?.resourceId === resourceId) {
        this.product.price = price;
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'
@import '~/assets/stylesheets/starpeace-inspect'

.products-tab
  height: 100%
  width: 100%

.price-settings
  :deep(.sp-slider)
    input
      max-width: 12rem

.column
  &.connections
    background-color: $sp-dark-bg
    display: grid
    grid-template-columns: auto
    grid-template-rows: [start-information] 2rem [end-information start-details] auto [end-details]
    overflow: hidden
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
