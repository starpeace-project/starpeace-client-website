<template lang='haml'>
#application-container{'v-bind:class':'application_css_class', 'v-cloak':true}
  %sp-header{'v-bind:client_state':'client_state'}
  %sp-loading-card{'v-bind:client_state':'client_state'}
  %sp-loading-modal{'v-bind:client_state':'client_state'}
  %sp-webgl-warning-modal{'v-bind:client_state':'client_state'}
  %sp-workflow{'v-bind:client':'client', 'v-bind:client_state':'client_state'}
  %sp-body{'v-bind:client_state':'client_state'}
</template>

<script lang='coffee'>
import Header from '~/components/page-layout/header.vue'
import LoadingCard from '~/components/misc/card-loading.vue'
import LoadingModal from '~/components/misc/modal-loading.vue'
import WebGLWarningCard from '~/components/misc/card-webgl-warning.vue'
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
    'sp-webgl-warning-card': WebGLWarningCard
    'sp-workflow': Workflow
    'sp-body': RenderContainer
    'sp-footer-overlay-menu': FooterOverlayMenu

  mounted: ->
    @client.options?.subscribe_options_listener =>
      @show_header = @client.options.option('general.show_header')

  data: ->
    client_state: @client?.client_state
    options: @client?.options

    show_header: @client?.options?.option('general.show_header')

  computed:
    application_css_class: -> if @show_header then [] else ['no-header']
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
