<template lang='haml'>
#application-container{'v-bind:class':'application_css_class', 'v-cloak':true}
  %sp-header{'v-bind:options':'options', 'v-bind:ui_state':'ui_state'}
  %sp-loading-card{'v-bind:game_state':'game_state'}
  %sp-loading-modal{'v-bind:game_state':'game_state'}
  %sp-workflow{'v-bind:client':'client', 'v-bind:event_listener':'event_listener', 'v-bind:game_state':'game_state'}
  %menu-corporation-establish{'v-bind:client':'client', 'v-bind:translation_manager':'translation_manager', 'v-bind:game_state':'game_state'}
  %menu-construction{'v-show':"is_menu_visible('construction')", 'v-bind:menu_state':'menu_state'}
  %menu-chat{'v-show':"is_menu_visible('chat')", 'v-bind:menu_state':'menu_state'}
  %menu-bookmarks{'v-show':"is_menu_visible('bookmarks')", 'v-bind:bookmark_manager':'bookmark_manager', 'v-bind:game_state':'game_state', 'v-bind:menu_state':'menu_state', 'v-bind:options':'options'}
  %menu-mail{'v-show':"is_menu_visible('mail')", 'v-bind:menu_state':'menu_state'}
  %menu-options{'v-show':"is_menu_visible('options')", 'v-bind:menu_state':'menu_state', 'v-bind:options':'options', 'v-bind:ui_state':'ui_state'}
  %menu-help{'v-show':"is_menu_visible('help')", 'v-bind:menu_state':'menu_state'}
  %menu-release-notes{'v-show':"is_menu_visible('release_notes')", 'v-bind:menu_state':'menu_state'}
  %menu-research-menu{'v-show':"is_menu_visible('research')", 'v-bind:invention_manager':'invention_manager', 'v-bind:translation_manager':'translation_manager', 'v-bind:game_state':'game_state', 'v-bind:menu_state':'menu_state', 'v-bind:options':'options'}
  %menu-research-no-company{'v-show':"is_menu_visible('research')", 'v-bind:translation_manager':'translation_manager', 'v-bind:game_state':'game_state', 'v-bind:menu_state':'menu_state'}
  %menu-research-tree{'v-show':"is_menu_visible('research')", 'v-bind:invention_manager':'invention_manager', 'v-bind:translation_manager':'translation_manager', 'v-bind:game_state':'game_state', 'v-bind:menu_state':'menu_state', 'v-bind:options':'options'}
  %menu-research-details{'v-show':"is_menu_visible('research')", 'v-bind:invention_manager':'invention_manager', 'v-bind:translation_manager':'translation_manager', 'v-bind:game_state':'game_state', 'v-bind:menu_state':'menu_state', 'v-bind:options':'options'}
  %menu-system{'v-show':"is_menu_visible('systems')", 'v-bind:client':'client', 'v-bind:game_state':'game_state', 'v-bind:menu_state':'menu_state'}
  %menu-tycoon{'v-show':"is_menu_visible('tycoon')", 'v-bind:bookmark_manager':'bookmark_manager', 'v-bind:game_state':'game_state', 'v-bind:menu_state':'menu_state', 'v-bind:options':'options'}
  %sp-body{'v-bind:game_state':'game_state', 'v-bind:options':'options', 'v-bind:ui_state':'ui_state'}
  %sp-footer-overlay-menu{'v-bind:ui_state':'ui_state'}
  %sp-toolbar-ribbon{'v-bind:camera_manager':'camera_manager', 'v-bind:game_state':'game_state', 'v-bind:mini_map_renderer':'mini_map_renderer', 'v-bind:options':'options', 'v-bind:ui_state':'ui_state'}
  %sp-toolbar-details{'v-bind:camera_manager':'camera_manager', 'v-bind:game_state':'game_state', 'v-bind:menu_state':'menu_state', 'v-bind:mini_map_renderer':'mini_map_renderer', 'v-bind:options':'options', 'v-bind:ui_state':'ui_state', 'v-bind:music_manager':'music_manager'}
</template>

<script lang='coffee'>
import Header from '~/components/page-layout/header.vue'
import LoadingCard from '~/components/body/loading-card.vue'
import LoadingModal from '~/components/body/loading-modal.vue'
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

  watch:
    state_counter: (new_value, old_value) ->
      @show_header = @client?.options?.option('general.show_header')

  data: ->
    bookmark_manager: @client?.managers?.bookmark_manager
    camera_manager: @client?.camera_manager
    event_listener: @client?.event_listener
    invention_manager: @client?.managers?.invention_manager
    game_state: @client?.game_state
    menu_state: @client?.menu_state
    mini_map_renderer: @client?.mini_map_renderer
    music_manager: @client?.music_manager
    translation_manager: @client?.managers?.translation_manager
    options: @client?.options
    ui_state: @client?.ui_state

    show_header: @client?.options?.option('general.show_header')

  computed:
    state_counter: -> @options.vue_state_counter
    application_css_class: ->
      classes = []
      classes.push 'no-header' unless @show_header
      classes.push 'is-toolbar-left' if @menu_state.is_toolbar_left_open()
      classes.push 'is-toolbar-right' if @menu_state.is_toolbar_right_open()
      classes

  methods:
    is_menu_visible: (type) -> @game_state?.initialized && @menu_state?.is_visible(type)
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
