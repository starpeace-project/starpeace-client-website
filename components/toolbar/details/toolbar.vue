<template lang='pug'>
#toolbar-details.is-flex.is-flex-direction-row.is-relative(v-cloak=true :oncontextmenu="'return ' + !$config.public.disableRightClick")
  toolbar-details-news-ticker(:client-state='clientState')
  toolbar-details-corporation.is-flex-grow-1(:client-state='clientState')
</template>

<script lang='ts'>
import ClientState from '~/plugins/starpeace-client/state/client-state';

export default {
  props: {
    clientState: { type: ClientState, required: true }
  },
  computed: {
    isReady (): boolean {
      return this.clientState.initialized && this.clientState?.workflow_status === 'ready';
    }
  }
}
</script>

<style lang='sass' scoped>
#toolbar-details
  grid-column: start-left / end-right
  grid-row: start-toolbar / end-toolbar
  pointer-events: auto
</style>
