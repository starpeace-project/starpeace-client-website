<template lang='pug'>
div
  .information
    .sp-profile.profile-column
      .profile-container
        .profile-image
          .profile-none
          .profile-mask

    .details-column
      .detail-row(v-if='!hideTycoon && tycoon')
        span.detail-label {{ $translate('ui.menu.corporation.panel.details.tycoon') }}:
        span.detail-value {{ tycoon.tycoonName }}
      .detail-row(v-if='!hideCorporation && corporation')
        span.detail-label {{ $translate('ui.menu.corporation.panel.details.corporation') }}:
        span.detail-value {{ corporation.name }}
      .detail-row
        span.detail-label {{ $translate('ui.menu.corporation.panel.details.fortune') }}:
        span.detail-value
          misc-money-text(:value='cash' no_styling)
      .detail-row
        span.detail-label {{ $translate('ui.menu.corporation.panel.details.fortune_ytd') }}:
        span.detail-value
          misc-money-text(:value='cashYearToDate' no_styling)
      .detail-row
        span.detail-label {{ $translate('ui.menu.corporation.panel.details.ranking') }}:
        span.detail-value 0
      .detail-row(v-if='level')
        span.detail-label {{ $translate('misc.corporation.level') }}:
        span.detail-value {{ $translate(level.label) }}
      .detail-row
        span.detail-label {{ $translate('misc.corporation.prestige') }}:
        span.detail-value 0

  .corporation-actions.level.is-mobile
    .level-item.action-column
      button.button.is-fullwidth.is-small.is-starpeace(@click.stop.prevent='show_profile') {{$translate('ui.menu.corporation.panel.action.show_profile')}}
    .level-item.action-column
      button.button.is-fullwidth.is-small.is-starpeace(:disabled='!canSend' @click.stop.prevent='send_mail') {{$translate('ui.menu.corporation.panel.action.send_mail')}}

  menu-shared-tree-menu-item(
    visible
    :client-state='clientState'
    :item='item'
    :level='1'
  )

</template>

<script lang='ts'>
import _ from 'lodash';

import { Level } from '@starpeace/starpeace-assets-types';

import Corporation from '~/plugins/starpeace-client/corporation/corporation';
import { type PlanetSearchResult } from '~/plugins/starpeace-client/planet/planets-manager';
import ClientState from '~/plugins/starpeace-client/state/client-state';

export default {
  props: {
    clientState: { type: ClientState, required: true },

    hideTycoon: Boolean,
    hideCorporation: Boolean,

    tycoon: { type: Object, required: true },
    corporation: { type: Corporation, required: false }
  },

  data () {
    return {
      item: this.companies_item()
    };
  },

  computed: {
    ready (): boolean {
      return this.clientState.workflow_status === 'ready';
    },
    canSend (): boolean {
      return this.ready && this.clientState.is_tycoon() && (this.clientState.player.corporation_id?.length ?? 0) > 0;
    },

    tycoonResult (): PlanetSearchResult {
      return this.tycoon as PlanetSearchResult;
    },

    cash (): number | undefined {
      return this.corporation?.cash;
    },
    cashYearToDate (): number | undefined {
      return 0;
    },
    level (): Level | undefined {
      return this.corporation?.levelId ? this.clientState?.core?.planet_library?.level_for_id(this.corporation?.levelId) : undefined;
    }
  },

  watch: {
    corporation () {
      this.item = this.companies_item();
    }
  },

  methods: {
    companies_item () {
      return {
        id: 'companies',
        type: 'FOLDER',
        primary: true,
        labelKey: 'ui.menu.corporation.panel.action.companies',
        children: !this.corporation ? [] : _.map(this.corporation.companies, (company) => {
          return {
            id: company.id,
            label: company.name,
            type: 'COMPANY',
            seal_id: company.seal_id,
            load_children_callback: () => this.$starpeaceClient.managers.building_manager.load_by_company(company.id),
            convert_children_callback: (buildings) => this.$starpeaceClient.managers.utils.tree_menu.organize_buildings(company.id, buildings)
          };
        })
      };
    },

    show_profile () {
      if (this.tycoon?.tycoonId) {
        this.clientState.show_tycoon_profile(this.tycoon.tycoonId);
      }
    },

    send_mail (): void {
      if (!this.canSend) return;
      if (this.tycoon?.tycoonId && this.corporation?.id) {
        this.clientState.send_mail(this.tycoon.tycoonName);
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.information
  display: grid
  grid-template-columns: 30% auto
  grid-template-rows: auto

  .profile-column
    padding: .5rem
    padding-right: .25rem

  .details-column
    padding: .5rem
    padding-left: .25rem

    .detail-label
      color: darken($sp-primary, 5%)
      font-size: .7rem
      letter-spacing: 0.05rem
      text-transform: uppercase

    .detail-value
      color: #ddd
      font-size: 1.1rem
      margin-left: .5rem

.corporation-actions
  padding: 0 .5rem .5rem .5rem
  margin: 0
  text-transform: uppercase
  letter-spacing: .05rem

</style>
