<template lang='pug'>
.columns.is-marginless.management-tab
  .column.is-narrow.is-paddingless.p-3.mr-3.column-allow-clone(v-if='manageOptionsBuilding.length')
    .is-flex.is-flex-direction-row
      misc-toggle-option(:disabled='!canManage' :value='buildingDetails.allowIncomingSettings' @toggle='toggleAllowIncoming')
      span.ml-2.toggle-label(:class="{'selected-toggle': buildingDetails.allowIncomingSettings, 'is-clickable': canManage, 'is-disabled': !canManage}" @click.stop.prevent='toggleAllowIncoming') {{ $translate('toolbar.inspect.management.label.incoming') }}

    div.mt-5
      span(v-if='buildingDetails.allowIncomingSettings') {{ $translate('toolbar.inspect.management.label.incoming.allow') }}
      span(v-else) {{ $translate('toolbar.inspect.management.label.incoming.block') }}


  .column.is-narrow.is-paddingless.is-flex.is-flex-direction-row.p-3.mr-5.column-clone(v-if='manageOptionsBuilding.length')
    .is-relative.is-flex.is-flex-direction-column.is-clipped
      .is-flex-grow-0.sp-kv-key.mb-2 {{ $translate('toolbar.inspect.management.label.clone') }}:

      .is-flex-grow-1.is-relative.pr-2.sp-scrollbar.clone-options
        .is-flex.is-flex-direction-row(v-for='option in manageOptionsAll')
          misc-toggle-option(:disabled='!canManage' :value='cloneOptions[option.id]' @toggle='toggleCloneOption(option.id)')
          span.ml-2.toggle-label(:class="{'selected-toggle': cloneOptions[option.id], 'is-clickable': canManage, 'is-disabled': !canManage}" @click.stop.prevent='toggleCloneOption(option.id)') {{ $translate(option.label) }}

    div.ml-5.clone-action
      button.button.is-fullwidth.is-starpeace(:disabled='!canClone' @click.stop.prevent='cloneSettings') {{ $translate('toolbar.inspect.management.action.clone') }}

  .column.is-narrow.is-paddingless.is-flex.is-flex-direction-column.p-3
    div
      span.sp-kv-key {{ $translate('toolbar.inspect.management.level') }}:
      span.has-text-right.sp-kv-value {{ currentLevelDescription }}
    div
      span.sp-kv-key {{ $translate('toolbar.inspect.management.level.pending') }}:
      span.has-text-right.sp-kv-value {{ pendingLevels }}
    div
      span.sp-kv-key {{ $translate('toolbar.inspect.management.level.next') }}:
      span.has-text-right.sp-kv-value {{ $format_money(upgradeCost) }}

    .is-flex.is-flex-direction-row.mt-3
      button.button.is-fullwidth.is-starpeace(:disabled='!canUpgrade' @click.stop.prevent='addUpgrade') {{ $translate('toolbar.inspect.management.action.upgrade') }}
      button.button.is-fullwidth.is-starpeace.ml-2(:disabled='!canDowngrade' @click.stop.prevent='addDowngrade') {{ $translate('toolbar.inspect.management.action.downgrade') }}
</template>

<script lang='ts'>
import _ from 'lodash';

import { BuildingDefinition, FactoryDefinition, FarmDefinition, ResidenceDefinition, SimulationDefinition, StorageDefinition, StoreDefinition } from '@starpeace/starpeace-assets-types';

import ClientState from '~/plugins/starpeace-client/state/client-state';
import Building from '~/plugins/starpeace-client/building/building';
import BuildingDetails from '~/plugins/starpeace-client/building/building-details';


declare interface TabJobsData {
  debouncedUpdateBuildingAllowSettings: (buildingId: string, allowSettings: boolean) => void;
  debouncedUpdateBuildingLevel: (buildingId: string, requestedLevel: number) => void;

  cloneOptions: Record<string, boolean>;
  clonePromise: Promise<any> | undefined;
  }

  declare interface CloneOption {
    id: string;
    label: string;
  }

const DEFAULT_OFF_CLONE_SETTINGS = new Set(['name', 'connectionPosture']);

export default {
  props: {
    clientState: { type: ClientState, required: true },

    building: { type: Building, required: true },
    definition: { type: BuildingDefinition, required: true },
    simulation: { type: SimulationDefinition, required: true },

    buildingDetails: { type: BuildingDetails, required: true }
  },

  data (): TabJobsData {
    return {
      debouncedUpdateBuildingAllowSettings: this.$debounce(250, async (buildingId: string, allowSettings: boolean) => {
        await this.$starpeaceClient.managers.building_manager.update_building_settings(buildingId, {
          allowIncomingSettings: allowSettings
        });
      }),
      debouncedUpdateBuildingLevel: this.$debounce(250, async (buildingId: string, requestedLevel: number) => {
        await this.$starpeaceClient.managers.building_manager.update_building_settings(buildingId, {
          requestedLevel: requestedLevel
        });
      }),
      cloneOptions: {},
      clonePromise: undefined
    };
  },

  computed: {
    buildingId (): string {
      return this.building.id;
    },
    canManage (): boolean {
      return this.clientState.player.corporation_id === this.building.corporationId;
    },

    manageOptionsDefault (): Array<CloneOption> {
      return [{
        id: 'sameCompany',
        label: 'toolbar.inspect.management.label.clone.same_company'
      }, {
        id: 'sameTown',
        label: 'toolbar.inspect.management.label.clone.same_town'
      }];
    },
    manageOptionsBuilding (): Array<CloneOption> {
      const options = [];
      if (this.building.constructed) {
        options.push({
          id: 'name',
          label: 'toolbar.inspect.management.label.clone.name'
        });
      }
      if (this.buildingDetails.outputs?.length > 0 || this.buildingDetails.inputs?.length > 0 || this.simulation instanceof StorageDefinition) {
        options.push({
          id: 'connectionPosture',
          label: 'toolbar.inspect.management.label.clone.connection_posture'
        });
      }
      if (this.buildingDetails.labors?.length > 0) {
        options.push({
          id: 'salaries',
          label: 'toolbar.inspect.management.label.clone.salaries'
        });
      }
      if (this.buildingDetails.outputs?.length > 0 && (this.simulation instanceof FactoryDefinition || this.simulation instanceof FarmDefinition || this.simulation instanceof StoreDefinition)) {
        options.push({
          id: 'price',
          label: 'toolbar.inspect.management.label.clone.price'
        });
      }
      if (this.buildingDetails.inputs?.length > 0) {
        options.push({
          id: 'supplies',
          label: 'toolbar.inspect.management.label.clone.suppliers'
        });
      }
      if (this.buildingDetails.services?.length > 0) {
        options.push({
          id: 'services',
          label: 'toolbar.inspect.management.label.clone.services'
        });
      }
      if (this.buildingDetails.rents?.length > 0) {
        options.push({
          id: 'rent',
          label: 'toolbar.inspect.management.label.clone.rent'
        });
        options.push({
          id: 'maintenance',
          label: 'toolbar.inspect.management.label.clone.maintenance'
        });
      }
      return options;
    },
    manageOptionsAll (): Array<CloneOption> {
      return new Array().concat(this.manageOptionsDefault).concat(this.manageOptionsBuilding);
    },

    canClone (): boolean {
      if (this.canManage && !this.clonePromise) {
        for (const option of this.manageOptionsBuilding) {
          if (this.cloneOptions[option.id]) {
            return true;
          }
        }
      }
      return false;
    },

    canUpgrade (): boolean {
      return this.canManage && (this.buildingDetails.requestedLevel < this.buildingDetails.maxLevel);
    },
    canDowngrade (): boolean {
      return this.canManage && (this.buildingDetails.requestedLevel > 1);
    },

    upgradeCost (): number {
      const cost = (this.simulation?.constructionInputs ?? []).reduce((sum: number, input: any) => sum + (this.$resourceTypePrice(input.resourceId) * input.quantity), 0);
      return cost / 2;
    },

    currentLevelDescription (): string {
      return `${this.buildingDetails.level} ${this.$translate('toolbar.inspect.management.level.separator')} ${this.buildingDetails.maxLevel}`;
    },
    pendingLevels (): number {
      return Math.max(this.buildingDetails.requestedLevel - this.buildingDetails.level, 0);
    }
  },

  watch: {
    buildingId: {
      immediate: true,
      handler () {
        this.resetCloneOptions();
      }
    },
    manageOptionsAll (newValue, oldValue) {
      if (!_.isEqual(newValue, oldValue)) {
        this.resetCloneOptions();
      }
    }
  },

  methods: {
    toggleAllowIncoming (): void {
      if (this.canManage && this.buildingDetails) {
        this.buildingDetails.allowIncomingSettings = !this.buildingDetails.allowIncomingSettings;
        this.debouncedUpdateBuildingAllowSettings(this.building.id, this.buildingDetails.allowIncomingSettings);
      }
    },

    resetCloneOptions (): void {
      this.cloneOptions = {};
      for (const option of this.manageOptionsAll) {
        this.cloneOptions[option.id] = DEFAULT_OFF_CLONE_SETTINGS.has(option.id) ? false : true;
      }
    },
    toggleCloneOption (id: string): void {
      if (this.canManage) {
        this.cloneOptions[id] = !this.cloneOptions[id];
      }
    },
    async cloneSettings (): Promise<void> {
      if (!this.canClone) {
        return;
      }

      try {
        const optionIds = Object.entries(this.cloneOptions).filter(([id, enabled]) => enabled).map(([id, enabled]) => id);
        this.clonePromise = this.$starpeaceClient.managers.building_manager.clone_building(this.building.id, optionIds);
        const count = await this.clonePromise;
        this.clonePromise = undefined;

        if (count <= 0) {
          this.clientState.add_system_message(this.$translate('toolbar.inspect.management.clone.notification.none') ?? '');
        }
        else {
          this.clientState.add_system_message(_.template(this.$translate('toolbar.inspect.management.clone.notification'))({ count: count }));
        }
      }
      catch (err) {
        this.clientState.add_error_message('Failure cloning building, please try again', err);
        this.clonePromise = undefined;
      }
    },

    addUpgrade (): void {
      if (this.canUpgrade) {
        this.buildingDetails.requestedLevel++;
        this.debouncedUpdateBuildingLevel(this.building.id, this.buildingDetails.requestedLevel);
      }
    },
    addDowngrade (): void {
      if (this.canDowngrade) {
        this.buildingDetails.requestedLevel--;
        this.debouncedUpdateBuildingLevel(this.building.id, this.buildingDetails.requestedLevel);
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'
@import '~/assets/stylesheets/starpeace-inspect'

.management-tab
  color: $sp-primary
  height: 100%

.column-clone
  height: 100%

.clone-options
  overflow-y: auto

.column-allow-clone
  max-width: 20rem

.clone-action
  min-width: 10rem

.toggle-label
  &.selected-toggle
    color: #fff

  &.is-disabled
    cursor: not-allowed

</style>
