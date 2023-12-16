<template lang='pug'>
#construction-container.card.is-starpeace.has-header(:oncontextmenu="'return ' + !$config.public.disableRightClick")
  .card-header
    .card-header-title {{$translate('ui.menu.construction.header')}}
    .card-header-icon.card-close(@click.stop.prevent="client_state.menu.toggle_menu('construction')")
      font-awesome-icon(:icon="['fas', 'times']")


  .card-content.sp-menu-background.overall-container
    #construction-image-pending(ref="pendingContainer")
      #construction-image-webgl-container(ref="previewContainer")

    template(v-if='isTycoon && companyId && !company || companyPromise')
      .sp-loading.is-flex.is-align-items-center.is-justify-content-center
        img.starpeace-logo

    template(v-else)
      .field.filter-input-container
        .control.has-icons-left.is-expanded
          input.input(type="text", placeholder="Filter")
          span.icon.is-left
            font-awesome-icon(:icon="['fas', 'search-location']")
      nav.breadcrumb.is-medium.menu-breadcrumb
        ul
          li(:class="{'is-active': !selectedIndustryCategoryId}")
            a(@click.stop.prevent='selectRootBreadcrumb')
              template(v-if='companySealId')
                span.icon.is-small
                  misc-company-seal-icon.company-seal(:seal_id="companySealId")
                span {{ $companySealShortLabel(companySealId) }}
              template(v-else)
                span.icon.is-small
                  font-awesome-icon.tycoon-icon(:icon="['fas', 'user-secret']")
                span {{$translate('identity.visitor')}}

          template(v-if='selectedIndustryCategoryId')
            li.is-active
              a.construction-breadcrumb-item
                span {{ $industryCategoryLabel(selectedIndustryCategoryId) }}

      template(v-if="selectedIndustryCategoryId")
        menu-construction-industry-category-construct(
          :client-state='client_state'
          :company='company'
          :company-buildings-by-category-id='companyBuildingsByCategoryId'
          :selected-industry-category-id='selectedIndustryCategoryId'
          @select='selectDefinitionId'
        )

      template(v-else)
        menu-construction-industry-category-controls(
          :client-state='client_state'
          :company='company'
          :company-buildings-by-category-id='companyBuildingsByCategoryId'
          @select='selectCategoryId'
        )

  #no-company-modal.modal-background(v-if='hasNoCompany')
    .content
      span {{$translate('ui.menu.construction.company_required.label')}}
      a(@click.stop.prevent='toggleFormCompanyMenu') {{$translate('ui.menu.construction.company_required.action')}}

</template>

<script lang='ts'>
import _ from 'lodash';

import { BuildingDefinition } from '@starpeace/starpeace-assets-types';

import ClientState from '~/plugins/starpeace-client/state/client-state';
import Company from '~/plugins/starpeace-client/company/company';

interface ConstructionMainMenuData {
  companyPromise: Promise<Company> | undefined,
  company: Company | undefined;
}

export default {
  props: {
    client_state: { type: ClientState, required: true }
  },

  data (): ConstructionMainMenuData {
    return {
      companyPromise: undefined,
      company: undefined
    }
  },

  computed: {
    isReady (): boolean {
      return this.client_state?.workflow_status === 'ready';
    },
    isVisible (): boolean {
      return this.isReady && (this.client_state?.menu?.is_visible('construction') ?? false);
    },

    isTycoon (): boolean {
      return this.isReady && this.client_state?.is_tycoon();
    },
    companyId (): string | null {
      return this.isTycoon ? this.client_state.player.company_id : null;
    },
    companySealId (): string | undefined {
      return this.company?.sealId;
    },

    hasNoCompany (): boolean {
      return this.isReady && this.isTycoon && !this.client_state.player.company_id;
    },

    selectedIndustryCategoryId (): string | null {
      return this.client_state.interface.construction_selected_category_id;
    },
    selectedDefinitionId (): string | null {
      return this.client_state.interface.construction_selected_building_id;
    },

    companyBuildingsByCategoryId (): Record<string, Array<BuildingDefinition>> {
      if (!this.isVisible || this.isTycoon && !this.company?.sealId) {
        return {};
      }

      const definitions = this.company?.sealId ? this.client_state.core.building_library.definitions_for_seal(this.company?.sealId) : _.values(this.client_state.core.building_library.metadata_by_id);
      return _.groupBy((definitions ?? []).filter((info: BuildingDefinition) => !info.restricted), (info) => info.industryCategoryId);
    }
  },

  watch: {
    companyId () {
      this.refreshCompany();
    },
    isVisible () {
      this.refreshCompany();
    }
  },

  mounted () {
    this.client_state.corporation.subscribe_company_inventions_listener(() => {
      if (this.isVisible) {
        this.$forceUpdate();
      }
    });
    this.client_state?.options?.subscribe_options_listener(() => {
      if (this.isVisible) {
        this.$forceUpdate();
      }
    });
  },

  methods: {
    toggleFormCompanyMenu (): void {
      this.client_state.menu.toggle_menu('company_form');
    },

    selectRootBreadcrumb (): void {
      if (this.selectedIndustryCategoryId) {
        this.client_state.interface.selectConstructionCategoryId(null);
        if (this.selectedDefinitionId && this.$refs.previewContainer && this.$refs.pendingContainer) {
          this.client_state.interface.selectConstructionDefinitionId(null);

          if (this.$refs.previewContainer.parentElement) {
            this.$refs.previewContainer.parentElement.removeChild(this.$refs.previewContainer);
            this.$refs.pendingContainer.appendChild(this.$refs.previewContainer);
          }
        }
      }
    },

    selectCategoryId (categoryId: string): void {
      if (this.companyBuildingsByCategoryId[categoryId]) {
        this.client_state.interface.selectConstructionCategoryId(categoryId);
      }
    },

    selectDefinitionId (event: any): void {
      if (this.$refs.previewContainer && this.$refs.pendingContainer) {
        if (this.$refs.previewContainer.parentElement) {
          this.$refs.previewContainer.parentElement.removeChild(this.$refs.previewContainer);
        }

        if (!event?.definitionId) {
          this.$refs.pendingContainer.appendChild(this.$refs.previewContainer);
        }
        else if (event.previewContainer) {
          if (Array.isArray(event.previewContainer)) {
            event.previewContainer[0].appendChild(this.$refs.previewContainer);
          }
          else {
            event.previewContainer.appendChild(this.$refs.previewContainer);
          }
        }
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
        this.client_state.add_error_message('Failure loading company, please try again', err);
        this.companyPromise = undefined;
      }
    },
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.sp-loading
  height: 100%

  .starpeace-logo
    animation: spin-and-blink 1.5s linear infinite
    background-size: 6rem
    filter: $sp-filter-primary
    height: 6rem
    opacity: .7
    width: 6rem


#construction-container
  grid-column: start-right / end-right
  grid-row: start-render / end-inspect
  overflow: hidden
  width: 30rem
  z-index: 1100

  .card-content
    height: calc(100% - 3.2rem)
    padding: 0

  .filter-input-container
    height: 3.75rem
    margin-bottom: 1rem
    padding: 1.25rem 1.25rem 0 1.25rem

  .menu-breadcrumb
    height: 2rem
    margin-bottom: .75rem
    padding: 0 1.25rem

  #construction-image-pending
    display: none

  #construction-image-webgl-container
    height: 6rem
    width: 12rem

#no-company-modal
  align-items: center
  display: flex
  justify-content: center
  padding: 1rem
  text-align: center
  top: 3.4rem
  z-index: 1000

  .content
    color: $sp-primary
    font-size: 1.5rem
    font-style: italic

  a
    font-weight: bold
    color: $sp-primary
    margin-left: .4rem

    &:not(.disabled)
      &:hover,
      &.is-hover
        color: $sp-light

      &:active,
      &.is-active
        color: #fff


</style>
