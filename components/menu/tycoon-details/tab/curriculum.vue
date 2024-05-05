<template lang='pug'>
.sp-tab
  template(v-if='loadingDetails')
    .sp-loading.is-flex.is-align-items-center.is-justify-content-center
      img.starpeace-logo

  .resume-tab(v-else)
    .is-flex.is-flex-direction-column.pr-2
      .resume-section.overview-section.is-flex.is-justify-content-space-between
        div
          div
            span.sp-kv-key {{$translate('ui.menu.corporation.panel.details.corporation')}}:
            span.sp-kv-value
              template(v-if='corporation')
                | {{corporation.name}}
              template(v-else)
                | {{$translate('ui.misc.none')}}
          div
            span.sp-kv-key {{$translate('ui.menu.corporation.panel.details.fortune')}}:
            span.sp-kv-value
              misc-money-text(:value='corporation_cash' no_styling)
          div
            span.sp-kv-key {{$translate('ui.menu.corporation.panel.details.fortune_ytd')}}:
            span.sp-kv-value
              misc-money-text(:value='corporation_current_year_cash' no_styling)
          div
            span.sp-kv-key {{$translate('ui.menu.corporation.panel.details.fortune_ytd_average')}}:
            span.sp-kv-value
              misc-money-text(:value='corporation_current_year_hours > 0 ? (corporation_current_year_cash / corporation_current_year_hours) : 0' no_styling)
              | /h
          div
            span.sp-kv-key {{$translate('misc.corporation.prestige')}}:
            span.sp-kv-value {{corporation_prestige}}

        div.is-flex.is-flex-direction-column.is-justify-content-space-around(v-if='has_corporation && is_self')
          button.button.is-starpeace.is-uppercase(disabled) {{$translate('ui.menu.tycoon_details.tab.curriculum.action.bankruptcy')}}
          button.button.is-starpeace.is-uppercase(disabled) {{$translate('ui.menu.tycoon_details.tab.curriculum.action.promotion')}}

      .resume-section.promotion-section
        .is-flex.is-flex-direction-column.level-current
          div
            span.sp-kv-key {{$translate('misc.corporation.level')}}:
            span.sp-kv-value {{current_level_label}}

          div
            span {{current_level_description}}

        .is-flex.is-flex-direction-column.level-next
          div
            span.sp-kv-key {{$translate('misc.corporation.level.next')}}:
            span.sp-kv-value {{next_level_label}}

          div
            span {{next_level_description}}
          div
            span.has-text-weight-bold {{next_level_requirements}}

    .sp-scrollbar
      table.basic-table.sp-striped.sp-solid-header.sp-sticky-header.rankings
        thead
          tr
            th.sp-kv-key {{$translate('ui.menu.tycoon_details.tab.curriculum.ranking')}}
            th.has-text-right.sp-kv-key.column-rank {{$translate('ui.menu.tycoon_details.tab.curriculum.rank')}}

        tbody
          template(v-if='!rankings.length')
            tr
              td.has-text-centered(colspan=2) {{$translate('ui.misc.none')}}

          template(v-else)
            tr(v-for='rank in sortedRankings')
              td
                span(v-for='label,index in rank.labels' :class="{'ml-1': index > 0}") {{$translate(label)}}
              td.has-text-right
                span(v-if='!(rank.rank >= 1)') -
                span(v-else) {{rank.rank}}

    .sp-scrollbar
      table.basic-table.sp-striped.sp-solid-header.sp-sticky-header.prestige-history
        thead
          tr
            th.sp-kv-key {{$translate('misc.unit.year.singular')}}
            th.sp-kv-key {{$translate('ui.menu.tycoon_details.tab.curriculum.history')}}
            th.has-text-right.sp-kv-key.column-prestige {{$translate('misc.corporation.prestige')}}

        tbody
          template(v-if='!prestigeHistory.length')
            tr
              td.has-text-centered(colspan=3) {{$translate('ui.misc.none')}}

          template(v-else)
            tr(v-for='history in sortedPrestigeHistory')
              td {{history.createdAt.year}}
              td {{history.label}}
              td.has-text-right
                span(v-if='history.prestige > 0') +
                span(v-else) -
                span {{history.prestige}}

</template>

<script lang='ts'>
import _ from 'lodash';
import ClientState from '~/plugins/starpeace-client/state/client-state';
import Utils from '~/plugins/starpeace-client/utils/utils.js'

export default {
  props: {
    clientState: { type: ClientState, required: true },
    tycoonId: String,
    corporationId: String
  },

  data () {
    return {
      loadingDetails: false,

      rankings: [],
      prestigeHistory: []
    };
  },

  computed: {
    has_corporation (): boolean { return (this.corporationId?.length ?? 0) > 0; },
    is_self (): boolean { return this.clientState.player.tycoon_id === this.tycoonId; },

    corporation (): any | null { return this.has_corporation ? this.clientState.core.corporation_cache.metadata_for_id(this.corporationId) : null; },

    corporation_cash (): number { return this.corporation?.cash ?? 0; },
    corporation_current_year_cash (): number { return 0; },
    corporation_current_year_hours (): number {
      if (!this.corporation?.cashAsOf) return 0;
      return this.corporation.cashAsOf.diff(this.corporation.cashAsOf.startOf('year'), 'hours').toObject().hours ?? 0;
    },
    corporation_prestige (): number { return this.corporation?.prestige ?? 0; },

    current_level (): any | null { return this.corporation?.levelId ? this.clientState.core.planet_library.level_for_id(this.corporation.levelId) : null; },
    next_level (): any | null { return this.corporation?.levelId ? this.clientState.core.planet_library.next_level_for_id(this.corporation.levelId) : null; },

    current_level_label (): string { return this.current_level ? this.$translate(this.current_level.label) : ''; },
    current_level_description (): string { return this.description_for_label(this.current_level); },
    next_level_label (): string { return this.next_level ? this.$translate(this.next_level.label) : ''; },
    next_level_description (): string { return this.next_level ? this.description_for_label(this.next_level) : ''; },
    next_level_requirements (): string {
      if (!this.next_level) return '';
      const parts = [];
      if (this.next_level.requiredFee > 0) {
        parts.push(`${_.template(this.$translate('ui.menu.tycoon_details.tab.curriculum.levels.requirement.fee'))({ fee: Utils.format_money(this.next_level.requiredFee) })}.`);
      }
      if (this.next_level.requiredHourlyProfit > 0) {
        parts.push(`${_.template(this.$translate('ui.menu.tycoon_details.tab.curriculum.levels.requirement.profit'))({ profit: Utils.format_money(this.next_level.requiredHourlyProfit) })}.`);
      }
      if (this.next_level.requiredPrestige > 0) {
        parts.push(`${_.template(this.$translate('ui.menu.tycoon_details.tab.curriculum.levels.requirement.prestige'))({ prestige: this.next_level.requiredPrestige })}.`);
      }
      return parts.join(' ');
    },

    sortedRankings (): Array<any> {
      return _.compact(_.map(this.rankings, (r: any) => {
        const ranking_type = this.clientState?.core?.planet_library?.ranking_type_for_id(r.rankingTypeId);
        const parent_ranking_type = ranking_type.parent_id ? this.clientState?.core?.planet_library?.ranking_type_for_id(ranking_type.parent_id) : null;
        if (!ranking_type || ranking_type.type === 'FOLDER') return null;
        return {
          rankingTypeId: r.rankingTypeId,
          labels: this.labels_for_ranking_type(ranking_type, parent_ranking_type),
          rank: r.rank
        };
      }));
    },
    sortedPrestigeHistory (): Array<any> { return _.orderBy(this.prestigeHistory, ['createdAt', 'label'], ['desc', 'asc']); }
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
    description_for_label (level: any) {
      if (!level) return '';

      const parts = [];
      if (level.rewardPrestige > 0) {
        parts.push(`${_.template(this.$translate('ui.menu.tycoon_details.tab.curriculum.levels.reward.prestige'))({ prestige: level.rewardPrestige })}.`);
      }

      parts.push(this.$translate(level.description));

      if (level.supplierIfel || level.refundResearch > 0 || level.refundDemolition > 0) {
        parts.push(`${this.$translate('ui.menu.tycoon_details.tab.curriculum.levels.protection.ifel')},`);
      }
      else {
        parts.push(`${this.$translate('ui.menu.tycoon_details.tab.curriculum.levels.protection.none')},`);
      }

      if (level.supplierPriority) {
        parts.push(`${this.$translate('ui.menu.tycoon_details.tab.curriculum.levels.priority.supplier')}.`);
      }
      else {
        parts.push(`${this.$translate('ui.menu.tycoon_details.tab.curriculum.levels.priority.none')}.`);
      }

      if (level.supplierIfel) {
        parts.push(`${this.$translate('ui.menu.tycoon_details.tab.curriculum.levels.trade_center.ifel')}.`);
      }
      else {
        parts.push(`${this.$translate('ui.menu.tycoon_details.tab.curriculum.levels.trade_center.none')}.`);
      }

      parts.push(`${_.template(this.$translate('ui.menu.tycoon_details.tab.curriculum.levels.facility.count'))({ count: level.facilityLimit })}.`);

      if (level.refundDemolition > 0) {
        parts.push(`${_.template(this.$translate('ui.menu.tycoon_details.tab.curriculum.levels.refund.demolition'))({ refund: (100 * level.refundDemolition).toFixed(0) })}.`);
      }

      if (level.refundResearch > 0) {
        parts.push(`${_.template(this.$translate('ui.menu.tycoon_details.tab.curriculum.levels.refund.research'))({ refund: (100 * level.refundResearch).toFixed(0) })}.`);
      }

      return parts.join(' ');
    },

    labels_for_ranking_type (type: any, parentType: any): Array<string> {
      if (type.category_total) {
        if (parentType) return [...this.labels_for_ranking_type(parentType, null), 'ui.menu.rankings.label.total'];
        return ['ui.menu.rankings.label.total'];
      }
      if (type.label) return [type.label];
      if (type.industryTypeId) return [this.clientState.core.planet_library.type_for_id(type.industryTypeId)?.label];
      if (type.industryCategoryId) return [this.clientState.core.planet_library.category_for_id(type.industryCategoryId)?.label];
      return [type.id];
    },

    reset_state () {
      this.rankings = [];
      this.prestigeHistory = [];
    },

    async refresh_details () {
      if (this.loadingDetails || !this.has_corporation) return;
      try {
        this.loadingDetails = true;
        const promiseResults = await Promise.all([
          this.$starpeaceClient.managers.corporation_manager.load_rankings_by_corporation(this.corporationId),
          this.$starpeaceClient.managers.corporation_manager.load_prestige_history_by_corporation(this.corporationId)
        ]);
        this.rankings = promiseResults[0] ?? [];
        this.prestigeHistory = promiseResults[1] ?? [];
      }
      catch (err) {
        this.clientState.add_error_message('Failure loading tycoon details from server', err);
        this.rankings = [];
        this.prestigeHistory = [];
      }
      finally {
        this.loadingDetails = false;
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-menus'
@import '~/assets/stylesheets/starpeace-menus-tycoon-details'


.tycoon-tabs
  .resume-tab
    display: grid
    grid-template-columns: auto max(15vw, 20rem) 30vw
    height: 100%

    > .is-flex
      row-gap: 1rem

    .sp-scrollbar
      overflow-y: scroll

    .resume-section,
    .overview-section
      border: 1px solid $sp-dark-bg
      padding: 1rem

    .promotion-section
      display: grid
      grid-template-columns: 50% 50%

      .level-current,
      .level-next
        row-gap: 1rem

      .level-current
        padding-right: 2rem

      .level-next
        border-left: 1px solid $sp-light-bg
        padding-left: 2rem

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


.basic-table
  td
    &.column-action
      .is-flex
        column-gap: 1rem

  &.rankings
    th
      &.column-rank
        width: 10rem

  &.prestige-history
    th
      &.column-prestige
        width: 10rem

</style>
