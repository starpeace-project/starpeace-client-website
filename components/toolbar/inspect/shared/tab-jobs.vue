<template lang='pug'>
.jobs-tab.columns.is-marginless
  .column.is-narrow.is-paddingless.p-3
    table.basic-table
      thead
        tr
          th
          th.has-text-right.sp-kv-key(v-for='job in jobs') {{ $resourceTypeLabel(job.resourceId) }}
      tbody
        tr
          td.sp-kv-key {{$translate('toolbar.inspect.jobs.label.workers')}}
          td.has-text-right.sp-kv-value(v-for='job in jobs') {{job.mostRecentVelocity}} / {{job.maxVelocity}}
        tr
          td.sp-kv-key {{$translate('toolbar.inspect.jobs.label.quality')}}
          td.has-text-right.sp-kv-value(v-for='job in jobs') {{$formatPercent(0)}}
        tr
          td.sp-kv-key {{$translate('toolbar.inspect.jobs.label.salary')}}
          td.has-text-right.sp-kv-value(v-for='job in jobs')
            div
              span {{$format_money(job.price)}}
              span.ml-1 ({{ $formatPercent(job.price, $resourceTypePrice(job.resourceId)) }})
            misc-resource-price-slider(
              :markers='[0, 100, 250]'
              :min='0'
              :max='250'
              :resource-id='job.resourceId'
              :price='job.price'
              :disabled='!canManage'
              @update='updateSalary(job.resourceId, $event)'
              @change='debouncedUpdateBuildingSalary(building.id, job.resourceId, $event)'
            )

</template>

<script lang='ts'>
import _ from 'lodash';

import { BuildingDefinition, ResourceType, SimulationDefinition } from '@starpeace/starpeace-assets-types';

import ClientState from '~/plugins/starpeace-client/state/client-state.js';
import Labor from '~/plugins/starpeace-client/building/details/building-labor.js';
import Building from '~/plugins/starpeace-client/building/building.js';
import BuildingLabor from '~/plugins/starpeace-client/building/details/building-labor.js';

declare interface TabJobsData {
  debouncedUpdateBuildingSalary: (buildingId: string, resourceId: string, price: number) => void;
}

export default {
  props: {
    clientState: { type: ClientState, required: true },

    building: { type: Building, required: true },
    definition: { type: BuildingDefinition, required: true },
    simulation: { type: SimulationDefinition, required: true },

    jobs: { type: Array<Labor>, required: true },
  },

  data (): TabJobsData {
    return {
      debouncedUpdateBuildingSalary: this.$debounce(250, async (buildingId: string, resourceId: string, price: number) => {
        await this.$starpeaceClient.managers.building_manager.update_building_settings(buildingId, {
          labor: {
            resourceId: resourceId,
            price: price
          }
        });
      })
    };
  },

  computed: {
    canManage (): boolean {
      return this.clientState.player.corporation_id === this.building.corporationId;
    },

    jobByResourceId (): Record<string, BuildingLabor> {
      return Object.fromEntries(this.jobs.map(j => [j.resourceId, j]));
    }
  },

  methods: {
    updateSalary (resourceId: string, price: number) {
      if (this.jobByResourceId[resourceId]) {
        this.jobByResourceId[resourceId].price = price;
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'
@import '~/assets/stylesheets/starpeace-inspect'
</style>
