<template lang='pug'>
.inspect-details
  .inspect-tabs.tabs.is-small.is-marginless
    ul
      li(v-for='tab in tabs' :class="{ 'is-active': tabId == tab.id }" @click.stop.prevent='tabId = tab.id')
        a {{ $translate(tab.label) }}

  .inspect-body.columns.is-marginless
    template(v-if="tabId == 'general'")
      .column.is-paddingless.is-relative.is-clipped.p-4
        span.is-italic {{ message }}

    template(v-else-if="tabId == 'jobs'")
      .column.is-paddingless.is-relative.is-clipped
        toolbar-inspect-shared-tab-jobs(
          :client-state='clientState'
          :jobs='jobs'
          :building='building'
          :definition='definition'
          :simulation='simulation'
        )

</template>

<script lang='ts'>
import _ from 'lodash';

import { BuildingDefinition, SimulationDefinition } from '@starpeace/starpeace-assets-types';

import Building from '~/plugins/starpeace-client/building/building';
import BuildingDetails from '~/plugins/starpeace-client/building/building-details';
import ClientState from '~/plugins/starpeace-client/state/client-state';

export default {
  props: {
    clientState: { type: ClientState, required: true },

    building: { type: Building, required: true },
    definition: { type: BuildingDefinition, required: true },
    simulation: { type: SimulationDefinition, required: true },

    buildingDetails: { type: BuildingDetails, required: true }
  },

  data () {
    return {
      tabId: 'general'
    };
  },

  computed: {
    jobs () {
      return this.buildingDetails.labors ?? [];
    },

    tabs () {
      const tabs = [
        {
          id: 'general',
          label: 'toolbar.inspect.common.tabs.general'
        }
      ];
      if (this.jobs.length > 0) {
        tabs.push({
          id: 'jobs',
          label: 'toolbar.inspect.common.tabs.jobs'
        });
      }
      return tabs;
    },

    message (): string {
      const template = _.template(this.$translate('toolbar.inspect.portal.message'));
      const town = this.clientState.planet.town_for_id(this.building.townId);
      return template({ townName: town?.name ?? '' });
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'
@import '~/assets/stylesheets/starpeace-inspect'

.inspect-body
  color: $sp-primary
</style>
