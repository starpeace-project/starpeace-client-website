<template lang='pug'>
.column-news-ticker.p-2.has-text-weight-bold
  span.is-clickable(v-if='tickerHasTarget' @click.stop.prevent='jumpTickerTarget') {{ tickerMessage }}
  span(v-else) {{ tickerMessage }}
</template>

<script lang='ts'>
import ClientState from '~/plugins/starpeace-client/state/client-state';

export default {
  props: {
    clientState: { type: ClientState, required: true }
  },

  computed: {
    tickerMessage (): string {
      return this.clientState?.interface?.eventTickerMessage ?? '';
    },
    tickerHasTarget (): boolean {
      return !!this.clientState?.interface?.eventTickerTarget;
    }
  },

  methods: {
    jumpTickerTarget (): void {
      if (this.clientState?.interface?.eventTickerTarget) {
        this.clientState.jump_to(this.clientState?.interface?.eventTickerTarget.mapX, this.clientState?.interface?.eventTickerTarget.mapY, this.clientState?.interface?.eventTickerTarget.buildingId);
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.column-news-ticker
  background-color: darken($sp-primary-bg, 10%)
  color: $sp-primary
  font-size: .85rem
  height: 100%
  width: 24rem

  .is-clickable
    &:hover
      text-decoration: underline

</style>
