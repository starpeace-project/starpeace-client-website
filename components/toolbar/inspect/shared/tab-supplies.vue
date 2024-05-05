<template lang='pug'>
.columns.m-0.is-relative.is-clipped.supplies-tab
  .column.is-narrow.p-0.sp-scrollbar.sp-sub-tabs
    .sp-tabs-menu
      ul
        template(v-for='supply,index in sortedSupplies')
          li(:class="{ 'is-active': supplyIndex == index }" @click.stop.prevent='selectSupply(index)')
            a.sp-kv-key.py-2.px-3 {{$resourceTypeLabel(supply.resourceId)}}

  .column.is-narrow.px-3.py-1.is-flex.is-flex-direction-column.sp-has-dark-background.price-settings
    div.is-flex-grow-1(v-if='supply')
      div.is-flex.is-flex-direction-row.is-align-items-baseline
        span.sp-kv-key {{ $translate('toolbar.inspect.supplies.label.max_price') }}:
        div.sp-kv-value.price-value {{ $format_money(supply.maxPrice) }} ({{ $formatPercent(supply.maxPrice, $resourceTypePrice(supply.resourceId)) }})
      misc-resource-price-slider(
        :markers='[0, 100, 400]'
        :min='0'
        :max='400'
        :resource-id='supply.resourceId'
        :price='supply.maxPrice'
        :disabled='!canManage'
        @update='updateMaxPrice(supply.resourceId, $event)'
        @change='debouncedUpdateBuildingMaxPrice(building.id, supply.resourceId, $event)'
      )
      div.mt-1
        span.sp-kv-key {{ $translate('toolbar.inspect.supplies.label.min_quality') }}:
        span.sp-kv-value {{ $formatPercent(supply.minQuality) }}
      misc-percent-slider(
        :markers='[0, 50, 100]'
        :min='0'
        :max='100'
        :percent='supply.minQuality'
        :disabled='!canManage'
        @update='updateMinQuality(supply.resourceId, $event)'
        @change='debouncedUpdateBuildingMinQuality(building.id, supply.resourceId, $event)'
      )
    .is-flex.is-flex-direction-row.mt-2
      button.button.is-fullwidth.is-starpeace.disabled(disabled) {{ $translate('toolbar.inspect.supplies.action.hire') }}
      button.button.is-fullwidth.is-starpeace.ml-2(disabled) {{ $translate('toolbar.inspect.supplies.action.modify') }}


  .column.connections.p-1
    .connection-information(v-if='supply')
      span.sp-kv-key.ml-2 {{ $translate('toolbar.inspect.supplies.label.last_value') }}:
      span.sp-kv-value {{ $format_number(supply.mostRecentVelocity) }} {{ $resourceTypeUnitLabel(supply.resourceId) }}
      span.sp-kv-key.ml-5 {{ $translate('toolbar.inspect.supplies.label.price') }}:
      span.sp-kv-value {{ $format_money(supply.mostRecentPrice) }} ({{ $formatPercent(supply.mostRecentPrice, $resourceTypePrice(supply.resourceId)) }})
      span.sp-kv-key.ml-5 {{ $translate('toolbar.inspect.supplies.label.quality') }}:
      span.sp-kv-value {{ $formatPercent(supply.mostRecentTotalQuality, supply.mostRecentVelocity) }}

    .connection-details.sp-scrollbar
      table
        thead
          tr
            th.column-validity
            th.sp-kv-key {{ $translate('toolbar.inspect.supplies.label.facility') }}
            th.sp-kv-key {{ $translate('toolbar.inspect.supplies.label.company') }}
            th.has-text-right.sp-kv-key {{ $translate('toolbar.inspect.supplies.label.price') }}
            th.has-text-right.sp-kv-key {{ $translate('toolbar.inspect.supplies.label.last_value') }}
            th.has-text-right.sp-kv-key {{ $translate('toolbar.inspect.supplies.label.quality') }}
            th.has-text-right.sp-kv-key {{ $translate('toolbar.inspect.supplies.label.transport_cost') }}
        tbody
          template(v-if='!connections.length')
            tr.is-empty
              td(colspan=7) {{$translate('ui.misc.none')}}

          template(v-else v-for='connection,index in connections')
            tr(:class="{ 'is-active': selectedIndices[index] }" @click.stop.prevent='clickConnection(connection, index)')
              td.sp-kv-value
                span.validity-icon
                  template(v-if='connection.valid')
                    font-awesome-icon(:icon="['fas', 'check']")
                  template(v-else)
                    font-awesome-icon(:icon="['fas', 'times']")
              td.sp-kv-value
                span(v-if='connection.sourceBuildingName') {{ connection.sourceBuildingName }}
                span(v-else-if='connection.sourceBuildingDefinitionId') {{ buildingName(connection.sourceBuildingDefinitionId) }}
              td.sp-kv-value {{ connection.sourceCompanyName }}
              td.has-text-right.sp-kv-value {{ $format_money(connection.mostRecentPrice) }}
              td.has-text-right.sp-kv-value {{ $format_number(connection.mostRecentVelocity) }}
              td.has-text-right.sp-kv-value {{ $formatPercent(connection.mostRecentQuality) }}
              td.has-text-right.sp-kv-value {{ $format_money(connection.mostRecentTransportCost) }}

</template>

<script lang='ts'>
import _ from 'lodash';

import { BuildingDefinition, ResourceType, ResourceUnit, SimulationDefinition } from '@starpeace/starpeace-assets-types';

import ClientState from '~/plugins/starpeace-client/state/client-state';
import BuilingInput from '~/plugins/starpeace-client/building/details/building-input.js';
import Building from '~/plugins/starpeace-client/building/building.js';
import BuildingConnection from '~/plugins/starpeace-client/building/details/building-connection';

declare interface TabSuppliesData {
  debouncedUpdateBuildingMaxPrice: (buildingId: string, resourceId: string, price: number) => void;
  debouncedUpdateBuildingMinQuality: (buildingId: string, resourceId: string, quality: number) => void;
  clickTimeout: ReturnType<typeof setTimeout> | null;

  supplyIndex: number;
  selectedIndices: Record<string, boolean>;

  connectionsBuildingId: string | undefined,
  connections: BuildingConnection[];
  connectionsPromise: Promise<BuildingConnection[]> | undefined;
}

export default {
  props: {
    clientState: { type: ClientState, required: true },

    building: { type: Building, required: true },
    definition: { type: BuildingDefinition, required: true },
    simulation: { type: SimulationDefinition, required: true },

    supplies: { type: Array<BuilingInput>, required: true },
  },

  data (): TabSuppliesData {
    return {
      debouncedUpdateBuildingMaxPrice: this.$debounce(250, async (buildingId: string, resourceId: string, price: number) => {
        await this.$starpeaceClient.managers.building_manager.update_building_settings(buildingId, {
          input: {
            resourceId: resourceId,
            maxPrice: price
          }
        });
      }),
      debouncedUpdateBuildingMinQuality: this.$debounce(250, async (buildingId: string, resourceId: string, quality: number) => {
        await this.$starpeaceClient.managers.building_manager.update_building_settings(buildingId, {
          input: {
            resourceId: resourceId,
            minQuality: quality
          }
        });
      }),
      clickTimeout: null,

      supplyIndex: 0,
      selectedIndices: {},

      connectionsBuildingId: undefined,
      connections: [],
      connectionsPromise: undefined
    };
  },

  computed: {
    canManage (): boolean {
      return this.clientState.player.corporation_id === this.building.corporationId;
    },

    sortedSupplies (): Array<BuilingInput> {
      return _.orderBy(this.supplies, [(t) => this.$resourceTypeLabel(t.resourceId)], ['asc']);
    },
    supply (): BuilingInput | undefined {
      return this.supplyIndex < this.sortedSupplies.length ? this.sortedSupplies[this.supplyIndex] : undefined;
    },

    staleConnections (): boolean {
      return this.connectionsBuildingId !== this.building.id;
    }
  },

  watch: {
    supplyIndex () {
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

    selectSupply (index: number): void {
      this.supplyIndex = index;
    },

    updateMaxPrice (resourceId: string, price: number) {
      if (this.supply?.resourceId === resourceId) {
        this.supply.maxPrice = price;
      }
    },
    updateMinQuality (resourceId: string, qualityPercent: number) {
      if (this.supply?.resourceId === resourceId) {
        this.supply.minQuality = qualityPercent;
      }
    },

    async refreshBuildingConnections (): Promise<void> {
      if (!this.supply) {
        return;
      }

      if (this.connectionsBuildingId !== this.building?.id) {
        this.connections = [];
      }

      try {
        this.connectionsPromise = this.$starpeaceClient.managers.building_manager.loadBuildingConnections(this.building.id, 'input', this.supply.resourceId, true);
        this.connections = await this.connectionsPromise;
        this.connectionsBuildingId = this.building.id;
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
      if (connection?.sourceBuildingMapX !== undefined && connection?.sourceBuildingMapY !== undefined) {
        this.clientState.jump_to(connection.sourceBuildingMapX, connection.sourceBuildingMapY, null);
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'
@import '~/assets/stylesheets/starpeace-inspect'

.supplies-tab
  height: 100%
  width: 100%

.sp-slider
  display: flex

  input
    width: 100%

.column
  &.price-settings
    .price-value
      min-width: 8rem

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
