<template lang='pug'>
.inspect-details
  .inspect-tabs.tabs.is-small.is-marginless
    ul
      template(v-for='tab in tabs')
        li(:class="{ 'is-active': tab.id == tabId }" @click.stop.prevent='tabId = tab.id')
          a
            span {{ $translate(tab.label) }}

  .inspect-body.is-marginless
    template(v-if="tabId == 'general'")
      .column.is-paddingless.is-relative.is-clipped.p-4
        span.is-italic {{ message }}


</template>

<script lang='ts'>
import _ from 'lodash';

import ClientState from '~/plugins/starpeace-client/state/client-state';
import Building from '~/plugins/starpeace-client/building/building';

export default {
  props: {
    clientState: { type: ClientState, required: true },

    building: { type: Building, required: true }
  },

  data () {
    return {
      tabId: 'general'
    };
  },

  computed: {
    tabs () {
      return [{
        id: 'general',
        label: 'toolbar.inspect.common.tabs.general'
      }];
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
