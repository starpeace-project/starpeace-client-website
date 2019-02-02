<template lang='pug'>
  sp-application(:client='client')
</template>

<script lang='coffee'>
MAX_SIZE_MOBILE = 769
MAX_SIZE_TABLET = 1024

import ApplicationDesktop from '~/components/application-desktop.vue'
import ApplicationMobile from '~/components/application-mobile.vue'

screen_is_mobile = false
if process.browser
  screen_width = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth
  screen_is_mobile = screen_width < MAX_SIZE_MOBILE
  #screen_is_tablet = context.screen_width >= MAX_SIZE_MOBILE && context.screen_width < MAX_SIZE_TABLET
  #screen_is_desktop = context.screen_width >= MAX_SIZE_TABLET

export default
  props:
    client: Object

  components:
    'sp-application': if screen_is_mobile then ApplicationMobile else ApplicationDesktop
</script>
