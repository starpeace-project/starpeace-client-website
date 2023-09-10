<template lang='pug'>
application-desktop(v-if='!isMobile')
application-mobile(v-else)
</template>

<script lang='ts'>
const MAX_SIZE_MOBILE: number = 769;
const MAX_SIZE_TABLET: number = 1024;

export default {
  computed: {
    screenWidth () { return window?.innerWidth ?? document?.documentElement?.clientWidth ?? document?.body?.clientWidth; },
    isMobile () { return this.screenWidth < MAX_SIZE_MOBILE; },
    isTablet () { return this.screenWidth >= MAX_SIZE_MOBILE && this.screenWidth < MAX_SIZE_TABLET; }
  },

  mounted () {
    if (this.$starpeaceClient) {
      this.animate();
    }
  },

  methods: {
    animate () {
      this.$starpeaceClient.tick();
      requestAnimationFrame(() => this.animate());
    }
  }
}
</script>
