<template lang='haml'>
#application-container{'v-bind:class':'application_css_class', 'v-cloak':true}
  %sp-header{'v-bind:ui_state':'ui_state'}
  %sp-loading-card{'v-bind:game_state':'game_state'}
  %sp-loading-modal{'v-bind:game_state':'game_state'}
  %sp-workflow{'v-bind:event_listener':'event_listener', 'v-bind:game_state':'game_state', 'v-bind:planetary_metadata_manager':'planetary_metadata_manager'}
  %sp-body{'v-bind:game_state':'game_state', 'v-bind:ui_state':'ui_state'}
</template>

<script lang='coffee'>
import Header from '~/components/page-layout/header.vue'
import LoadingCard from '~/components/body/loading-card.vue'
import LoadingModal from '~/components/body/loading-modal.vue'
import Workflow from '~/components/workflow/workflow.vue'
import RenderContainer from '~/components/body/render-container.vue'
import FooterOverlayMenu from '~/components/footer/overlay-menu.vue'

export default
  props:
    client: Object

  components:
    'sp-header': Header
    'sp-loading-card': LoadingCard
    'sp-loading-modal': LoadingModal
    'sp-workflow': Workflow
    'sp-body': RenderContainer
    'sp-footer-overlay-menu': FooterOverlayMenu

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
@import '~bulma/sass/utilities/_all'

#application-container
  display: grid
  grid-template-columns: 0 auto 0
  grid-template-rows: 4rem auto 3rem 5rem 10.5rem
  grid-row-gap: 0
  height: 100vh
  position: relative

  +mobile
    grid-template-rows: calc(11vw + 1.5rem) auto 3rem 5rem 10.5rem

    #common-header
      display: inline-block
      width: 100%

  &.no-header
    +mobile
      grid-template-rows: calc(1rem) auto 3rem 5rem 10.5rem

</style>
