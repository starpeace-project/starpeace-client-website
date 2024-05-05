<template lang='pug'>
.columns.m-0.is-relative.is-clipped.general-tab
  .column.is-narrow.pr-5.general
    .is-flex.is-flex-direction-row(:class="{'mb-1 is-align-items-center': isRenaming, 'is-align-items-baseline': !isRenaming}")
      span.sp-kv-key {{ $translate('toolbar.inspect.common.label.name') }}:
      span.sp-kv-value
        template(v-if='isRenaming')
          .field.has-addons
            .control
              input.input(type='text' v-model='buildingName')
            .control
              button.button.is-fullwidth.is-starpeace(:disabled='!canSaveRename' @click.stop.prevent='saveRename') {{ $translate('toolbar.inspect.common.action.rename.save') }}

        template(v-else)
          template(v-if='name') {{ name }}
          template(v-else) {{ $translate('ui.misc.none') }}

    div(v-if='landPurchasedAt && !constructedAt')
      span.sp-kv-key {{ $translate('toolbar.inspect.common.label.land_purchased') }}:
      span.sp-kv-value {{ landPurchasedAt }}
    div(v-if='constructedAt')
      span.sp-kv-key {{ $translate('toolbar.inspect.common.label.built') }}:
      span.sp-kv-value {{ constructedAt }}
    div
      span.sp-kv-key {{ $translate('toolbar.inspect.common.label.owner') }}:
      span.sp-kv-value(:class="{'centered': !!tycoonNamePromise}")
        template(v-if='tycoonNamePromise')
          img.loading-image-inline.starpeace-logo.logo-loading
        template(v-else-if='tycoonName') {{ tycoonName }}
        template(v-else) {{ $translate('ui.misc.unknown') }}
    div
      span.sp-kv-key {{ $translate('toolbar.inspect.common.label.company') }}:
      span.sp-kv-value(:class="{'centered': !!companyNamePromise}")
        template(v-if='companyNamePromise')
          img.loading-image-inline.starpeace-logo.logo-loading
        template(v-else-if='companyName') {{ companyName }}
        template(v-else) {{ $translate('ui.misc.unknown') }}
    div
      span.sp-kv-key {{ $translate('toolbar.inspect.common.label.value') }}:
      span.sp-kv-value {{ $format_money(buildingValue) }}
    div(v-if='!(buildingCumulativeProfit > 0)')
      span.sp-kv-key {{ $translate('toolbar.inspect.common.label.roi') }}:
      span.sp-kv-value
        template(v-if='!(buildingReturnOnInvestmentMonths > 0)') {{ $translate('ui.misc.never') }}
        template(v-else-if='!(buildingReturnOnInvestmentMonths >= 2)') 1 {{ $translate('misc.unit.month.singular') }}
        template(v-else) {{ buildingReturnOnInvestmentMonths }} {{ $translate('misc.unit.month.plural') }}

  .column.is-narrow.px-5.general-actions
    .is-flex.is-flex-direction-row.mb-2(v-if='hasConnectionPosture' :class="{'is-align-items-center': canManage, 'is-align-items-baseline': !canManage}")
      span.sp-kv-key {{ $translate('toolbar.inspect.common.label.connection_posture') }}:
      span.sp-kv-value(:class="{'centered': !!tycoonNamePromise}")
        template(v-if='tycoonNamePromise || !tycoonName')
          img.loading-image-inline.starpeace-logo.logo-loading
        template(v-else)
          .select.sp-select(v-if='canManage')
            select(v-model='connectionPosture' @change='debouncedUpdateBuildingConnectionPosture(building.id, connectionPosture)')
              option(value='ANYONE') {{ $translate('toolbar.inspect.common.label.connection_posture.anyone') }}
              option(value='ONLY_ALLIES') {{ $translate('toolbar.inspect.common.label.connection_posture.allies') }}
              option(value='ONLY_SELF') {{ $translate('toolbar.inspect.common.label.connection_posture.self') }} {{ tycoonName }}
          span(v-else)
            template(v-if="connectionPosture == 'ANYONE'") {{ $translate('toolbar.inspect.common.label.connection_posture.anyone') }}
            template(v-else-if="connectionPosture == 'ONLY_ALLIES'") {{ $translate('toolbar.inspect.common.label.connection_posture.allies') }}
            template(v-else-if="connectionPosture == 'ONLY_SELF'") {{ $translate('toolbar.inspect.common.label.connection_posture.self') }} {{ tycoonName }}

    template(v-if='isConstructed')
      button.button.is-fullwidth.is-starpeace.mb-1(v-if='!isRenaming' :disabled='!canManage' @click.stop.prevent='toggleRename') {{ $translate('toolbar.inspect.common.action.rename') }}
      button.button.is-fullwidth.is-starpeace.mb-1(v-else :disabled='!canManage' @click.stop.prevent='toggleRename') {{ $translate('toolbar.inspect.common.action.cancel') }}
      button.button.is-fullwidth.is-starpeace.mb-1(v-if='!isClosed' :disabled='!canClose' @click.stop.prevent='toggleClosed') {{ $translate('toolbar.inspect.common.action.close') }}
      button.button.is-fullwidth.is-starpeace.mb-1(v-else :disabled='!canOpen' @click.stop.prevent='toggleClosed') {{ $translate('toolbar.inspect.common.action.open') }}

    button.button.is-fullwidth.is-starpeace.mb-1(:disabled='!canDemolish' @click.stop.prevent='demolishBuilding') {{ $translate('toolbar.inspect.common.action.demolish') }}
    button.button.is-fullwidth.is-starpeace(v-if='hasRents' :disabled='!canRepair') {{ $translate('toolbar.inspect.common.action.repair') }}

  .column.py-0.pl-5.pr-3(v-if='hasStoreProducts')
    toolbar-inspect-shared-tab-store-products(
      :client-state='clientState'
      :building='building'
      :definition='definition'
      :simulation='simulation'
      :products='buildingDetails.outputs'
    )

  .column.pl-5.pr-3(v-if='hasRents')
    toolbar-inspect-shared-tab-rents(
      :client-state='clientState'
      :building='building'
      :definition='definition'
      :simulation='simulation'
      :rents='buildingDetails.rents'
    )

  .column.is-narrow.pl-5.pr-3(v-if='hasStorage')
    toolbar-inspect-shared-tab-storage(
      :client-state='clientState'
      :building='building'
      :definition='definition'
      :simulation='simulation'
      :storages='buildingDetails.storages'
      @refresh-details="$emit('refresh-details')"
    )

  .column.is-narrow.pl-0.pr-3(v-if='isCondemned')
    .sp-notification.is-warning.is-uppercase.has-text-weight-bold.is-italic.is-size-5.p-3.condemned-message
      span {{ $translate('toolbar.inspect.common.demolition.message') }}
      span.ml-1 {{ condemnedDate }}

</template>

<script lang='ts'>
import _ from 'lodash';

import { BuildingDefinition, ResidenceDefinition, SimulationDefinition, StorageDefinition, StoreDefinition, isSimulationWithOutputs, isSimulationWithStorage } from '@starpeace/starpeace-assets-types';

import ClientState from '~/plugins/starpeace-client/state/client-state';
import Building from '~/plugins/starpeace-client/building/building.js';
import Tycoon from '~/plugins/starpeace-client/tycoon/tycoon';
import Company from '~/plugins/starpeace-client/company/company';
import BuildingDetails from '~/plugins/starpeace-client/building/building-details';

declare interface TabGeneralData {
  debouncedUpdateBuildingRename: (buildingId: string, name: string) => void;
  debouncedUpdateBuildingConnectionPosture: (buildingId: string, posture: string) => void;
  debouncedUpdateBuildingClosed: (buildingId: string, closed: boolean) => void;

  productIndex: number;
  selectedIndices: Record<string, boolean>;

  buildingName: string | undefined;

  tycoonName: string | undefined;
  tycoonNamePromise: Promise<Tycoon> | undefined;
  companyName: string | undefined;
  companyNamePromise: Promise<Company> | undefined;

  demolishPromise: Promise<any> | undefined;
}

export default {
  props: {
    clientState: { type: ClientState, required: true },

    building: { type: Building, required: true },
    definition: { type: BuildingDefinition, required: true },
    simulation: { type: SimulationDefinition, required: true },

    buildingDetails: { type: BuildingDetails, required: true }
  },

  data (): TabGeneralData {
    return {
      debouncedUpdateBuildingRename: this.$debounce(250, async (buildingId: string, name: string) => {
        await this.$starpeaceClient.managers.building_manager.update_building_settings(buildingId, {
          name: name
        });
      }),
      debouncedUpdateBuildingConnectionPosture: this.$debounce(250, async (buildingId: string, posture: string) => {
        await this.$starpeaceClient.managers.building_manager.update_building_settings(buildingId, {
          connectionPosture: posture
        });
      }),
      debouncedUpdateBuildingClosed: this.$debounce(250, async (buildingId: string, closed: boolean) => {
        await this.$starpeaceClient.managers.building_manager.update_building_settings(buildingId, {
          closed: closed
        });
        this.$emit('refresh-details');
      }),

      productIndex: 0,
      selectedIndices: {},

      buildingName: undefined,

      tycoonName: undefined,
      tycoonNamePromise: undefined,
      companyName: undefined,
      companyNamePromise: undefined,

      demolishPromise: undefined
    };
  },

  computed: {
    tycoonId (): string | undefined {
      return this.building.tycoonId;
    },
    companyId (): string | undefined {
      return this.building.companyId;
    },

    name (): string | undefined {
      return this.building?.name ?? (this.definition?.name ? this.$translate(this.definition.name) : undefined);
    },
    connectionPosture: {
      get (): string {
        return this.buildingDetails.connectionPosture;
      },
      set (value: string): void {
        this.buildingDetails.connectionPosture = value;
      }
    },
    landPurchasedAt (): string | undefined {
      return this.building.constructionStartedAt?.toFormat('LLL dd, yyyy');
    },
    constructedAt (): string | undefined {
      return this.building.constructionFinishedAt?.toFormat('LLL dd, yyyy');
    },
    isConstructed (): boolean {
      return !!this.building.constructionFinishedAt;
    },

    canManage (): boolean {
      return this.clientState.player.corporation_id === this.building.corporationId;
    },

    isClosed (): boolean {
      return this.buildingDetails.closed;
    },
    canClose (): boolean {
      return this.canManage && !this.isClosed;
    },
    canOpen (): boolean {
      return this.canManage && this.isClosed;
    },

    canSaveRename (): boolean {
      return this.canManage && (this.buildingName?.length ?? 0) >= 3 && this.building.name !== this.buildingName;
    },
    isRenaming (): boolean {
      return this.canManage && this.isConstructed && !!this.buildingName;
    },

    isCondemned (): boolean {
      return !!this.building.condemnedAt;
    },
    condemnedDate (): string {
      return this.building.condemnedAt?.toFormat('MMM d, yyyy') ?? '';
    },
    condemnedMonths (): number {
      return this.building.condemnedAt && this.clientState.planet.current_time ? Math.floor(this.building.condemnedAt.diff(this.clientState.planet.current_time, 'months').as('months')) : 0;
    },
    canDemolish (): boolean {
      return this.canManage && (!this.isCondemned || this.condemnedMonths > 1) && !this.demolishPromise;
    },

    canRepair (): boolean {
      // TODO: hook up to quality somehow
      return this.hasRents && false;
    },

    buildingValue (): number {
      return 0;
    },
    buildingCumulativeProfit (): number {
      return 0;
    },
    buildingReturnOnInvestmentMonths (): number {
      return -1;
    },

    hasConnectionPosture (): boolean {
      return (this.buildingDetails.inputs?.length ?? 0) > 0 || (this.buildingDetails.outputs?.length ?? 0) > 0 || this.hasStorage;
    },
    hasStoreProducts (): boolean {
      return this.simulation instanceof StoreDefinition && isSimulationWithOutputs(this.simulation) && (this.buildingDetails.outputs?.length ?? 0) > 0;
    },
    hasRents (): boolean {
      return this.simulation instanceof ResidenceDefinition && (this.buildingDetails.rents?.length ?? 0) > 0;
    },
    hasStorage (): boolean {
      return this.simulation instanceof StorageDefinition && isSimulationWithStorage(this.simulation) && (this.buildingDetails.storages?.length ?? 0) > 0;
    }
  },

  watch: {
    tycoonId: {
      immediate: true,
      handler () {
        this.refreshTycoon();
      }
    },
    companyId: {
      immediate: true,
      handler () {
        this.refreshCompany();
      }
    }
  },

  methods: {
    async refreshTycoon (): Promise<void> {
      this.tycoonName = undefined;
      if (!this.tycoonId) {
        return;
      }

      try {
        this.tycoonNamePromise = this.$starpeaceClient.managers.tycoon_manager.load_metadata_by_tycoon_id(this.tycoonId);
        this.tycoonName = (await this.tycoonNamePromise)?.name;
        this.tycoonNamePromise = undefined;
      }
      catch (err) {
        this.clientState.add_error_message('Failure loading tycoon, please try again', err);
        this.tycoonNamePromise = undefined;
      }
    },

    async refreshCompany (): Promise<void> {
      this.companyName = undefined;
      if (!this.companyId) {
        return;
      }

      try {
        this.companyNamePromise = this.$starpeaceClient.managers.company_manager.load_by_company(this.companyId);
        this.companyName = (await this.companyNamePromise)?.name;
        this.companyNamePromise = undefined;
      }
      catch (err) {
        this.clientState.add_error_message('Failure loading company, please try again', err);
        this.companyNamePromise = undefined;
      }
    },

    toggleRename (): void {
      if (!this.canManage || !this.isConstructed) {
        return;
      }

      if (!this.buildingName) {
        this.buildingName = this.building.name;
      }
      else {
        this.buildingName = undefined;
      }
    },
    saveRename (): void {
      if (this.canManage && this.isConstructed && this.canSaveRename && this.buildingName) {
        this.debouncedUpdateBuildingRename(this.building.id, this.buildingName);
        this.building.name = this.buildingName;
        this.buildingName = undefined;
      }
    },

    toggleClosed (): void {
      if (this.isClosed && !this.canOpen || !this.isClosed && !this.canClose) {
        return;
      }
      if (this.buildingDetails) {
        this.buildingDetails.closed = !this.buildingDetails.closed;
        this.debouncedUpdateBuildingClosed(this.building.id, this.buildingDetails.closed);
      }
    },

    async demolishBuilding (): Promise<void> {
      if (!this.canDemolish) {
        return;
      }

      try {
        this.demolishPromise = this.$starpeaceClient.managers.building_manager.demolish_building(this.building.id);
        await this.demolishPromise;
        this.demolishPromise = undefined;
      }
      catch (err) {
        this.clientState.add_error_message('Failure demolishing building, please try again', err);
        this.demolishPromise = undefined;
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'
@import '~/assets/stylesheets/starpeace-inspect'

.column
  &.general-actions
    min-width: 16rem

.condemned-message
  height: 100%
  max-width: 24rem

.general-tab
  height: 100%
  width: 100%
</style>
