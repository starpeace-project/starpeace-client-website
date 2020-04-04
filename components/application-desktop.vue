<template lang='pug'>
client-only
  #application-container(:class='application_css_class', v-cloak=true)
    sp-header(:managers='managers', :client_state='client_state')

    sp-loading-card(:managers='managers', :client_state='client_state')
    sp-loading-modal(v-show='is_loading_modal_visible')

    sp-session-expired-warning-card(:managers='managers', :client_state='client_state')
    sp-webgl-warning-card(:managers='managers', :client_state='client_state')

    sp-workflow(:managers='managers', :ajax_state='ajax_state', :client_state='client_state')

    menu-corporation-establish(:managers='managers', :client_state='client_state')

    menu-construction(v-show="is_menu_visible('construction')", :managers='managers', :client_state='client_state')
    menu-chat(v-show="is_menu_visible('chat')", :managers='managers', :client_state='client_state')
    menu-bookmarks(v-show="is_menu_visible('bookmarks')", :managers='managers', :ajax_state='ajax_state', :client_state='client_state')
    menu-mail(v-show="is_menu_visible('mail')", :managers='managers', :client_state='client_state')
    menu-options(v-show="is_menu_visible('options')", :managers='managers', :client_state='client_state')
    menu-politics(v-show="is_menu_visible('politics')", :managers='managers', :client_state='client_state')
    menu-help(v-show="is_menu_visible('help')", :managers='managers', :client_state='client_state')
    menu-rankings(v-show="is_menu_visible('rankings')", :managers='managers', :client_state='client_state')
    menu-release-notes(v-show="is_menu_visible('release_notes')", :managers='managers', :client_state='client_state')
    menu-research-menu(v-show="is_menu_visible('research')", :managers='managers', :client_state='client_state')
    menu-research-no-company(v-show="is_menu_visible('research')", :managers='managers', :client_state='client_state')
    menu-research-tree(v-show="is_menu_visible('research')", :managers='managers', :client_state='client_state')
    menu-research-details(v-show="is_menu_visible('research')", :managers='managers', :ajax_state='ajax_state', :client_state='client_state')
    menu-galaxy(v-show="is_menu_visible('galaxy')", :managers='managers', :client_state='client_state', :ajax_state='ajax_state')
    menu-town-search(v-show="is_menu_visible('town_search')", :managers='managers', :client_state='client_state')
    menu-tycoon-details(v-show="is_menu_visible('tycoon')", :managers='managers', :client_state='client_state')
    menu-tycoon-search(v-show="is_menu_visible('tycoon_search')", :managers='managers', :client_state='client_state')

    sp-body(:client_state='client_state')

    sp-toolbar-overlay-menu(:managers='managers', :client_state='client_state')
    sp-toolbar-ribbon(:managers='managers', :mini_map_renderer='mini_map_renderer', :client_state='client_state')
    sp-toolbar-header(:managers='managers', :ajax_state='ajax_state', :client_state='client_state')
    sp-toolbar-details(:managers='managers', :ajax_state='ajax_state', :client_state='client_state')

    sp-loading-modal(v-show='is_sub_menu_visible')
    sp-sub-menu-remove-galaxy(v-show='is_sub_menu_remove_galaxy_visible', :managers='managers', :client_state='client_state')
    sp-sub-menu-add-galaxy(v-show='is_sub_menu_add_galaxy_visible', :managers='managers', :client_state='client_state')
</template>

<script lang='coffee'>
import Header from '~/components/page-layout/header.vue'
import RenderContainer from '~/components/page-layout/render-container.vue'

import LoadingCard from '~/components/misc/card-loading.vue'
import LoadingModal from '~/components/misc/modal-loading.vue'
import SessionExpiredWarningCard from '~/components/misc/card-session-expired-warning.vue'
import WebGLWarningCard from '~/components/misc/card-webgl-warning.vue'

import Workflow from '~/components/workflow/workflow.vue'
import SubMenuRemoveGalaxy from '~/components/workflow/sub-menu-remove-galaxy.vue'
import SubMenuAddGalaxy from '~/components/workflow/sub-menu-add-galaxy.vue'

import MenuCorporationEstablish from '~/components/menu/corporation/establish.vue'

import MenuConstruction from '~/components/menu/construction/main-menu.vue'
import MenuChat from '~/components/menu/menu-chat.vue'
import MenuBookmarks from '~/components/menu/bookmarks/main-menu.vue'
import MenuMail from '~/components/menu/menu-mail.vue'
import MenuOptions from '~/components/menu/options/main-menu.vue'
import MenuPolitics from '~/components/menu/politics/main-menu.vue'
import MenuHelp from '~/components/menu/menu-help.vue'
import MenuRankings from '~/components/menu/rankings/main-menu.vue'
import MenuReleaseNotes from '~/components/menu/menu-release-notes.vue'
import MenuResearchMenu from '~/components/menu/research/menu.vue'
import MenuResearchNoCompany from '~/components/menu/research/no-company.vue'
import MenuResearchTree from '~/components/menu/research/tree.vue'
import MenuResearchDetails from '~/components/menu/research/details.vue'
import MenuGalaxy from '~/components/menu/galaxy/menu.vue'
import MenuTownSearch from '~/components/menu/town-search/main-menu.vue'
import MenuTycoonDetails from '~/components/menu/tycoon-details/menu-tycoon.vue'
import MenuTycoonSearch from '~/components/menu/tycoon-search/main-menu.vue'

import ToolbarDetails from '~/components/toolbar/toolbar-details.vue'
import ToolbarHeader from '~/components/toolbar/toolbar-header.vue'
import ToolbarRibbon from '~/components/toolbar/toolbar-ribbon.vue'
import ToolbarOverlayMenu from '~/components/toolbar/overlay-menu.vue'

export default
  props:
    client: Object

  components:
    'sp-header': Header
    'sp-loading-card': LoadingCard
    'sp-loading-modal': LoadingModal
    'sp-workflow': Workflow
    'sp-body': RenderContainer
    'sp-toolbar-overlay-menu': ToolbarOverlayMenu
    'sp-toolbar-header': ToolbarHeader
    'sp-toolbar-details': ToolbarDetails
    'sp-toolbar-ribbon': ToolbarRibbon
    'sp-session-expired-warning-card': SessionExpiredWarningCard
    'sp-webgl-warning-card': WebGLWarningCard
    'sp-sub-menu-remove-galaxy': SubMenuRemoveGalaxy
    'sp-sub-menu-add-galaxy': SubMenuAddGalaxy
    'menu-corporation-establish': MenuCorporationEstablish
    'menu-construction': MenuConstruction
    'menu-chat': MenuChat
    'menu-bookmarks': MenuBookmarks
    'menu-mail': MenuMail
    'menu-options': MenuOptions
    'menu-politics': MenuPolitics
    'menu-help': MenuHelp
    'menu-rankings': MenuRankings
    'menu-release-notes': MenuReleaseNotes
    'menu-research-menu': MenuResearchMenu
    'menu-research-no-company': MenuResearchNoCompany
    'menu-research-tree': MenuResearchTree
    'menu-research-details': MenuResearchDetails
    'menu-galaxy': MenuGalaxy
    'menu-town-search': MenuTownSearch
    'menu-tycoon-details': MenuTycoonDetails
    'menu-tycoon-search': MenuTycoonSearch

  mounted: ->
    @client.options?.subscribe_options_listener =>
      @show_header = @client.options.option('general.show_header')

    @client.client_state?.menu?.subscribe_menu_listener =>
      @$forceUpdate()

  data: ->
    options: @client?.options
    client_state: @client?.client_state
    ajax_state: @client?.ajax_state

    show_loading_modal: false
    show_header: @client?.options?.option('general.show_header')

  computed:
    managers: -> @client?.managers
    mini_map_renderer: -> @client?.mini_map_renderer

    loading_visible: -> (@client_state?.initialized || false) && (@client_state?.loading || false)

    is_loading_modal_visible: -> @client_state?.initialized && @client_state?.loading

    is_sub_menu_visible: -> @is_sub_menu_remove_galaxy_visible || @is_sub_menu_add_galaxy_visible
    is_sub_menu_remove_galaxy_visible: -> @client_state?.interface?.show_remove_galaxy
    is_sub_menu_add_galaxy_visible: -> @client_state?.interface?.show_add_galaxy

    is_toolbar_left_open: -> @client_state?.menu?.toolbar_left?.length
    is_toolbar_right_open: -> @client_state?.menu?.toolbar_right?.length

    application_css_class: ->
      classes = []
      classes.push 'no-header' unless @show_header
      classes.push 'is-toolbar-left' if !@client_state.session_expired_warning && @is_toolbar_left_open
      classes.push 'is-toolbar-right' if !@client_state.session_expired_warning && @is_toolbar_right_open
      classes

  methods:
    is_menu_visible: (type) -> @client_state.initialized && !@client_state.session_expired_warning && @client_state?.workflow_status == 'ready' && @client_state?.menu?.is_visible(type)
</script>

<style lang='sass' scoped>
@import '~bulma/sass/utilities/_all'

#application-container
  display: grid
  grid-template-columns: 0 auto 0
  grid-template-rows: 4rem auto 3rem 5rem 3rem 7.5rem
  height: 100vh
  position: relative

  &.no-header
    grid-template-rows: 0 auto 3rem 5rem 3rem 7.5rem

  &.is-toolbar-left:not(.is-toolbar-right)
    grid-template-columns: 25rem auto 0rem

  &.is-toolbar-right:not(.is-toolbar-left)
    grid-template-columns: 0 auto 25rem

  &.is-toolbar-right.is-toolbar-left
    grid-template-columns: 25rem auto 25rem

</style>
