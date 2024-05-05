<template lang='pug'>
.jobs-tab.columns.m-0
  .column.is-narrow.p-4
    button.button.is-starpeace(:disabled='!canManage' @click.stop.prevent='showResearch') Show Research

</template>

<script lang='ts'>
import _ from 'lodash';

import { BuildingDefinition, SimulationDefinition } from '@starpeace/starpeace-assets-types';

import ClientState from '~/plugins/starpeace-client/state/client-state.js';
import Building from '~/plugins/starpeace-client/building/building.js';

export default {
  props: {
    clientState: { type: ClientState, required: true },

    building: { type: Building, required: true },
    definition: { type: BuildingDefinition, required: true },
    simulation: { type: SimulationDefinition, required: true },
  },

  computed: {
    canManage (): boolean {
      return this.clientState.player.corporation_id === this.building.corporationId;
    }
  },

  methods: {
    showResearch (): void {
      if (this.canManage) {
        this.clientState.player.set_company_id(this.building.companyId);
        this.clientState.menu.toggle_menu('research');
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'
@import '~/assets/stylesheets/starpeace-inspect'
</style>
