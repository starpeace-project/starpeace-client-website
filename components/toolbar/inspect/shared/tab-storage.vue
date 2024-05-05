<template lang='pug'>
.column.is-narrow.p-0.is-clipped.is-flex.is-flex-direction-column.storages-tab
  .is-flex-grow-0.sp-kv-key.mb-2 {{ $translate('Wares') }}:

  .is-flex-grow-1.is-relative.pr-2.sp-scrollbar.storage-options
    .is-flex.is-flex-direction-row.storage-option(v-for='option in storageResourceOptions')
      misc-toggle-option(:value='resourceOptions[option.id]' @toggle='toggleResourceOption(option.id)')
      span.ml-2.is-clickable(:class="{'selected-toggle': resourceOptions[option.id] }" @click.stop.prevent='toggleResourceOption(option.id)') {{ option.label }}
</template>

<script lang='ts'>
import _ from 'lodash';

import { BuildingDefinition, SimulationDefinition } from '@starpeace/starpeace-assets-types';

import ClientState from '~/plugins/starpeace-client/state/client-state';
import Building from '~/plugins/starpeace-client/building/building.js';
import BuildingStorage from '~/plugins/starpeace-client/building/details/building-storage';


declare interface StorageOption {
  id: string;
  label: string;
}

declare interface TabStorageData {
  debouncedUpdateBuildingStorage: (buildingId: string, resourceId: string, enabled: boolean) => void;

  resourceOptions: Record<string, boolean>;
}

export default {
  props: {
    clientState: { type: ClientState, required: true },

    building: { type: Building, required: true },
    definition: { type: BuildingDefinition, required: true },
    simulation: { type: SimulationDefinition, required: true },

    storages: { type: Array<BuildingStorage>, required: true },
  },

  data (): TabStorageData {
    return {
      debouncedUpdateBuildingStorage: this.$debounce(250, async (buildingId: string, resourceId: string, enabled: boolean) => {
        await this.$starpeaceClient.managers.building_manager.update_building_settings(buildingId, {
          storage: {
            resourceId: resourceId,
            enabled: enabled
          }
        });
        this.$emit('refresh-details');
      }),
      resourceOptions: {}
    };
  },

  computed: {
    buildingId (): string {
      return this.building.id;
    },
    canManage (): boolean {
      return this.clientState.player.corporation_id === this.building.corporationId;
    },

    sortedStorages (): Array<BuildingStorage> {
      return _.orderBy(this.storages, [(t) => this.$resourceTypeLabel(t.resourceId)], ['asc']);
    },
    storageResourceOptions (): Array<StorageOption> {
      return this.sortedStorages.map((s) => {
        return {
          id: s.resourceId,
          label: this.$resourceTypeLabel(s.resourceId)
        };
      });
    },
    storageByResourceId (): Record<string, BuildingStorage> {
      return Object.fromEntries(this.storages.map(s => [s.resourceId, s]));
    }
  },

  watch: {
    buildingId: {
      immediate: true,
      handler () {
        this.resetResourceOptions();
      }
    },
    storageResourceOptions () {
      this.resetResourceOptions();
    }
  },

  methods: {
    resetResourceOptions (): void {
      this.resourceOptions = {};
      for (const storage of this.sortedStorages) {
        this.resourceOptions[storage.resourceId] = storage.enabled;
      }
    },

    toggleResourceOption (resourceId: string): void {
      this.resourceOptions[resourceId] = !this.resourceOptions[resourceId];

      if (this.storageByResourceId[resourceId]) {
        this.debouncedUpdateBuildingStorage(this.buildingId, resourceId, this.resourceOptions[resourceId]);
        this.storageByResourceId[resourceId].enabled = this.resourceOptions[resourceId];
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'
@import '~/assets/stylesheets/starpeace-inspect'

.storages-tab
  height: 100%

.storage-options
  color: $sp-primary
  overflow-y: auto
  text-transform: capitalize

  .selected-toggle
    color: #fff
</style>
