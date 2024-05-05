<template lang='pug'>
.columns.m-0.is-relative.is-clipped.products-tab
  .column.is-narrow.p-0.sp-scrollbar.sp-sub-tabs
    .sp-tabs-menu
      ul
        template(v-for='product,index in sortedProducts')
          li(:class="{ 'is-active': productIndex == index }" @click.stop.prevent='selectProduct(index)')
            a.sp-kv-key.py-2.px-3 {{ $resourceTypeLabel(product.resourceId) }}

  .column.is-narrow.px-3.py-1.is-flex.is-flex-direction-column.sp-has-dark-background
    div.is-flex-grow-1(v-if='product')
      div
        span.sp-kv-key {{$translate('toolbar.inspect.products.label.price')}}:
        span.sp-kv-value {{$format_money(product.price)}} ({{ $formatPercent(product.price, $resourceTypePrice(product.resourceId)) }})
      misc-resource-price-slider(
        :markers='[0, 100, 400]'
        :min='0'
        :max='400'
        :resource-id='product.resourceId'
        :price='product.price'
        :disabled='!canManage'
        @update='updatePrice(product.resourceId, $event)'
        @change='debouncedUpdateBuildingPrice(building.id, product.resourceId, $event)'
      )

    div.mt-2
      button.button.is-fullwidth.is-starpeace.disabled.mb-2(disabled) Offer
      button.button.is-fullwidth.is-starpeace(disabled) Delete

  .column.connections.p-1
    .connection-information(v-if='product')
      span.sp-kv-key {{ $translate('toolbar.inspect.products.label.last_value') }}:
      span.sp-kv-value {{ $format_number(product.mostRecentVelocity) }} {{ $resourceTypeUnitLabel(product.resourceId) }}
      span.sp-kv-key {{ $translate('toolbar.inspect.products.label.quality') }}:
      span.sp-kv-value {{ $formatPercent(product.mostRecentTotalQuality, product.mostRecentVelocity) }}

    .connection-details.sp-scrollbar
      table
        thead
          tr
            th.column-validity
            th.sp-kv-key {{ $translate('toolbar.inspect.products.label.customer') }}
            th.sp-kv-key {{ $translate('toolbar.inspect.products.label.company') }}
            th.has-text-right.sp-kv-key {{ $translate('toolbar.inspect.products.label.sales') }}
            th.has-text-right.sp-kv-key {{ $translate('toolbar.inspect.products.label.transport_cost') }}
        tbody
          template(v-if='!connections.length')
            tr.is-empty
              td(colspan=5) {{$translate('ui.misc.none')}}

          template(v-else v-for='connection,index in connections')
            tr(:class="{ 'is-active': selectedIndices[index] }" @click.stop.prevent='clickConnection(connection, index)')
              td.sp-kv-value
                span.validity-icon
                  template(v-if='connection.valid')
                    font-awesome-icon(:icon="['fas', 'check']")
                  template(v-else)
                    font-awesome-icon(:icon="['fas', 'times']")
              td.sp-kv-value
                span(v-if='connection.sinkBuildingName') {{ connection.sinkBuildingName }}
                span(v-else-if='connection.sinkBuildingDefinitionId') {{ buildingName(connection.sinkBuildingDefinitionId) }}
              td.sp-kv-value {{ connection.sinkCompanyName }}
              td.has-text-right.sp-kv-value {{ $format_number(connection.mostRecentVelocity) }}
              td.has-text-right.sp-kv-value {{ $format_money(connection.mostRecentTransportCost) }}

</template>

<script lang='ts'>
import _ from 'lodash';

import { BuildingDefinition, SimulationDefinition } from '@starpeace/starpeace-assets-types';

import ClientState from '~/plugins/starpeace-client/state/client-state';
import BuildingOutput from '~/plugins/starpeace-client/building/details/building-output.js';
import Building from '~/plugins/starpeace-client/building/building.js';
import BuildingConnection from '~/plugins/starpeace-client/building/details/building-connection';

declare interface TabProductsData {
  debouncedUpdateBuildingPrice: (buildingId: string, resourceId: string, price: number) => void;
  clickTimeout: ReturnType<typeof setTimeout> | null;

  productIndex: number;
  selectedIndices: Record<string, boolean>;

  connectionsBuildingId: string | undefined,
  connectionsResourceId: string | undefined;
  connections: BuildingConnection[];
  connectionsPromise: Promise<BuildingConnection[]> | undefined;
}

export default {
  props: {
    clientState: { type: ClientState, required: true },

    building: { type: Building, required: true },
    definition: { type: BuildingDefinition, required: true },
    simulation: { type: SimulationDefinition, required: true },

    products: { type: Array<BuildingOutput>, required: true },
  },

  data (): TabProductsData {
    return {
      debouncedUpdateBuildingPrice: this.$debounce(250, async (buildingId: string, resourceId: string, price: number) => {
        await this.$starpeaceClient.managers.building_manager.update_building_settings(buildingId, {
          output: {
            resourceId: resourceId,
            price: price
          }
        });
      }),
      clickTimeout: null,

      productIndex: 0,
      selectedIndices: {},

      connectionsBuildingId: undefined,
      connectionsResourceId: undefined,
      connections: [],
      connectionsPromise: undefined
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

    staleConnections (): boolean {
      return this.connectionsBuildingId !== this.building.id || (!!this.product && this.connectionsResourceId !== this.product.resourceId);
    }
  },

  watch: {
    productIndex () {
      this.selectedIndices = {};
    },
    staleConnections: {
      immediate: true,
      handler () {
        this.refreshBuildingConnections();
      }
    }
  },

  methods: {
    buildingName (definitionId: string): string {
      const definition = this.clientState.core.building_library.definition_for_id(definitionId);
      return (definition ? this.$translate(definition.name) : undefined) ?? '';
    },

    selectProduct (index: number): void {
      this.productIndex = index;
    },

    updatePrice (resourceId: string, price: number) {
      if (this.product?.resourceId === resourceId) {
        this.product.price = price;
      }
    },

    async refreshBuildingConnections (): Promise<void> {
      if (!this.product) {
        return;
      }

      if (this.connectionsBuildingId !== this.building?.id || this.connectionsResourceId !== this.product.resourceId) {
        this.connections = [];
      }

      try {
        this.connectionsPromise = this.$starpeaceClient.managers.building_manager.loadBuildingConnections(this.building.id, 'output', this.product.resourceId, true);
        this.connections = await this.connectionsPromise;
        this.connectionsBuildingId = this.building.id;
        this.connectionsResourceId = this.product.resourceId;
        this.connectionsPromise = undefined;
      }
      catch (err) {
        this.clientState.add_error_message('Failure loading building connections, please try again', err);
        this.connectionsPromise = undefined;
      }
    },

    clickConnection (connection: any, index: number): void {
      if (this.clickTimeout) {
        clearTimeout(this.clickTimeout);
        this.clickTimeout = null;
        this.jumpConnection(connection);
      }
      else {
        const should_deselect = this.selectedIndices[index];
        this.selectedIndices[index] = true;
        this.clickTimeout = setTimeout(() => {
          if (should_deselect) {
            delete this.selectedIndices[index];
          }
          this.clickTimeout = null
        }, 250);
      }
    },
    jumpConnection (connection: BuildingConnection): void {
      if (connection?.sinkBuildingMapX !== undefined && connection?.sinkBuildingMapY !== undefined) {
        this.clientState.jump_to(connection.sinkBuildingMapX, connection.sinkBuildingMapY, null);
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
        z-index: 250

      td
        color: #000
        padding: .25rem .5rem
        vertical-align: middle

    .column-validity
      width: 2rem

    .validity-icon
      display: inline-block
      text-align: center
      margin-right: .5rem
      width: 1.5rem

</style>
