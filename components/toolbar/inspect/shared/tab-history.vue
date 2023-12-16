<template lang='pug'>
.columns.is-marginless.history-tab
  .column.is-narrow.is-paddingless.p-4
    span.is-italic {{ $translate('toolbar.inspect.history.label.pending') }}

</template>

<script lang='ts'>
import _ from 'lodash';

import { BuildingDefinition, ResourceType, SimulationDefinition } from '@starpeace/starpeace-assets-types';

import ClientState from '~/plugins/starpeace-client/state/client-state';
import Building from '~/plugins/starpeace-client/building/building';

declare interface TabHistoryData {
}

export default {
  props: {
    clientState: { type: ClientState, required: true },

    building: { type: Building, required: true },
    definition: { type: BuildingDefinition, required: true },
    simulation: { type: SimulationDefinition, required: true },
  },

  data (): TabHistoryData {
    return {
    };
  },

  computed: {
  },

  methods: {
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'
@import '~/assets/stylesheets/starpeace-inspect'

.history-tab
  color: $sp-primary
</style>
