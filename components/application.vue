<template lang='pug'>
  sp-core-application(:client='client')
</template>

<script lang='coffee'>
MAX_SIZE_MOBILE = 769
MAX_SIZE_TABLET = 1024

import ApplicationDesktop from '~/components/application-desktop.vue'
import ApplicationMobile from '~/components/application-mobile.vue'
import Client from '~/plugins/starpeace-client/client.coffee'

client = null
screen_is_mobile = false

if process.browser
  window.starpeace_client = client = new Client()
  animate = () ->
    client.tick() if client?
    requestAnimationFrame(-> animate())

  screen_width = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth
  screen_is_mobile = screen_width < MAX_SIZE_MOBILE
  #screen_is_tablet = context.screen_width >= MAX_SIZE_MOBILE && context.screen_width < MAX_SIZE_TABLET
  #screen_is_desktop = context.screen_width >= MAX_SIZE_TABLET

export default
  created: ->
    animate() if animate?

  data: ->
    client: client

  components:
    'sp-core-application': if screen_is_mobile then ApplicationMobile else ApplicationDesktop
</script>
