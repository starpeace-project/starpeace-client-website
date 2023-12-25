<template lang='pug'>
.inspect-container(v-show='isVisible' :oncontextmenu="'return ' + !$config.public.disableRightClick")
  .inspect-preview.is-marginless
    #inspect-image-webgl-container(ref='previewContainer')

  template(v-if='!isVisible || isLoading || !buildingType')
    .is-flex.is-align-items-center.is-justify-content-center
      img.loading-image.starpeace-logo.logo-loading

  template(v-else)
    template(v-if="buildingTypeInspectType == 'PORTAL'")
      toolbar-inspect-portal(:client-state='clientState' :key='selectedBuildingId' :building='selectedBuilding')

    template(v-else-if="buildingTypeInspectType == 'TOWNHALL'")
      toolbar-inspect-townhall(
        :key='selectedBuildingId'
        :client-state='clientState'
        :building='selectedBuilding'
        :definition='selectedBuildingDefinition'
        :simulation='selectedBuildingSimulation'
        :building-details='buildingDetails'
        )

    template(v-else-if="buildingTypeInspectType == 'TRADECENTER'")
      toolbar-inspect-trade-center(
        :key='selectedBuildingId'
        :client-state='clientState'
        :building='selectedBuilding'
        :definition='selectedBuildingDefinition'
        :simulation='selectedBuildingSimulation'
        :building-details='buildingDetails'
      )

    template(v-else)
      toolbar-inspect-building(
        :key='selectedBuildingId'
        :client-state='clientState'
        :building='selectedBuilding'
        :definition='selectedBuildingDefinition'
        :simulation='selectedBuildingSimulation'
        :building-details='buildingDetails'
        @refresh-details='refreshBuildingDetails'
      )

</template>

<script lang='ts'>
import { BuildingDefinition, SimulationDefinition } from '@starpeace/starpeace-assets-types';

import ClientState from '~/plugins/starpeace-client/state/client-state';
import Building from '~/plugins/starpeace-client/building/building';
import BuildingDetails from '~/plugins/starpeace-client/building/building-details';

declare interface ToolbarInspectData {
  buildingDetailsPromise: Promise<BuildingDetails> | undefined;
  buildingDetails: BuildingDetails | undefined;
  buildingDetailsConstructed: boolean | undefined;
  buildingDetailsUpgrading: boolean | undefined;
}

export default {
  props: {
    clientState: { type: ClientState, required: true }
  },

  data (): ToolbarInspectData {
    return {
      buildingDetailsPromise: undefined,
      buildingDetails: undefined,
      buildingDetailsConstructed: undefined,
      buildingDetailsUpgrading: undefined
    };
  },

  computed: {
    isReady (): boolean {
      return this.clientState.initialized && this.clientState.workflow_status === 'ready';
    },
    isLoading (): boolean {
      return !this.buildingDetails;
    },

    isVisible (): boolean {
      return this.isReady && (this.clientState.interface?.selected_building_id?.length ?? 0) > 0 && this.clientState.interface?.show_inspect;
    },

    selectedBuildingId (): string | undefined | null {
      return this.isVisible ? this.clientState.interface?.selected_building_id : undefined;
    },
    selectedBuilding (): Building | undefined | null {
      return this.isVisible && this.selectedBuildingId ? this.clientState.core.building_cache.building_for_id(this.selectedBuildingId) : undefined;
    },
    selectedBuildingConstructed (): boolean {
      return !!this.selectedBuilding?.constructionFinishedAt;
    },
    selectedBuildingUpgrading (): boolean {
      return this.selectedBuilding?.upgrading ?? false;
    },
    selectedBuildingDefinition (): BuildingDefinition | undefined | null {
      return this.selectedBuilding ? this.clientState.core.building_library.definition_for_id(this.selectedBuilding.definition_id) : undefined;
    },
    selectedBuildingSimulation (): SimulationDefinition | undefined | null {
      return this.selectedBuilding ? this.clientState.core.building_library.simulation_definition_for_id(this.selectedBuilding.definition_id) : undefined;
    },

    selectedBuildingDetailsStale (): boolean {
      return !this.buildingDetails || this.buildingDetails && (
        this.buildingDetailsConstructed !== this.selectedBuildingConstructed ||
        this.buildingDetailsUpgrading !== this.selectedBuildingUpgrading
      );
    },

    buildingType (): string | undefined {
      return this.selectedBuildingSimulation?.type;
    },
    buildingTypeInspectType (): string {
      if (this.buildingType === 'PORTAL') {
        return 'PORTAL';
      }
      else if (this.buildingType === 'TOWNHALL') {
        return 'TOWNHALL';
      }
      else if (this.buildingType === 'TRADECENTER') {
        return 'TRADECENTER';
      }
      else {
        return 'DEFAULT';
      }
    }
  },

  mounted() {
    this.clientState.planet.subscribeBuildingListener((event: any) => {
      if (this.isVisible && this.selectedBuildingId === event.id) {
        this.refreshBuildingDetails();
      }
    });
  },

  watch: {
    isVisible () {
      if (this.isVisible) {
        this.refreshBuildingDetails();
      }
    },
    selectedBuildingId: {
      immediate: true,
      handler () {
        if (this.isVisible) {
          this.refreshBuildingDetails();
        }
      }
    },
    selectedBuildingDetailsStale: {
      immediate: false,
      handler () {
        if (this.isVisible && this.selectedBuildingDetailsStale) {
          this.refreshBuildingDetails();
        }
      }
    },
    buildingTypeInspectType () {
      this.clientState.interface.selectedInspectTabId = undefined;
    }
  },

  methods: {
    async refreshBuildingDetails (): Promise<void> {
      if (!this.selectedBuildingId || !this.isVisible) {
        return;
      }

      if (this.selectedBuildingId !== this.buildingDetails?.id) {
        this.buildingDetails = undefined;
        this.buildingDetailsConstructed = undefined;
        this.buildingDetailsUpgrading = undefined;
      }

      try {
        this.buildingDetailsPromise = this.$starpeaceClient.managers.building_manager.load_building_details(this.selectedBuildingId, true);
        this.buildingDetails = await this.buildingDetailsPromise;
        this.buildingDetailsConstructed = this.selectedBuildingConstructed;
        this.buildingDetailsUpgrading = this.selectedBuildingUpgrading;
        this.buildingDetailsPromise = undefined;
      }
      catch (err) {
        this.clientState.add_error_message('Failure loading building details, please try again', err);
        this.buildingDetailsPromise = undefined;
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'
@import '~/assets/stylesheets/starpeace-inspect'

.inspect-container
  background-color: #000
  display: grid
  grid-column: start-left / end-render
  grid-row: start-inspect / end-inspect
  grid-template-columns: [start-preview] 10rem [end-preview start-details] auto [end-details]
  grid-template-rows: auto
  pointer-events: auto
  position: relative
  z-index: 1050

.inspect-preview
  border-right: 1px solid $sp-primary-bg
  grid-column: start-preview / end-preview
  grid-row: 1 / 2
  position: relative

#inspect-image-webgl-container
  left: 0
  position: absolute
  height: 100%
  top: 0
  width: 100%

</style>
