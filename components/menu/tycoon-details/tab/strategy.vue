<template lang='pug'>
.sp-tab
  template(v-if='loadingStrategies')
    .sp-loading.is-flex.is-align-items-center.is-justify-content-center
      img.starpeace-logo

  template(v-else)
    .strategy-tab
      .sp-scrollbar
        table.basic-table.sp-striped.sp-solid-header.sp-sticky-header.strategy
          thead
            tr
              th.sp-kv-key {{$translate('ui.menu.tycoon_details.tab.strategy.tycoon_name')}}
              th.sp-kv-key {{$translate('ui.menu.tycoon_details.tab.strategy.corporation_name')}}
              th.has-text-centered.sp-kv-key.column-policy {{$translate('ui.menu.tycoon_details.tab.strategy.their_policy')}}
              th.has-text-centered.sp-kv-key.column-policy {{$translate('ui.menu.tycoon_details.tab.strategy.your_policy')}}
              th.column-action

          tbody
            template(v-for='strategy in sorted_strategies.prioritize')
              tr
                td {{strategy.otherTycoonName}}
                td.is-size-5 {{strategy.otherCorporationName}}
                td.has-text-centered {{$translate(text_key_for_strategy_policy(strategy.otherPolicy))}}
                td.has-text-centered {{$translate(text_key_for_strategy_policy(strategy.policy))}}
                td.column-action
                  .is-flex.is-justify-content-center(v-if='has_corporation && is_self')
                    template(v-if='strategy.isPrioritize')
                      button.button.is-uppercase.is-small.is-starpeace(disabled) {{$translate('misc.action.cancel')}}
                    template(v-else)
                      button.button.is-uppercase.is-small.is-starpeace(disabled) {{$translate('ui.menu.tycoon_details.tab.action.prioritize')}}

          tfoot(v-if='has_corporation && is_self')
            tr
              td.has-text-centered.py-4(colspan=5)
                .field.has-addons.is-justify-content-center
                  .control
                    .tabs.is-centered.is-small.is-toggle.sp-tabs
                      ul
                        li(:class="{'is-active': allyMode == 'CORPORATION'}" @click.stop.prevent="swap_ally_mode('CORPORATION')")
                          a {{$translate('ui.menu.tycoon_search.toggle.corporation')}}
                        li(:class="{'is-active': allyMode == 'TYCOON'}" @click.stop.prevent="swap_ally_mode('TYCOON')")
                          a {{$translate('ui.menu.tycoon_search.toggle.tycoon')}}
                  .control
                    input.input.is-small(type='text' v-model='allyValue' disabled)
                  .control
                    button.button.is-uppercase.is-small.is-starpeace(@click.stop.prevent='make_ally' disabled) {{$translate('ui.menu.tycoon_details.tab.action.prioritize')}}

      .sp-scrollbar
        table.basic-table.sp-striped.sp-solid-header.sp-sticky-header.strategy
          thead
            tr
              th.sp-kv-key {{$translate('ui.menu.tycoon_details.tab.strategy.tycoon_name')}}
              th.sp-kv-key {{$translate('ui.menu.tycoon_details.tab.strategy.corporation_name')}}
              th.has-text-centered.sp-kv-key.column-policy {{$translate('ui.menu.tycoon_details.tab.strategy.their_policy')}}
              th.has-text-centered.sp-kv-key.column-policy {{$translate('ui.menu.tycoon_details.tab.strategy.your_policy')}}
              th.column-action

          tbody
            template(v-for='strategy in sorted_strategies.embargo')
              tr
                td {{strategy.otherTycoonName}}
                td.is-size-5 {{strategy.otherCorporationName}}
                td.has-text-centered {{$translate(text_key_for_strategy_policy(strategy.otherPolicy))}}
                td.has-text-centered {{$translate(text_key_for_strategy_policy(strategy.policy))}}
                td.column-action
                  .is-flex.is-justify-content-center(v-if='has_corporation && is_self')
                    template(v-if='strategy.isEmbargo')
                      button.button.is-uppercase.is-small.is-starpeace(disabled) {{$translate('misc.action.cancel')}}
                    template(v-else)
                      button.button.is-uppercase.is-small.is-starpeace(disabled) {{$translate('ui.menu.tycoon_details.tab.action.embargo')}}

          tfoot(v-if='has_corporation && is_self')
            tr
              td.has-text-centered.py-4(colspan=5)
                .field.has-addons.is-justify-content-center
                  .control
                    .tabs.is-centered.is-small.is-toggle.sp-tabs
                      ul
                        li(:class="{'is-active': embargoMode == 'CORPORATION'}" @click.stop.prevent="swap_embargo_mode('CORPORATION')")
                          a {{$translate('ui.menu.tycoon_search.toggle.corporation')}}
                        li(:class="{'is-active': embargoMode == 'TYCOON'}" @click.stop.prevent="swap_embargo_mode('TYCOON')")
                          a {{$translate('ui.menu.tycoon_search.toggle.tycoon')}}
                  .control
                    input.input.is-small(type='text' v-model='embargoValue' disabled)
                  .control
                    button.button.is-uppercase.is-small.is-starpeace(@click.stop.prevent='make_embargo' disabled) {{$translate('ui.menu.tycoon_details.tab.action.embargo')}}

</template>

<script lang='ts'>
import _ from 'lodash';
import ClientState from '~/plugins/starpeace-client/state/client-state';

declare interface StrategyData {
  loadingStrategies: boolean;
  allyMode: string;
  allyValue: string;
  embargoMode: string;
  embargoValue: string;
  strategies: Array<any>;
}

export default {
  props: {
    clientState: { type: ClientState, required: true },
    tycoonId: String,
    corporationId: String
  },

  data (): StrategyData {
    return {
      loadingStrategies: false,

      allyMode: 'TYCOON',
      allyValue: '',
      embargoMode: 'TYCOON',
      embargoValue: '',

      strategies: []
    };
  },

  computed: {
    has_corporation (): boolean { return (this.corporationId?.length ?? 0) > 0; },
    is_self (): boolean { return this.clientState.player.tycoon_id === this.tycoonId; },

    tycoon (): any | null { return this.tycoonId?.length ? this.clientState.core.tycoon_cache.metadata_for_id(this.tycoonId) : null; },
    corporation (): any | null { return this.has_corporation ? this.clientState.core.corporation_cache.metadata_for_id(this.corporationId) : null; },

    sorted_strategies () {
      const prioritize: Array<any> = [];
      const embargo: Array<any> = [];

      for (const strategy of this.strategies) {
        if (strategy.isPrioritize || (!strategy.isEmbargo && strategy.isOtherPrioritize)) {
          prioritize.push(strategy);
        }
        else {
          embargo.push(strategy);
        }
      }

      return { prioritize: _.orderBy(prioritize, ['otherTycoonName'], ['asc']), embargo: _.orderBy(embargo, ['otherTycoonName'], ['asc']) };
    }
  },

  mounted () {
    this.refresh_details();
  },

  watch: {
    tycoonId (newValue, oldValue) {
      if (newValue !== oldValue) {
        if (oldValue) this.reset_state();
        this.refresh_details();
      }
    },
    corporationId (newValue, oldValue) {
      if (newValue !== oldValue) {
        if (oldValue) this.reset_state();
        this.refresh_details();
      }
    }
  },

  methods: {
    text_key_for_strategy_policy (policy: string) {
      if (policy === 'PRIORITIZE') {
        return 'ui.menu.tycoon_details.tab.status.prioritize';
      }
      else if (policy === 'EMBARGO') {
        return 'ui.menu.tycoon_details.tab.status.embargo';
      }
      else {
        return 'ui.menu.tycoon_details.tab.status.neutral';
      }
    },

    reset_state () {
      this.allyMode = 'TYCOON';
      this.allyValue = '';
      this.embargoMode = 'TYCOON';
      this.embargoValue = '';
      this.strategies = [];
    },

    async refresh_details () {
      if (this.loadingStrategies || !this.has_corporation) return;
      try {
        this.loadingStrategies = true;
        this.strategies = await this.$starpeaceClient.managers.corporation_manager.load_strategies_by_corporation(this.corporationId);
      }
      catch (err) {
        this.clientState.add_error_message('Failure loading tycoon details from server', err);
        this.strategies = [];
      }
      finally {
        this.loadingStrategies = false;
      }
    },


    swap_ally_mode (mode: string) {
      if (this.allyMode !== mode) {
        this.allyMode = mode;
        this.allyValue = '';
      }
    },

    make_ally () {
      console.log('make_ally', this.allyValue);
    },

    swap_embargo_mode (mode: string) {
      if (this.embargoMode !== mode) {
        this.embargoMode = mode;
        this.embargoValue = '';
      }
    },

    make_embargo () {
      console.log('make_embargo', this.embargoValue);
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-menus'
@import '~/assets/stylesheets/starpeace-menus-tycoon-details'

.strategy-tab
  display: grid
  grid-template-columns: 50% 50%
  height: 100%

  .sp-scrollbar
    overflow-y: scroll


.basic-table
  td
    &.column-action
      .is-flex
        column-gap: 1rem

  &.strategy
    th
      &.column-policy
        width: 12rem

      &.column-action
        width: 10rem

</style>
