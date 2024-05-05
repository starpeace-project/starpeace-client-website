<template lang='pug'>
.inspect-details
  .inspect-tabs.tabs.is-small.m-0
    ul
      li(v-for='tab in tabs' :class="{ 'is-active': tabId == tab.id }" @click.stop.prevent='tabId = tab.id')
        a {{$translate(tab.label)}}

  .inspect-body.columns.m-0
    template(v-if="tabId == 'general'")
      .column.is-narrow.pr-5.general
        div
          span.sp-kv-key {{$translate('toolbar.inspect.common.label.name')}}:
          span.sp-kv-value
            template(v-if='name') {{name}}
            template(v-else) {{$translate('ui.misc.none')}}
        div
          span.sp-kv-key {{$translate('toolbar.inspect.common.label.built')}}:
          span.sp-kv-value {{constructionDate}}
        div
          span.sp-kv-key {{$translate('toolbar.inspect.common.label.owner')}}:
          span.sp-kv-value IFEL

    template(v-else-if="tabId == 'products'")
      .column.p-0.is-relative.is-clipped
        toolbar-inspect-shared-tab-products(
          :client-state='clientState'
          :products='products'
          :building='building'
          :definition='definition'
          :simulation='simulation'
        )

    template(v-else-if="tabId == 'jobs'")
      .column.p-0.is-relative.is-clipped
        toolbar-inspect-shared-tab-jobs(
          :client-state='clientState'
          :jobs='jobs'
          :building='building'
          :definition='definition'
          :simulation='simulation'
        )

</template>

<script lang='ts'>
import { BuildingDefinition, SimulationDefinition } from '@starpeace/starpeace-assets-types';

import ClientState from '~/plugins/starpeace-client/state/client-state';
import Building from '~/plugins/starpeace-client/building/building';
import BuildingDetails from '~/plugins/starpeace-client/building/building-details';

declare interface ToolbarInspectTradeCenterData {
  tabId: string | undefined;
}

export default {
  props: {
    clientState: { type: ClientState, required: true },

    building: { type: Building, required: true },
    definition: { type: BuildingDefinition, required: true },
    simulation: { type: SimulationDefinition, required: true },

    buildingDetails: { type: BuildingDetails, required: true }
  },

  data (): ToolbarInspectTradeCenterData {
    return {
      tabId: undefined
    };
  },

  computed:  {
    buildingId () { return this.building.id; },
    name () {
      if (this.building?.name) return this.building.name;
      if (this.definition?.name) return this.$translate(this.definition.name);
      return null;
    },
    constructionDate () {
      return this.building.constructionFinishedAt?.toFormat('LLL dd, yyyy');
    },

    products () { return this.buildingDetails.outputs ?? []; },
    jobs () { return this.buildingDetails.labors ?? []; },

    tabs () {
      const tabs = [
        {
          id: 'general',
          label: 'toolbar.inspect.common.tabs.general'
        }
      ];
      if (this.products.length > 0) {
        tabs.push({
          id: 'products',
          label: 'toolbar.inspect.common.tabs.products'
        });
      }
      if (this.jobs.length > 0) {
        tabs.push({
          id: 'jobs',
          label: 'toolbar.inspect.common.tabs.jobs'
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
