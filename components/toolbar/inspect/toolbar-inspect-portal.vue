<template lang='pug'>
.inspect-details
  .inspect-tabs.tabs.is-small.is-marginless
    ul
      template(v-for='tab,index in tabs')
        li(:class="{ 'is-active': index == tab_index }" @click.stop.prevent='tab_index = index')
          a
            span {{tab}}

  .inspect-body.is-marginless


</template>

<script lang='ts'>
import ClientState from '~/plugins/starpeace-client/state/client-state.coffee';

export default {
  props: {
    clientState: { type: ClientState, required: true }
  },

  data () {
    return {
      tab_index: 0
    };
  },

  computed: {
    is_ready (): boolean { return this.clientState?.initialized && this.clientState?.workflow_status === 'ready'; },

    show_inspect () { return this.clientState?.interface?.selected_building_id && this.clientState?.interface?.show_inspect; },

    tabs () { return ['General']; }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'
@import '~/assets/stylesheets/starpeace-inspect'

</style>
