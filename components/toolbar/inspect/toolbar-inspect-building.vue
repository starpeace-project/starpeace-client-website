<template lang='pug'>
.inspect-details
  .inspect-tabs.tabs.is-small.m-0
    ul
      template(v-for='tab in tabs')
        li(:class="{ 'is-active': tab.id == tabId }" @click.stop.prevent='tabId = tab.id')
          a
            span {{ $translate(tab.label) }}

  .inspect-body.columns.m-0
    template(v-if="tabId == 'general'")
      .column.p-0.is-relative.is-clipped
        toolbar-inspect-shared-tab-general(
          :client-state='clientState'
          :building='building'
          :definition='definition'
          :simulation='simulation'
          :building-details='buildingDetails'
          @refresh-details="$emit('refresh-details')"
        )

    template(v-if="tabId == 'research'")
      .column.p-0.is-relative.is-clipped
        toolbar-inspect-tab-headquarters-research(
          :client-state='clientState'
          :building='building'
          :definition='definition'
          :simulation='simulation'
        )

    template(v-else-if="tabId == 'operations' || tabId == 'supplies'")
      .column.p-0.is-relative.is-clipped
        toolbar-inspect-shared-tab-supplies(
          :client-state='clientState'
          :building='building'
          :definition='definition'
          :simulation='simulation'
          :supplies='buildingDetails.inputs'
        )

    template(v-else-if="tabId == 'products'")
      .column.p-0.is-relative.is-clipped
        toolbar-inspect-shared-tab-products(
          :client-state='clientState'
          :building='building'
          :definition='definition'
          :simulation='simulation'
          :products='buildingDetails.outputs'
        )

    template(v-else-if="tabId == 'services'")
      .column.p-0.is-relative.is-clipped
        toolbar-inspect-shared-tab-services(
          :client-state='clientState'
          :building='building'
          :definition='definition'
          :simulation='simulation'
          :services='buildingDetails.services'
        )

    template(v-else-if="tabId == 'jobs'")
      .column.p-0.is-relative.is-clipped
        toolbar-inspect-shared-tab-jobs(
          :client-state='clientState'
          :building='building'
          :definition='definition'
          :simulation='simulation'
          :jobs='buildingDetails.labors'
        )

    template(v-else-if="tabId == 'management'")
      .column.p-0.is-relative.is-clipped
        toolbar-inspect-shared-tab-management(
          :client-state='clientState'
          :building='building'
          :definition='definition'
          :simulation='simulation'
          :building-details='buildingDetails'
          @refresh-details="$emit('refresh-details')"
        )

    template(v-else-if="tabId == 'history'")
      .column.p-0.is-relative.is-clipped
        toolbar-inspect-shared-tab-history(
          :client-state='clientState'
          :building='building'
          :definition='definition'
          :simulation='simulation'
        )

</template>

<script lang='ts'>
import { BuildingDefinition, FactoryDefinition, FarmDefinition, HeadquartersDefinition, SimulationDefinition, StorageDefinition } from '@starpeace/starpeace-assets-types';

import ClientState from '~/plugins/starpeace-client/state/client-state';
import Building from '~/plugins/starpeace-client/building/building';
import BuildingDetails from '~/plugins/starpeace-client/building/building-details';

export default {
  props: {
    clientState: { type: ClientState, required: true },

    building: { type: Building, required: true },
    definition: { type: BuildingDefinition, required: true },
    simulation: { type: SimulationDefinition, required: true },

    buildingDetails: { type: BuildingDetails, required: true }
  },

  computed: {
    tabId: {
      get (): string | undefined {
        return this.clientState.interface.selectedInspectTabId;
      },
      set (value: string | undefined): void {
        this.clientState.interface.selectedInspectTabId = value;
      }
    },

    tabs (): Array<any> {
      const isHeadquarters = this.simulation instanceof HeadquartersDefinition;
      const isFactory = this.simulation instanceof FactoryDefinition;
      const isFarm = this.simulation instanceof FarmDefinition;
      const isStorage = this.simulation instanceof StorageDefinition;

      const tabs = [
        {
          id: 'general',
          label: 'toolbar.inspect.common.tabs.general'
        }
      ];
      if (isHeadquarters) {
        tabs.push({
          id: 'research',
          label: 'toolbar.inspect.common.tabs.research'
        });
      }
      if (this.buildingDetails.inputs?.length > 0) {
        if (isHeadquarters) {
          tabs.push({
            id: 'operations',
            label: 'toolbar.inspect.common.tabs.operations'
          });
        }
        else {
          tabs.push({
            id: 'supplies',
            label: 'toolbar.inspect.common.tabs.supplies'
          });
        }
      }
      if (this.buildingDetails.outputs?.length > 0 && (isFactory || isFarm || isStorage)) {
        tabs.push({
          id: 'products',
          label: 'toolbar.inspect.common.tabs.products'
        });
      }
      if (this.buildingDetails.services?.length > 0) {
        tabs.push({
          id: 'services',
          label: 'toolbar.inspect.common.tabs.services'
        });
      }
      if (this.buildingDetails.labors?.length > 0) {
        tabs.push({
          id: 'jobs',
          label: 'toolbar.inspect.common.tabs.jobs'
        });
      }
      if (!!this.building.constructionFinishedAt) {
        tabs.push({
          id: 'management',
          label: 'toolbar.inspect.common.tabs.management'
        });
        tabs.push({
          id: 'history',
          label: 'toolbar.inspect.common.tabs.history'
        });
      }
      return tabs;
    }
  },

  watch: {
    tabs: {
      immediate: true,
      handler () {
        if (!this.tabs.length) {
          this.tabId = undefined;
        }
        else if (!this.tabId || !this.tabs.find(t => t.id === this.tabId)) {
          this.tabId = this.tabs[0].id;
        }
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'
@import '~/assets/stylesheets/starpeace-inspect'
</style>
