<template lang='haml'>
%no-ssr
  %sp-application{'v-bind:client':'client'}
</template>

<script lang='coffee'>
import Application from '~/components/application.vue'
import Client from '~/plugins/starpeace-client/client.coffee'

client = null
if process.browser
  window.starpeace_client = client = new Client()
  animate = () ->
    client.tick() if client?
    requestAnimationFrame(-> animate())

export default
  layout: 'application'
  created: ->
    animate() if animate?

  components:
    'sp-application': Application

  data: ->
    client: client
</script>
