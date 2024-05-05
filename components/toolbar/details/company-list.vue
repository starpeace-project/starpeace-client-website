<template lang='pug'>
.company-container.is-flex.is-flex-direction-row
  .company-panel(v-for='company in sortedCompanyInfos' :class="{ 'is-selected': company.selected }" @click.stop.prevent='selectCompany(company.id)')
    .company-name-row
      span.company-icon-wrapper
        misc-company-seal-icon.company-seal(:seal_id='company.sealId')
      span.company-name {{ company.name }}

    .company-building-count
      font-awesome-icon(:icon="['far', 'building']")
      span.count {{ company.buildingCount }}

    p.company-cashflow(:class="{'is-negative': company.cashflow < 0}")
      | (
      misc-money-text(no_styling :value='company.cashflow')
      | /h)

  .company-panel.form-company(v-if='canFormCompany' :class="{'is-selected': isFormCompanyVisible, 'no-companies': !companies.length}" @click.stop.prevent='toggleFormCompany')
    .form-label {{ $translate('ui.menu.company.form.action.form') }}

</template>

<script lang='ts'>
import _ from 'lodash';
import type Company from '~/plugins/starpeace-client/company/company';
import ClientState from '~/plugins/starpeace-client/state/client-state';


const HEADQUARTERS_BUILDING_IDS = new Set([
  'dis.hq',
  'magna.research.a',
  'magna.research.b',
  'mko.hq',
  'moab.hq',
  'pgi.hq'
]);

interface CompanyInfo {
  id: string;
  selected: boolean;
  name: string;
  sealId: string;
  cashflow: number;
  buildingCount: number;
}

export default {
  props: {
    clientState: { type: ClientState, required: true }
  },

  computed: {
    isReady (): boolean {
      return this.clientState.initialized && this.clientState?.workflow_status === 'ready';
    },

    isTycoon (): boolean {
      return this.isReady && this.clientState?.is_tycoon();
    },
    companies (): Array<Company> {
      return (this.isReady && this.isTycoon ? (this.clientState.corporation.company_ids ?? []) : []).map((id) => this.clientState.core.company_cache.metadataForId(id)).filter(c => !!c) as Array<Company>;
    },
    sortedCompanies (): Array<Company> {
      return _.orderBy(this.companies, ['name'], ['asc']);
    },
    sortedCompanyInfos (): Array<CompanyInfo> {
      return this.sortedCompanies.map(c => {
        return {
          id: c.id,
          selected: this.clientState.player.company_id === c.id,
          name: this.clientState.name_for_company_id(c.id),
          sealId: this.clientState.seal_for_company_id(c.id),
          cashflow: this.clientState.corporation.cashflow_by_company_id[c.id] ?? 0,
          buildingCount: (this.clientState.corporation.buildings_ids_by_company_id?.[c.id] ?? []).length
        };
      });
    },

    canFormCompany () {
      return this.isTycoon && this.clientState.player.corporation_id?.length;
    },
    isFormCompanyVisible () {
      return this.clientState.initialized && !this.clientState.session_expired_warning && this.clientState?.workflow_status == 'ready' && this.clientState?.menu?.is_visible('company_form');
    }
  },

  methods: {
    selectCompany (companyId: string): void {
      if (this.clientState.player.company_id === companyId) {
        const buildingIds = this.clientState.corporation.building_ids_for_company(companyId);
        const headquarters = buildingIds.map(id => this.clientState.core.building_cache.building_for_id(id)).filter(b => b && HEADQUARTERS_BUILDING_IDS.has(b.definitionId));
        const sortedHeadquarters = _.orderBy(headquarters, ['constructionStartedAt'], ['asc']);

        if (sortedHeadquarters.length) {
          const index = this.clientState.interface.selected_building_id ? sortedHeadquarters.findIndex(b => b?.id === this.clientState.interface.selected_building_id) : -1;
          const nextBuilding = sortedHeadquarters[index < 0 ? 0 : (index + 1 >= sortedHeadquarters.length ? 0 : index + 1)];
          if (nextBuilding) {
            this.clientState.jump_to(nextBuilding.mapX, nextBuilding.mapY, nextBuilding.id);
          }
        }
      }
      else {
        this.clientState.player.set_company_id(companyId);
      }
    },
    toggleFormCompany (): void {
      if (this.canFormCompany) {
        this.clientState.menu.toggle_menu('company_form');
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.company-container
  align-items: stretch
  justify-content: left
  margin-bottom: .5rem
  padding: .5rem

  .company-panel
    border: 1px solid $sp-primary-bg
    cursor: pointer
    margin-left: .5rem
    min-width: 8em
    padding: .5rem

    &.form-company
      align-items: center
      border: 1px solid darken($sp-primary-bg, 5%)
      color: darken($sp-primary, 15%)
      display: flex
      flex-direction: column
      font-size: 1.1rem
      justify-content: center
      letter-spacing: .1rem
      text-align: center
      text-transform: uppercase
      width: 8rem

      &.no-companies
        border: 1px solid lighten($sp-primary-bg, 5%)
        color: $sp-primary

      &:hover
        background-color: darken($sp-primary, 25%)
        border: 1px solid darken($sp-primary, 15%)
        color: lighten($sp-primary, 5%)

      &.is-selected,
      &:active
        background-color: darken($sp-primary, 20%)
        border: 1px solid darken($sp-primary, 5%)
        color: lighten($sp-primary, 10%)

    &:hover
      background-color: darken($sp-primary, 30%)
      border: 1px solid darken($sp-primary, 15%)

    &.is-selected,
    &:active
      background-color: darken($sp-primary, 20%)
      border: 1px solid darken($sp-primary, 5%)

      .company-seal
        color: #ddd

      .company-name
        color: #ddd

      .company-building-count
        color: #ddd

      .company-cashflow
        color: #ddd

        &.is-negative
          color: $color-negative
          font-weight: bold


.company-icon-wrapper
  height: 1.2rem
  width: 1.2rem

.company-seal
  color: $sp-primary

.company-name
  color: $sp-primary
  margin-left: .5rem

.company-building-count
  color: $sp-primary
  font-size: 1rem
  line-height: 1.05rem
  margin-top: .25rem

  .count
    font-size: 1.3rem
    margin-left: .5rem
    vertical-align: bottom

.company-cashflow
  color: $sp-primary
  margin-top: .25rem

  &.is-negative
    color: $color-negative

</style>
