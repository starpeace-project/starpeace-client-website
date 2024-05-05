<template lang='pug'>
.columns.m-0.is-relative.is-clipped.rents-tab
  .column.is-narrow.p-0.sp-scrollbar.sp-sub-tabs
    .sp-tabs-menu
      ul
        template(v-for='rent,index in sortedRents')
          li(:class="{ 'is-active': rentIndex == index }" @click.stop.prevent='selectRent(index)')
            a.sp-kv-key.py-2.px-3 {{ $resourceTypeLabel(rent.resourceId) }}

  .column.px-3.py-1.sp-has-dark-background.price-settings
    .is-flex.is-flex-direction-column(v-if='rent')

      .is-inline-flex.is-flex-direction-row
        .is-inline-flex.is-flex-direction-column
          div
            span.sp-kv-key {{ $translate('toolbar.inspect.rent.label.rent') }}:
            span.sp-kv-value {{ $formatPercent(rent.rentFactor) }}
          misc-percent-slider(
            :markers='[0, 100, 200]'
            :min='0'
            :max='200'
            :percent='rent.rentFactor'
            :disabled='!canManage'
            @update='updateRentFactor(rent.resourceId, $event)'
            @change='debouncedUpdateBuildingMaintenance(building.id, rent.resourceId, $event)'
          )
        .is-inline-flex.is-flex-direction-column.ml-3
          div
            span.sp-kv-key {{ $translate('toolbar.inspect.rent.label.maintenance') }}:
            span.sp-kv-value {{ $formatPercent(rent.maintenanceFactor) }}
          misc-percent-slider(
            :markers='[0, 100, 200]'
            :min='0'
            :max='200'
            :percent='rent.maintenanceFactor'
            :disabled='!canManage'
            @update='updateMaintenanceFactor(rent.resourceId, $event)'
            @change='debouncedUpdateBuildingRent(building.id, rent.resourceId, $event)'
          )

      div.mt-3
        span.sp-kv-key Extra Beauty:
        span.sp-kv-value 0
      div
        span.sp-kv-key Crime Resistance:
        span.sp-kv-value 0
      div
        span.sp-kv-key Pollution Resistance:
        span.sp-kv-value 0
      div
        span.sp-kv-key Extra Privacy:
        span.sp-kv-value 0
</template>

<script lang='ts'>
import _ from 'lodash';

import { BuildingDefinition, SimulationDefinition } from '@starpeace/starpeace-assets-types';

import ClientState from '~/plugins/starpeace-client/state/client-state';
import BuildingRent from '~/plugins/starpeace-client/building/details/building-rent.js';
import Building from '~/plugins/starpeace-client/building/building.js';

declare interface TabRentsData {
  debouncedUpdateBuildingRent: (buildingId: string, resourceId: string, rentFactor: number) => void;
  debouncedUpdateBuildingMaintenance: (buildingId: string, resourceId: string, maintenanceFactor: number) => void;

  rentIndex: number;
  selectedIndices: Record<string, boolean>;
}

export default {
  props: {
    clientState: { type: ClientState, required: true },

    building: { type: Building, required: true },
    definition: { type: BuildingDefinition, required: true },
    simulation: { type: SimulationDefinition, required: true },

    rents: { type: Array<BuildingRent>, required: true },
  },

  data (): TabRentsData {
    return {
      debouncedUpdateBuildingRent: this.$debounce(250, async (buildingId: string, resourceId: string, rentFactor: number) => {
        await this.$starpeaceClient.managers.building_manager.update_building_settings(buildingId, {
          rent: {
            resourceId: resourceId,
            rentFactor: rentFactor
          }
        });
      }),
      debouncedUpdateBuildingMaintenance: this.$debounce(250, async (buildingId: string, resourceId: string, maintenanceFactor: number) => {
        await this.$starpeaceClient.managers.building_manager.update_building_settings(buildingId, {
          rent: {
            resourceId: resourceId,
            maintenanceFactor: maintenanceFactor
          }
        });
      }),

      rentIndex: 0,
      selectedIndices: {}
    };
  },

  computed: {
    canManage (): boolean {
      return this.clientState.player.corporation_id === this.building.corporationId;
    },

    sortedRents (): Array<BuildingRent> {
      return _.orderBy(this.rents, [(t) => this.$resourceTypeLabel(t.resourceId)], ['asc']);
    },
    rent (): BuildingRent | undefined {
      return this.rentIndex < this.sortedRents.length ? this.sortedRents[this.rentIndex] : undefined;
    }
  },

  watch: {
    rentIndex () {
      this.selectedIndices = {};
    }
  },

  methods: {
    selectRent (index: number): void {
      this.rentIndex = index;
    },

    updateRentFactor (resourceId: string, rentPercent: number): void {
      if (this.rent?.resourceId === resourceId) {
        this.rent.rentFactor = rentPercent;
      }
    },
    updateMaintenanceFactor (resourceId: string, maintenancePercent: number) {
      if (this.rent?.resourceId === resourceId) {
        this.rent.maintenanceFactor = maintenancePercent;
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'
@import '~/assets/stylesheets/starpeace-inspect'

.rents-tab
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
