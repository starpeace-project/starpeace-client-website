<template lang='pug'>
client-only
  #application-container(v-cloak=true :style='application_css_style')
    page-layout-header(:managers='managers' :client_state='client_state')

    misc-card-loading(:managers='managers' :client_state='client_state' within-grid=true)
    misc-modal-loading(v-show='is_loading_modal_visible' within-grid=true)

    misc-card-server-connection-warning(:managers='managers' :client_state='client_state')
    misc-card-session-expired-warning(:managers='managers' :client_state='client_state')
    misc-card-webgl-warning(:managers='managers' :client_state='client_state')

    workflow(:managers='managers' :ajax_state='ajax_state' :client_state='client_state')

    menu-corporation-establish(v-if='is_corporation_establish_visible' :managers='managers', :client_state='client_state')
    menu-company-form(v-show="is_menu_visible('company_form')" :managers='managers' :client_state='client_state')

    menu-construction-main-menu(v-show="is_menu_visible('construction')" :managers='managers' :client_state='client_state')
    menu-chat-main-menu(v-show="is_menu_visible('chat')" :managers='managers' :client_state='client_state')
    menu-bookmarks-main-menu(v-show="is_menu_visible('bookmarks')" :managers='managers' :ajax_state='ajax_state' :client_state='client_state')
    menu-mail-main-menu(v-show="is_menu_visible('mail')" :managers='managers' :ajax_state='ajax_state' :client_state='client_state')
    menu-options-main-menu(v-show="is_menu_visible('options')" :managers='managers' :client_state='client_state')
    menu-politics-main-menu(:visible="is_menu_visible('politics')" :managers='managers' :client_state='client_state')
    menu-help(v-show="is_menu_visible('help')" :managers='managers' :client_state='client_state')
    menu-rankings-main-menu(v-show="is_menu_visible('rankings')" :managers='managers' :ajax_state='ajax_state' :client_state='client_state')
    menu-release-notes(v-show="is_menu_visible('release_notes')" :managers='managers' :client_state='client_state')
    menu-research-main-menu(v-show="is_menu_visible('research')" :managers='managers' :ajax_state='ajax_state' :client_state='client_state')
    menu-galaxy-menu(v-show="is_menu_visible('galaxy')" :managers='managers' :ajax_state='ajax_state' :client_state='client_state')
    menu-town-search-main-menu(v-show="is_menu_visible('town_search')" :managers='managers' :client_state='client_state')
    menu-tycoon-details-main-menu(v-show="is_menu_visible('tycoon')" :managers='managers' :client_state='client_state')
    menu-tycoon-search-main-menu(v-show="is_menu_visible('tycoon_search')" :managers='managers' :ajax_state='ajax_state' :client_state='client_state')

    page-layout-render-container(:client_state='client_state')

    misc-system-message-panel(:managers='managers' :client-state='client_state')

    toolbar-overlay(:managers='managers' :client_state='client_state')
    toolbar-minimap(:client_state='client_state')
    toolbar-ribbon(:managers='managers' :client_state='client_state')
    toolbar-inspect(:managers='managers' :ajax_state='ajax_state' :client_state='client_state')
    toolbar-menubar(:managers='managers' :ajax_state='ajax_state' :client_state='client_state')
    toolbar-details(:managers='managers' :ajax_state='ajax_state' :client_state='client_state')

    misc-modal-loading(v-show='is_sub_menu_visible')
    workflow-sub-menu-remove-galaxy(v-show='is_sub_menu_remove_galaxy_visible' :managers='managers' :client_state='client_state')
    workflow-sub-menu-add-galaxy(v-show='is_sub_menu_add_galaxy_visible' :managers='managers' :client_state='client_state')
    workflow-sub-menu-create-tycoon(v-show='is_sub_menu_create_tycoon_visible' :managers='managers' :client_state='client_state')
</template>

<script lang='coffee'>
import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

export default
  props:
    client: Object

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

    is_ready: -> @client_state.initialized && @client_state?.workflow_status == 'ready'
    loading_visible: -> (@client_state?.initialized || false) && (@client_state?.loading || false)
    is_loading_modal_visible: -> @client_state?.initialized && @client_state?.loading

    is_corporation_establish_visible: -> @client_state.initialized && @client_state.workflow_status == 'ready' && @client_state.is_tycoon() && !@client_state.player.corporation_id?.length

    is_sub_menu_visible: -> @is_sub_menu_remove_galaxy_visible || @is_sub_menu_add_galaxy_visible || @is_sub_menu_create_tycoon_visible
    is_sub_menu_remove_galaxy_visible: -> @client_state?.interface?.show_remove_galaxy
    is_sub_menu_add_galaxy_visible: -> @client_state?.interface?.show_add_galaxy
    is_sub_menu_create_tycoon_visible: -> @client_state?.interface?.show_create_tycoon

    is_toolbar_left_open: -> @client_state?.menu?.toolbars.left?.length
    is_toolbar_right_open: -> @client_state?.menu?.toolbars.right?.length

    show_overlay: -> @is_ready && @client_state?.interface?.show_overlay
    show_inspect: -> @is_ready && @client_state?.interface?.show_inspect

    application_grid_columns_style: ->
      Utils.grid_style('grid-template-columns', [{
        start: 'start-left'
        size: if @is_toolbar_left_open then '25rem' else '0'
        end: 'end-left'
      }, {
        start: 'start-render'
        size: 'auto'
        end: 'end-render'
      }, {
        start: 'start-right'
        size: if @is_toolbar_right_open then '25rem' else '0'
        end: 'end-right'
      }])

    application_grid_rows_style: ->
      Utils.grid_style('grid-template-rows', [{
        start: 'start-header'
        size: if @show_header then '4rem' else '0'
        end: 'end-header'
      }, {
        start: 'start-render'
        size: 'auto'
        end: 'end-render'
      }, {
        start: 'start-overlay'
        size: if @show_overlay then '3rem' else '0'
        end: 'end-overlay'
      }, {
        start: 'start-ribbon'
        size: '5.5rem'
        end: 'end-ribbon'
      }, {
        start: 'start-inspect'
        size: if @show_inspect then '16rem' else '0'
        end: 'end-inspect'
      }, {
        start: 'start-menu'
        size: '3rem'
        end: 'end-menu'
      }, {
        start: 'start-toolbar'
        size: '7.5rem'
        end: 'end-toolbar'
      }])

    application_css_style: -> "#{@application_grid_columns_style}; #{@application_grid_rows_style}"

  methods:
    is_menu_visible: (type) -> @client_state.initialized && !@client_state.session_expired_warning && @client_state?.workflow_status == 'ready' && @client_state?.menu?.is_visible(type)
</script>

<style lang='sass' scoped>
@import 'bulma/sass/utilities/_all'

#application-container
  display: grid
  height: 100vh
  position: relative

</style>
