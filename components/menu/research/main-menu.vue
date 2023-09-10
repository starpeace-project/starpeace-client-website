<template lang='pug'>
.card.has-header.is-starpeace.sp-menu(:oncontextmenu="'return ' + !$config.public.disableRightClick")
  .card-header
    .card-header-title {{$translate('ui.menu.research.header')}}
    .card-header-icon.card-close(v-on:click.stop.prevent="client_state.menu.toggle_menu('research')")
      font-awesome-icon(:icon="['fas', 'times']")

  .card-content.sp-menu-background.is-paddingless
    menu-research-sections(:is-visible='is_visible' :client_state='client_state')
    menu-research-tree(:is-visible='is_visible' :client_state='client_state')
    menu-research-details(:ajax_state='ajax_state' :client_state='client_state')

  .sp-menu-modal(v-show='has_no_company')
    .content
      span {{$translate('ui.menu.construction.company_required.label')}}
      a(@click.stop.prevent='toggle_form_company_menu') {{$translate('ui.menu.construction.company_required.action')}}

</template>

<script lang='ts'>
import ClientState from '~/plugins/starpeace-client/state/client-state.coffee';

export default {
  props: {
    ajax_state: Object,
    client_state: { type: ClientState, required: true }
  },

  data () {
    return {
      menuVisible: this.client_state?.menu?.is_visible('research') ?? false
    };
  },

  mounted () {
    this.client_state?.menu?.subscribe_menu_listener(() => {
      this.menuVisible = this.client_state?.menu?.is_visible('research') ?? false;
    });
  },

  computed: {
    is_visible (): boolean { return this.client_state.workflow_status === 'ready' && this.menuVisible; },

    has_no_company () {
      return this.client_state?.workflow_status === 'ready' && this.client_state.is_tycoon() && !this.client_state.player.company_id?.length;
    }
  },

  methods: {
    toggle_form_company_menu () {
      this.client_state.menu.toggle_menu('company_form');
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'
@import '~/assets/stylesheets/starpeace-menus'

.sp-menu
  grid-column: start-left / end-right
  grid-row: start-render / end-inspect

  > .card-content
    grid-template-columns: 25rem auto 25rem

</style>
