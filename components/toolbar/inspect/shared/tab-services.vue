<template lang='pug'>
.columns.is-marginless.is-relative.is-clipped.services-tab
  .column.is-narrow.is-paddingless.sp-scrollbar.sp-sub-tabs
    .sp-tabs-menu
      ul
        template(v-for='service,index in sortedServices')
          li(:class="{ 'is-active': serviceIndex == index }" @click.stop.prevent='selectService(index)')
            a.sp-kv-key.py-2.px-3 {{ $resourceTypeLabel(service.resourceId) }}

  .column.is-paddingless.px-3.py-1.is-flex.is-flex-direction-column.sp-has-dark-background
    div.is-flex-grow-1(v-if='service')
      div.is-inline-flex.is-flex-direction-column
        div
          span.sp-kv-key {{ $translate('toolbar.inspect.services.label.requesting') }}:
          span.sp-kv-value {{ service.requestedVelocity }} {{ $resourceTypeUnitLabel(service.resourceId) }}
        .sp-slider
          input(
            type='range'
            list='requested-markers'
            step='any'
            min='0'
            :max='serviceMaxVelocity'
            :disabled='!canManage'
            v-model='serviceRequestedVelocity'
            @change='debouncedUpdateBuildingServices(building.id, service.resourceId, serviceRequestedVelocity)'
          )
          datalist(id='requested-markers')
            option(v-for='marker in serviceRequestedMarkers' :value='marker')

      div
        span.sp-kv-key {{ $translate('toolbar.inspect.services.label.receiving') }}:
        span.sp-kv-value {{ service.mostRecentVelocity }} {{ $resourceTypeUnitLabel(service.resourceId) }}
      div
        span.sp-kv-key {{ $translate('toolbar.inspect.services.label.ratio') }}:
        span.sp-kv-value {{ $formatPercent(service.mostRecentVelocity, service.requestedVelocity) }}

</template>

<script lang='ts'>
import _ from 'lodash';

import { BuildingDefinition, SimulationDefinition } from '@starpeace/starpeace-assets-types';

import ClientState from '~/plugins/starpeace-client/state/client-state.js';
import BuildingService from '~/plugins/starpeace-client/building/details/building-service.js';
import Building from '~/plugins/starpeace-client/building/building.js';

declare interface TabServicesData {
  debouncedUpdateBuildingServices: (buildingId: string, resourceId: string, velocity: number) => void;
  clickTimeout: ReturnType<typeof setTimeout> | null;

  serviceIndex: number;
  selectedIndices: Record<string, boolean>;
}

export default {
  props: {
    clientState: { type: ClientState, required: true },

    building: { type: Building, required: true },
    definition: { type: BuildingDefinition, required: true },
    simulation: { type: SimulationDefinition, required: true },

    services: { type: Array<BuildingService>, required: true },
  },

  data (): TabServicesData {
    return {
      debouncedUpdateBuildingServices: this.$debounce(250, async (buildingId: string, resourceId: string, velocity: number) => {
        await this.$starpeaceClient.managers.building_manager.update_building_settings(buildingId, {
          service: {
            resourceId: resourceId,
            requestedVelocity: velocity
          }
        });
      }),
      clickTimeout: null,

      serviceIndex: 0,
      selectedIndices: {}
    };
  },

  computed: {
    canManage (): boolean {
      return this.clientState.player.corporation_id === this.building.corporationId;
    },

    sortedServices (): Array<BuildingService> {
      return _.orderBy(this.services, [(t) => this.$resourceTypeLabel(t.resourceId)], ['asc']);
    },
    service (): BuildingService | undefined {
      return this.serviceIndex < this.sortedServices.length ? this.sortedServices[this.serviceIndex] : undefined;
    },

    serviceMaxVelocity (): number {
      return this.service ? Math.round(this.service.maxVelocity * 100) / 100 : 0;
    },

    serviceRequestedVelocity: {
      get (): number {
        return this.service?.requestedVelocity ?? 0;
      },
      set (value: number) {
        if (this.service) {
          const velocity = Math.round(value * 100) / 100;
          this.service.requestedVelocity = velocity;
        }
      }
    },

    serviceRequestedMarkers () {
      const maxVelocity = this.service?.maxVelocity ?? 0;
      if (maxVelocity > 0) {
        return [0, 0.5 * maxVelocity, maxVelocity];
      }
      return [];
    }
  },

  watch: {
    serviceIndex () {
      this.selectedIndices = {};
    }
  },

  methods: {
    selectService (index: number): void {
      this.serviceIndex = index;
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'
@import '~/assets/stylesheets/starpeace-inspect'

.sp-slider
  input
    max-width: 12rem

.services-tab
  height: 100%
  width: 100%

</style>
