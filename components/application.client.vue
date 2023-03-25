<template lang='pug'>
application-desktop(v-if='!isMobile' :client='client')
application-mobile(v-else :client='client')
</template>

<script lang='ts'>
import { markRaw } from 'vue';
import Client from '~/plugins/starpeace-client/client.coffee'

const MAX_SIZE_MOBILE: number = 769;
const MAX_SIZE_TABLET: number = 1024;

export default {
  data () {
    return {
      client: markRaw(new Client(this.$config.public.disableRightClick ?? true))
    };
  },

  computed: {
    screenWidth () { return window?.innerWidth ?? document?.documentElement?.clientWidth ?? document?.body?.clientWidth; },
    isMobile () { return this.screenWidth < MAX_SIZE_MOBILE; },
    isTablet () { return this.screenWidth >= MAX_SIZE_MOBILE && this.screenWidth < MAX_SIZE_TABLET; }
  },

  mounted () {
    this.animate();
  },

  methods: {
    animate () {
      this.client.tick();
      requestAnimationFrame(() => this.animate());
    }
  }
}
</script>
