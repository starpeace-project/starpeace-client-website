<template lang='pug'>
client-only
  #application-container(v-cloak=true :style='application_css_style' v-if='$starpeaceClient && client_state')
    page-layout-header(:client_state='client_state')

    misc-card-loading(:client_state='client_state' within-grid)
    misc-modal-loading(v-show='is_loading_modal_visible' within-grid)

    misc-card-server-connection-warning(:client_state='client_state')
    misc-card-session-expired-warning(:client_state='client_state')
    misc-card-webgl-warning(:client_state='client_state')

    workflow(:ajax_state='ajax_state' :client_state='client_state')

    menu-corporation-establish(v-if='is_corporation_establish_visible' :client_state='client_state')
    menu-company-form(v-show="is_menu_visible('company_form')" :client_state='client_state')

    menu-construction-main-menu(v-show="is_menu_visible('construction')" :client_state='client_state')
    menu-chat-main-menu(v-show="is_menu_visible('chat')" :client_state='client_state')
    menu-bookmarks-main-menu(v-show="is_menu_visible('bookmarks')" :ajax_state='ajax_state' :client_state='client_state')
    menu-mail-main-menu(v-show="is_menu_visible('mail')" :ajax_state='ajax_state' :client_state='client_state')
    menu-options-main-menu(v-show="is_menu_visible('options')" :client_state='client_state')
    menu-politics-main-menu(:visible="is_menu_visible('politics')" :client_state='client_state')
    menu-help(v-show="is_menu_visible('help')" :client_state='client_state')
    menu-rankings-main-menu(v-show="is_menu_visible('rankings')" :ajax_state='ajax_state' :client_state='client_state')
    menu-release-notes(v-show="is_menu_visible('release_notes')" :client_state='client_state')
    menu-research-main-menu(v-show="is_menu_visible('research')" :ajax_state='ajax_state' :client_state='client_state')
    menu-galaxy-menu(v-show="is_menu_visible('galaxy')" :ajax_state='ajax_state' :client_state='client_state')
    menu-town-search-main-menu(v-show="is_menu_visible('town_search')" :client_state='client_state')
    menu-tycoon-details-main-menu(v-show="is_menu_visible('tycoon')" :client_state='client_state')
    menu-tycoon-search-main-menu(v-show="is_menu_visible('tycoon_search')" :ajax_state='ajax_state' :client_state='client_state')

    page-layout-render-container(:client_state='client_state')

    misc-system-message-panel(:client-state='client_state')

    toolbar-overlay(:client_state='client_state')
    toolbar-minimap(:client_state='client_state')
    toolbar-ribbon(:client_state='client_state')
    toolbar-inspect(:ajax_state='ajax_state' :client_state='client_state')
    toolbar-menubar(:ajax_state='ajax_state' :client_state='client_state')
    toolbar-details(:ajax_state='ajax_state' :client_state='client_state')

    misc-modal-loading(v-show='is_sub_menu_visible' within-grid)
    workflow-sub-menu-remove-galaxy(v-show='is_sub_menu_remove_galaxy_visible' :client_state='client_state')
    workflow-sub-menu-add-galaxy(v-show='is_sub_menu_add_galaxy_visible' :client_state='client_state')
    workflow-sub-menu-create-tycoon(v-show='is_sub_menu_create_tycoon_visible' :client_state='client_state')
</template>

<script lang='ts'>
import Utils from '~/plugins/starpeace-client/utils/utils.coffee';

export default {
  data () {
    return {
      options: this.$starpeaceClient?.options,
      client_state: this.$starpeaceClient?.client_state,
      ajax_state: this.$starpeaceClient?.ajax_state,

      show_loading_modal: false,
      show_header: this.$starpeaceClient?.options?.option('general.show_header')
    };
  },

  mounted () {
    this.$starpeaceClient.options?.subscribe_options_listener(() => {
      this.show_header = this.$starpeaceClient.options.option('general.show_header');
    });

    this.$starpeaceClient.client_state?.menu?.subscribe_menu_listener(() => {
      this.$forceUpdate()
    });
  },

  computed: {
    is_ready () { return this.client_state.initialized && this.client_state?.workflow_status === 'ready'; },
    is_loading_modal_visible () { return this.client_state?.initialized && this.client_state?.loading; },

    is_corporation_establish_visible () { return this.client_state.initialized && this.client_state.workflow_status == 'ready' && this.client_state.is_tycoon() && !this.client_state.player.corporation_id?.length; },

    is_sub_menu_visible (): boolean { return this.is_sub_menu_remove_galaxy_visible || this.is_sub_menu_add_galaxy_visible || this.is_sub_menu_create_tycoon_visible; },
    is_sub_menu_remove_galaxy_visible (): boolean { return this.client_state.interface.remove_galaxy_visible; },
    is_sub_menu_add_galaxy_visible (): boolean { return this.client_state.interface.add_galaxy_visible; },
    is_sub_menu_create_tycoon_visible (): boolean { return this.client_state.interface.show_create_tycoon; },

    is_toolbar_left_open (): boolean { return !!this.client_state?.menu?.toolbars.left?.length; },
    is_toolbar_right_open (): boolean { return !!this.client_state?.menu?.toolbars.right?.length; },

    show_overlay (): boolean { return this.is_ready && this.client_state?.interface?.show_overlay; },
    show_inspect (): boolean { return this.is_ready && this.client_state?.interface?.show_inspect; },

    application_grid_columns_style (): string {
      return Utils.grid_style('grid-template-columns', [{
        start: 'start-left',
        size: this.is_toolbar_left_open ? '25rem' : '0',
        end: 'end-left'
      }, {
        start: 'start-render',
        size: 'auto',
        end: 'end-render'
      }, {
        start: 'start-right',
        size: this.is_toolbar_right_open ? '25rem' : '0',
        end: 'end-right'
      }]);
    },

    application_grid_rows_style (): string {
      return Utils.grid_style('grid-template-rows', [{
        start: 'start-header',
        size: this.show_header ? '4rem' : '0',
        end: 'end-header'
      }, {
        start: 'start-render',
        size: 'auto',
        end: 'end-render'
      }, {
        start: 'start-overlay',
        size: this.show_overlay ? '3rem' : '0',
        end: 'end-overlay'
      }, {
        start: 'start-ribbon',
        size: '5.5rem',
        end: 'end-ribbon'
      }, {
        start: 'start-inspect',
        size: this.show_inspect ? '16rem' : '0',
        end: 'end-inspect'
      }, {
        start: 'start-menu',
        size: '3rem',
        end: 'end-menu'
      }, {
        start: 'start-toolbar',
        size: '7.5rem',
        end: 'end-toolbar'
      }]);
    },

    application_css_style (): string { return `${this.application_grid_columns_style}; ${this.application_grid_rows_style}`; }
  },

  methods: {
    is_menu_visible (type: string): boolean {
      return this.client_state.initialized && !this.client_state.session_expired_warning && this.client_state?.workflow_status === 'ready' && this.client_state?.menu?.is_visible(type);
    }
  }
}
</script>

<style lang='sass' scoped>
@import 'bulma/sass/utilities/_all'

#application-container
  display: grid
  height: 100vh
  position: relative

</style>
