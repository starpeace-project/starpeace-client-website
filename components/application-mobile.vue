<template lang='haml'>
#application-container{'v-bind:class':'application_css_class', 'v-cloak':true}
  %sp-header{'v-bind:ui_state':'ui_state'}
  %sp-loading-card{'v-bind:game_state':'game_state'}
  %sp-loading-modal{'v-bind:game_state':'game_state'}
  %sp-workflow{'v-bind:event_listener':'event_listener', 'v-bind:game_state':'game_state', 'v-bind:planetary_metadata_manager':'planetary_metadata_manager'}
  %sp-menu{'v-bind:game_state':'game_state', 'v-bind:menu_state':'menu_state', 'v-bind:ui_state':'ui_state'}
  %sp-body{'v-bind:game_state':'game_state', 'v-bind:ui_state':'ui_state'}
</template>

<script lang='coffee'>
import Header from '~/components/header/header-panel.vue'
import LoadingCard from '~/components/body/loading-card.vue'
import LoadingModal from '~/components/body/loading-modal.vue'
import Workflow from '~/components/workflow/workflow.vue'
import Menus from '~/components/menu/menus.vue'
import RenderContainer from '~/components/body/render-container.vue'
import Footer from '~/components/footer/footer-container.vue'
import FooterOverlayMenu from '~/components/footer/overlay-menu.vue'

export default
  props:
    client: Object

  components:
    'sp-header': Header
    'sp-loading-card': LoadingCard
    'sp-loading-modal': LoadingModal
    'sp-workflow': Workflow
    'sp-menu': Menus
    'sp-body': RenderContainer
    'sp-footer-overlay-menu': FooterOverlayMenu
    'sp-footer': Footer

  watch:
    state_counter: (new_value, old_value) ->
      @show_header = @client?.options?.option('general.show_header')

  computed:
    state_counter: -> @options.vue_state_counter
    application_css_class: -> if @show_header then [] else ['no-header']

  data: ->
    event_listener: @client?.event_listener
    game_state: @client?.game_state
    menu_state: @client?.menu_state
    options: @client?.options
    ui_state: @client?.ui_state
    planetary_metadata_manager: @client?.managers?.planetary_metadata_manager
    camera_manager: @client?.camera_manager

    show_header: @client?.options?.option('general.show_header')
</script>

<style lang='sass' scoped>
#render-parent-container
  grid-column-start: 1
  grid-column-end: 4
  grid-row-start: 2
  grid-row-end: 4
  position: relative

.no-header
  #render-parent-container
    grid-row-start: 1

#fps-container
  left: .5rem
  position: absolute
  top: .5rem
  z-index: 1015

#render-container
  height: 100%
  left: 0
  position: absolute
  top: 0
  width: 100%
  z-index: 1000

</style>
