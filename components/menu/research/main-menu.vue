<template lang='pug'>
.card.has-header.is-starpeace.sp-menu(:oncontextmenu="'return ' + !$config.public.disableRightClick")
  .card-header
    .card-header-title {{ $translate('ui.menu.research.header') }}
    .card-header-icon.card-close(@click.stop.prevent="clientState.menu.toggle_menu('research')")
      font-awesome-icon(:icon="['fas', 'times']")

  .card-content.sp-menu-background.is-paddingless(v-if='menuVisible')
    menu-research-sections(:invention-definitions='inventionDefinitions' :client-state='clientState')
    menu-research-tree(:connected-invention-definitions='connectedInventionDefinitions' :company-inventions='companyInventions' :client-state='clientState')
    menu-research-details(
      :corporation='corporation'
      :company='company'
      :company-inventions='companyInventions'
      :client-state='clientState'
    )

  .sp-menu-modal(v-if='!companyId')
    .content
      span {{ $translate('ui.menu.construction.company_required.label') }}
      a(@click.stop.prevent='toggleFormCompany') {{ $translate('ui.menu.construction.company_required.action') }}

</template>

<script lang='ts'>
import { InventionDefinition } from '@starpeace/starpeace-assets-types';
import Company from '~/plugins/starpeace-client/company/company';
import Corporation from '~/plugins/starpeace-client/corporation/corporation';
import CompanyInventions from '~/plugins/starpeace-client/invention/company-inventions';

import ClientState from '~/plugins/starpeace-client/state/client-state';

interface MenuResearchMainMenuData {
  menuVisible: boolean;

  corporation: Corporation | undefined;
  company: Company | undefined;
  companyInventions: CompanyInventions | undefined;

  corporationPromise: Promise<Corporation> | undefined;
  companyPromise: Promise<Company> | undefined;
  inventionsPromise: Promise<CompanyInventions> | undefined;
}

export default {
  props: {
    clientState: { type: ClientState, required: true }
  },

  data (): MenuResearchMainMenuData {
    return {
      menuVisible: this.clientState?.menu?.is_visible('research') ?? false,

      corporation: undefined,
      company: undefined,
      companyInventions: undefined,

      corporationPromise: undefined,
      companyPromise: undefined,
      inventionsPromise: undefined
    };
  },

  mounted () {
    this.clientState?.menu?.subscribe_menu_listener(() => {
      this.menuVisible = this.clientState?.menu?.is_visible('research') ?? false;
    });
    this.clientState.corporation.subscribe_company_inventions_listener(() => this.refreshInventions());
  },

  computed: {
    isVisible (): boolean {
      return this.clientState.workflow_status === 'ready' && this.menuVisible;
    },

    corporationId (): string | undefined {
      return this.clientState.player?.corporation_id ?? undefined;
    },
    companyId (): string | undefined {
      return this.clientState.player.company_id ?? undefined;
    },

    selectedCategoryId (): string | undefined {
      return this.clientState.interface.inventions_selected_category_id ?? undefined;
    },
    selectedIndustryTypeId (): string | undefined {
      return this.clientState.interface.inventions_selected_industry_type_id ?? undefined;
    },

    inventionDefinitions (): Array<InventionDefinition> {
      if (this.companyId && this.company?.id === this.companyId) {
        return this.clientState.core.invention_library.metadata_for_seal_id(this.company.sealId) ?? [];
      }
      else {
        return this.clientState.core.invention_library.all_metadata() ?? [];
      }
    },
    connectedInventionDefinitions (): Array<InventionDefinition> {
      const inventionById: Record<string, InventionDefinition> = {};
      const toSearch: Array<any> = [];
      for (const invention of this.inventionDefinitions) {
        if (invention.industryCategoryId === this.selectedCategoryId && (invention.industryTypeId || 'GENERAL') === this.selectedIndustryTypeId) {
          inventionById[invention.id] = invention;
          toSearch.push(invention.id);
        }
      }

      while (toSearch.length) {
        const invention_id = toSearch.pop()
        const invention_metadata = this.clientState.core.invention_library.metadata_for_id(invention_id);

        for (const dependsId of (invention_metadata?.dependsOnIds ?? [])) {
          if (!inventionById[dependsId]) {
            inventionById[dependsId] = this.clientState.core.invention_library.metadata_for_id(dependsId);
            toSearch.push(dependsId);
          }
        }
      }
      return Object.values(inventionById);
    },
  },

  watch: {
    isVisible () {
      if (this.isVisible) {
        this.refreshCorporation();
        this.refreshCompany();
        this.refreshInventions();
      }
    },
    corporationId () {
      if (this.isVisible) {
        this.refreshCorporation();
      }
    },
    companyId () {
      if (this.isVisible) {
        this.refreshCompany();
        this.refreshInventions();
      }
    }
  },

  methods: {
    async refreshCorporation (): Promise<void> {
      this.corporation = undefined;
      if (!this.corporationId || !this.isVisible) {
        return;
      }

      try {
        this.corporationPromise = this.$starpeaceClient.managers.corporation_manager.load_by_corporation(this.corporationId);
        this.corporation = await this.corporationPromise;
        this.corporationPromise = undefined;
      }
      catch (err) {
        this.clientState.add_error_message('Failure loading corporation, please try again', err);
        this.corporationPromise = undefined;
      }
    },

    async refreshCompany (): Promise<void> {
      this.company = undefined;
      if (!this.companyId || !this.isVisible) {
        return;
      }

      try {
        this.companyPromise = this.$starpeaceClient.managers.company_manager.load_by_company(this.companyId);
        this.company = await this.companyPromise;
        this.companyPromise = undefined;
      }
      catch (err) {
        this.clientState.add_error_message('Failure loading company, please try again', err);
        this.companyPromise = undefined;
      }
    },

    async refreshInventions (): Promise<void> {
      this.companyInventions = undefined;
      if (!this.companyId || !this.isVisible) {
        return;
      }

      try {
        this.inventionsPromise = this.$starpeaceClient.managers.invention_manager.loadByCompany(this.companyId);
        this.companyInventions = await this.inventionsPromise;
        this.inventionsPromise = undefined;
      }
      catch (err) {
        this.clientState.add_error_message('Failure loading inventions, please try again', err);
        this.inventionsPromise = undefined;
      }
    },

    toggleFormCompany () {
      this.clientState.menu.toggle_menu('company_form');
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
