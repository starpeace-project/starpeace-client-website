<template lang='pug'>
.card.has-header.is-starpeace.sp-menu
  .card-header
    .card-header-title {{$translate('ui.menu.tycoon_details.header')}}
    .card-header-icon.card-close(@click.stop.prevent="client_state.menu.toggle_menu('tycoon')")
      font-awesome-icon(:icon="['fas', 'times']")

  .card-content.sp-menu-background.overall-container
    .tycoon-menu-panel
      template(v-if='tycoon && !loadingTycoon')
        .tycoon-name
          span.tycoon-icon
            font-awesome-icon(:icon="['fas', 'user-tie']")
          span.tycoon-label {{tycoon.name}}

        .sp-profile.profile-logo
          .profile-container
            .profile-image
              .profile-none
              .profile-mask

        .tabs.is-centered.is-small.is-toggle.sp-tabs.mode-toggle
          ul
            li(:class="{'is-active':mode=='CURRICULUM'}" @click.stop.prevent="mode='CURRICULUM'")
              a {{$translate('ui.menu.tycoon_details.tab.curriculum')}}
            li(:class="{'is-active':mode=='BANK_ACCOUNT'}" @click.stop.prevent="mode='BANK_ACCOUNT'" v-show='is_self')
              a {{$translate('ui.menu.tycoon_details.tab.bank_account')}}
            li(:class="{'is-active':mode=='PROFIT_LOSS'}" @click.stop.prevent="mode='PROFIT_LOSS'")
              a {{$translate('ui.menu.tycoon_details.tab.profit_loss')}}
            li(:class="{'is-active':mode=='INITIAL_SUPPLIERS'}" @click.stop.prevent="mode='INITIAL_SUPPLIERS'" v-show='is_self')
              a {{$translate('ui.menu.tycoon_details.tab.initial_suppliers')}}
            li(:class="{'is-active':mode=='COMPANIES'}" @click.stop.prevent="mode='COMPANIES'")
              a {{$translate('ui.menu.tycoon_details.tab.companies')}}
            li(:class="{'is-active':mode=='STRATEGY'}" @click.stop.prevent="mode='STRATEGY'" v-show='is_self')
              a {{$translate('ui.menu.tycoon_details.tab.strategy')}}

    .tycoon-tabs(v-if='has_tycoon')
      template(v-if='!tycoon || loadingTycoon')
        .sp-loading.is-flex.is-align-items-center.is-justify-content-center
          img.starpeace-logo

      template(v-else-if="mode=='CURRICULUM'")
        menu-tycoon-details-tab-curriculum(:client-state='client_state' :tycoon-id='tycoon_id' :corporation-id='corporation_id')

      template(v-else-if="mode=='BANK_ACCOUNT'")
        menu-tycoon-details-tab-bank-account(:client-state='client_state' :tycoon-id='tycoon_id' :corporation-id='corporation_id')

      template(v-else-if="mode=='PROFIT_LOSS'")

      template(v-else-if="mode=='INITIAL_SUPPLIERS'")
        menu-tycoon-details-tab-initial-suppliers(:client-state='client_state' :tycoon-id='tycoon_id' :corporation-id='corporation_id')

      template(v-else-if="mode=='COMPANIES'")
        menu-tycoon-details-tab-companies(:client-state='client_state' :tycoon-id='tycoon_id' :corporation-id='corporation_id')

      template(v-else-if="mode=='STRATEGY'")
        menu-tycoon-details-tab-strategy(:client-state='client_state' :tycoon-id='tycoon_id' :corporation-id='corporation_id')

</template>

<script lang='ts'>
import _ from 'lodash';
import ClientState from '~/plugins/starpeace-client/state/client-state';

export default {
  props: {
    client_state: { type: ClientState, required: true }
  },

  data () {
    return {
      mode: 'CURRICULUM',
      loading: false,
      loadingTycoon: false,
      loadingSuppliers: false,
      loadingStrategies: false,

      suppliersByResourceTypeId: {},
      selectedSupplierResourceTypeId: null,

      corporation_id: null,

      allyMode: 'TYCOON',
      allyValue: '',
      embargoMode: 'TYCOON',
      embargoValue: '',

      strategies: [],

      details_promise: null,
      details: null
    };
  },

  computed: {
    is_ready (): boolean { return this.client_state.initialized && this.client_state.workflow_status === 'ready'; },
    is_visible (): boolean { return this.is_ready && (this.client_state?.menu?.is_visible('tycoon') ?? false); },

    planet_id (): string | null { return this.is_visible ? this.client_state.player.planet_id : null; },
    tycoon_id (): string | null { return this.is_visible ? this.client_state.interface.selected_tycoon_id : null; },

    has_tycoon (): boolean { return (this.tycoon_id?.length ?? 0) > 0; },
    is_self (): boolean { return this.client_state.player.tycoon_id === this.tycoon_id; },

    tycoon (): any | null { return this.is_visible && this.has_tycoon ? this.client_state.core.tycoon_cache.metadata_for_id(this.tycoon_id) : null; }
  },

  watch: {
    tycoon_id (newValue, oldValue) {
      if (newValue !== oldValue) {
        if (oldValue) this.reset_state();
        this.refresh_details();
      }
    },
    corporation_id (newValue, oldValue) {
      if (newValue !== oldValue) {
        if (oldValue) this.reset_state();
        this.refresh_details();
      }
    },
    is_visible (newValue, oldValue) {
      if (newValue !== oldValue) {
        if (!this.is_visible) this.reset_state();
        this.refresh_details();
      }
    },
    mode (newValue, oldValue) {
      if (newValue !== oldValue) {
        this.refresh_details();
      }
    }
  },

  methods: {
    reset_state () {
      this.mode = 'CURRICULUM';
    },

    async refresh_details () {
      if (!this.is_visible) return;
      if (!this.tycoon_id?.length) return;

      try {
        this.loadingTycoon = true;
        await this.$starpeaceClient.managers.tycoon_manager.load_metadata_by_tycoon_id(this.tycoon_id);

        const identifiers = await this.$starpeaceClient.managers.corporation_manager.load_identifiers_by_tycoon(this.tycoon_id);
        const corporation_id = identifiers.find((i) => i.planetId === this.planet_id)?.id;

        if (corporation_id) {
          await this.$starpeaceClient.managers.corporation_manager.load_by_corporation(corporation_id);
        }
        this.corporation_id = corporation_id;
      }
      catch (err) {
        this.client_state.add_error_message('Failure loading tycoon details from server', err);
      }
      finally {
        this.loadingTycoon = false;
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-menus'
@import '~/assets/stylesheets/starpeace-menus-tycoon-details'

.sp-menu
  grid-column: start-left / end-render
  grid-row: start-render / end-inspect

  > .card-content
    grid-template-columns: 15rem auto


.tycoon-menu-panel
  grid-column: 1 / 2
  grid-row: 1 / 2

.tycoon-tabs
  grid-column: 2 / 3
  grid-row: 1 / 2
  padding: .5rem 0 0 .5rem
  position: relative

.tycoon-name
  color: $sp-primary
  font-size: 1.25rem
  font-weight: bold
  padding: 1rem .5rem .5rem
  text-align: center

  .tycoon-label
    color: #fff
    margin-left: .5rem

.profile-logo
  padding: .5rem 2.5rem

.mode-toggle
  position: relative
  padding: .5rem

  ul
    flex-direction: column

  li
    width: 100%

  a
    border-radius: 0 !important
    letter-spacing: .1rem
    padding: .5rem
    text-transform: uppercase

</style>
