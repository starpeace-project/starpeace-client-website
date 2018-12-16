<template lang='haml'>
#application-container{'v-bind:class':'application_css_class', 'v-cloak':true}
  %sp-header{'v-bind:options':'options', 'v-bind:client_state':'client_state'}
  %sp-loading-card{'v-bind:client_state':'client_state'}
  %sp-loading-modal{'v-bind:client_state':'client_state'}
  %sp-webgl-warning-card{'v-bind:client_state':'client_state'}
  %sp-workflow{'v-bind:client':'client', 'v-bind:client_state':'client_state'}
  %menu-corporation-establish{'v-bind:client':'client', 'v-bind:managers':'managers', 'v-bind:client_state':'client_state'}
  %menu-construction{'v-show':"is_menu_visible('construction')", 'v-bind:client_state':'client_state'}
  %menu-chat{'v-show':"is_menu_visible('chat')", 'v-bind:client_state':'client_state'}
  %menu-bookmarks{'v-show':"is_menu_visible('bookmarks')", 'v-bind:managers':'managers', ':ajax_state':'ajax_state', 'v-bind:client_state':'client_state', 'v-bind:options':'options'}
  %menu-mail{'v-show':"is_menu_visible('mail')", 'v-bind:client_state':'client_state'}
  %menu-options{'v-show':"is_menu_visible('options')", 'v-bind:client_state':'client_state', 'v-bind:options':'options'}
  %menu-help{'v-show':"is_menu_visible('help')", 'v-bind:client_state':'client_state'}
  %menu-release-notes{'v-show':"is_menu_visible('release_notes')", 'v-bind:client_state':'client_state'}
  %menu-research-menu{'v-show':"is_menu_visible('research')", 'v-bind:client_state':'client_state', 'v-bind:options':'options'}
  %menu-research-no-company{'v-show':"is_menu_visible('research')", 'v-bind:client_state':'client_state'}
  %menu-research-tree{'v-show':"is_menu_visible('research')", 'v-bind:managers':'managers', 'v-bind:client_state':'client_state', 'v-bind:options':'options'}
  %menu-research-details{'v-show':"is_menu_visible('research')", 'v-bind:managers':'managers', 'v-bind:client_state':'client_state', 'v-bind:options':'options'}
  %menu-system{'v-show':"is_menu_visible('systems')", 'v-bind:client_state':'client_state', 'v-bind:ajax_state':'ajax_state', 'v-bind:managers':'managers'}
  %menu-tycoon{'v-show':"is_menu_visible('tycoon')", 'v-bind:managers':'managers', 'v-bind:client_state':'client_state', 'v-bind:options':'options'}
  %sp-body{'v-bind:client_state':'client_state', 'v-bind:options':'options'}
  %sp-footer-overlay-menu{'v-bind:client_state':'client_state'}
  %sp-toolbar-ribbon{'v-bind:managers':'managers', 'v-bind:mini_map_renderer':'mini_map_renderer', 'v-bind:client_state':'client_state', 'v-bind:options':'options'}
  %sp-toolbar-details{'v-bind:managers':'managers', 'v-bind:client_state':'client_state', 'v-bind:options':'options'}
</template>

<script lang='coffee'>
import Header from '~/components/page-layout/header.vue'
import LoadingCard from '~/components/misc/card-loading.vue'
import LoadingModal from '~/components/misc/modal-loading.vue'
import WebGLWarningCard from '~/components/misc/card-webgl-warning.vue'
import Workflow from '~/components/workflow/workflow.vue'

import MenuCorporationEstablish from '~/components/menu/corporation/establish.vue'

import MenuConstruction from '~/components/menu/menu-construction.vue'
import MenuChat from '~/components/menu/menu-chat.vue'
import MenuBookmarks from '~/components/menu/bookmarks/main-menu.vue'
import MenuMail from '~/components/menu/menu-mail.vue'
import MenuOptions from '~/components/menu/menu-options.vue'
import MenuHelp from '~/components/menu/menu-help.vue'
import MenuReleaseNotes from '~/components/menu/menu-release-notes.vue'
import MenuResearchMenu from '~/components/menu/research/menu.vue'
import MenuResearchNoCompany from '~/components/menu/research/no-company.vue'
import MenuResearchTree from '~/components/menu/research/tree.vue'
import MenuResearchDetails from '~/components/menu/research/details.vue'
import MenuSystem from '~/components/menu/system/menu.vue'
import MenuTycoon from '~/components/menu/menu-tycoon.vue'

import RenderContainer from '~/components/body/render-container.vue'
import ToolbarDetails from '~/components/footer/toolbar-details.vue'
import ToolbarRibbon from '~/components/footer/toolbar-ribbon.vue'
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
    'sp-toolbar-details': ToolbarDetails
    'sp-toolbar-ribbon': ToolbarRibbon
    'sp-webgl-warning-card': WebGLWarningCard
    'menu-corporation-establish': MenuCorporationEstablish
    'menu-construction': MenuConstruction
    'menu-chat': MenuChat
    'menu-bookmarks': MenuBookmarks
    'menu-mail': MenuMail
    'menu-options': MenuOptions
    'menu-system': MenuSystem
    'menu-help': MenuHelp
    'menu-release-notes': MenuReleaseNotes
    'menu-research-menu': MenuResearchMenu
    'menu-research-no-company': MenuResearchNoCompany
    'menu-research-tree': MenuResearchTree
    'menu-research-details': MenuResearchDetails
    'menu-tycoon': MenuTycoon

  mounted: ->
    @client.options?.subscribe_options_listener =>
      @show_header = @client.options.option('general.show_header')

    @client.client_state?.menu?.subscribe_menu_listener =>
      @$forceUpdate()

  data: ->
    options: @client?.options
    client_state: @client?.client_state
    ajax_state: @client?.ajax_state

    show_header: @client?.options?.option('general.show_header')

  computed:
    managers: -> @client?.managers
    mini_map_renderer: -> @client?.mini_map_renderer

    webgl_warning_visible: -> (@client_state?.initialized || false) && (@client_state?.webgl_warning || false)
    loading_visible: -> (@client_state?.initialized || false) && (@client_state?.loading || false)

    is_toolbar_left_open: -> @client_state?.menu?.toolbar_left?.length
    is_toolbar_right_open: -> @client_state?.menu?.toolbar_right?.length

    application_css_class: ->
      classes = []
      classes.push 'no-header' unless @show_header
      classes.push 'is-toolbar-left' if @is_toolbar_left_open
      classes.push 'is-toolbar-right' if @is_toolbar_right_open
      classes

  methods:
    is_menu_visible: (type) -> @client_state.initialized && @client_state?.workflow_status == 'ready' && @client_state?.menu?.is_visible(type)
</script>

<style lang='sass' scoped>
@import '~bulma/sass/utilities/_all'

#application-container
  display: grid
  grid-template-columns: 0 auto 0
  grid-template-rows: 4rem auto 3rem 5rem 10.5rem
  height: 100vh
  position: relative

  &.no-header
    grid-template-rows: 0 auto 3rem 5rem 10.5rem

  &.is-toolbar-left:not(.is-toolbar-right)
    grid-template-columns: 25rem auto 0rem

  &.is-toolbar-right:not(.is-toolbar-left)
    grid-template-columns: 0 auto 25rem

  &.is-toolbar-right.is-toolbar-left
    grid-template-columns: 25rem auto 25rem

</style>
