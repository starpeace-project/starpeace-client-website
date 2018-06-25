<template lang='haml'>
#application{'v-bind:class':'application_css_class', 'v-cloak':true}
  %sp-header{'v-bind:client':'client'}
  %sp-loading-card{'v-bind:client':'client'}
  %sp-loading-modal{'v-bind:client':'client'}
  %sp-workflow{'v-bind:client':'client'}
  %sp-menu{'v-bind:client':'client'}
  %sp-body{'v-bind:client':'client'}
  %sp-footer{'v-bind:client':'client'}
</template>

<script lang='coffee'>
import Header from '~/components/header-panel.vue'
import LoadingCard from '~/components/loading-card.vue'
import LoadingModal from '~/components/loading-modal.vue'
import Workflow from '~/components/workflow/workflow.vue'
import Menus from '~/components/menu/menus.vue'
import RenderContainer from '~/components/render-container.vue'
import Footer from '~/components/footer/footer-container.vue'
import Client from '~/plugins/starpeace-client/client.coffee'

client = null
if process.browser
  window.starpeace_client = client = new Client()
  animate = () ->
    client.tick() if client?
    requestAnimationFrame(-> animate())

export default
  created: ->
    animate() if animate?

  components:
    'sp-header': Header
    'sp-loading-card': LoadingCard
    'sp-loading-modal': LoadingModal
    'sp-workflow': Workflow
    'sp-menu': Menus
    'sp-body': RenderContainer
    'sp-footer': Footer

  data: ->
    client: client

  computed:
    ui_state: -> @client?.ui_state
    application_css_class: -> [@ui_state?.theme, {'no-header':(if @ui_state?.show_header? then !@ui_state?.show_header else false)}]

</script>

<style lang='sass'>
#application
  display: grid
  grid-template-columns: .5rem auto .5rem
  grid-template-rows: 4rem auto 2rem 15.5rem
  height: 100vh

</style>
