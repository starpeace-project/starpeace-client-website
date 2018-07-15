<template lang='haml'>
%no-ssr
  #application-container{'v-bind:class':'application_css_class', 'v-cloak':true}
    %sp-header{'v-bind:ui_state':'ui_state'}
    %sp-loading-card{'v-bind:game_state':'game_state'}
    %sp-loading-modal{'v-bind:game_state':'game_state'}
    %sp-workflow{'v-bind:event_listener':'event_listener', 'v-bind:game_state':'game_state', 'v-bind:planetary_metadata_manager':'planetary_metadata_manager'}
    %sp-menu{'v-bind:game_state':'game_state', 'v-bind:menu_state':'menu_state', 'v-bind:ui_state':'ui_state'}
    %sp-body{'v-bind:game_state':'game_state', 'v-bind:ui_state':'ui_state'}
    %sp-footer-overlay-menu{'v-bind:ui_state':'ui_state'}
    %sp-footer{'v-bind:game_state':'game_state', 'v-bind:menu_state':'menu_state', 'v-bind:ui_state':'ui_state', 'v-bind:camera_manager':'camera_manager'}
</template>

<script lang='coffee'>
import Header from '~/components/header-panel.vue'
import LoadingCard from '~/components/loading-card.vue'
import LoadingModal from '~/components/loading-modal.vue'
import Workflow from '~/components/workflow/workflow.vue'
import Menus from '~/components/menu/menus.vue'
import RenderContainer from '~/components/render-container.vue'
import Footer from '~/components/footer/footer-container.vue'
import FooterOverlayMenu from '~/components/footer/overlay-menu.vue'
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
    'sp-header': Header
    'sp-loading-card': LoadingCard
    'sp-loading-modal': LoadingModal
    'sp-workflow': Workflow
    'sp-menu': Menus
    'sp-body': RenderContainer
    'sp-footer-overlay-menu': FooterOverlayMenu
    'sp-footer': Footer

  data: ->
    event_listener: client?.event_listener
    game_state: client?.game_state
    menu_state: client?.menu_state
    ui_state: client?.ui_state
    planetary_metadata_manager: client?.managers?.planetary_metadata_manager
    camera_manager: client?.camera_manager

  computed:
    application_css_class: ->
      classes = []
      classes.push('no-header') unless @ui_state?.show_header
      classes

</script>

<style lang='sass'>

</style>
