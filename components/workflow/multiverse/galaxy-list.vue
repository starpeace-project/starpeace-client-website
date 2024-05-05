<template lang='pug'>
.universe-multiverse-actions
  .galaxy-list.sp-scrollbar

    template(v-for='galaxy in galaxyConfigurations')
      workflow-multiverse-galaxy-info-row(
        :client-state='clientState'
        :ajax-state='ajaxState'
        :galaxy='galaxy'
        :galaxy-info='infoByGalaxyId[galaxy.id]'
        :selected-galaxy-id='selectedGalaxyId'
        @select-galaxy='selectGalaxy'
        @refresh-galaxy='refreshGalaxy'
        @login-visitor='loginVisitor'
      )

      workflow-multiverse-galaxy-login-row(
        v-if='selectedGalaxyId && galaxy.id == selectedGalaxyId && !is_galaxy_loading(galaxy.id) && !errorByGalaxyId[galaxy.id]'
        :client-state='clientState'
        :ajax-state='ajaxState'
        :galaxy='galaxy'
        :galaxy-info='infoByGalaxyId[galaxy.id]'
        @logout='refreshGalaxies'
      )

  .is-flex.is-justify-content-space-between.mt-2.mb-3
    button.button.is-small(@click.stop.prevent='toggle_remove_galaxy' :disabled='!galaxyConfigurations.length') {{ $translate('ui.workflow.universe.galaxy.remove.label') }}
    button.button.is-small(@click.stop.prevent='toggle_add_galaxy') {{ $translate('ui.workflow.universe.galaxy.add.label') }}

</template>

<script lang='ts'>
import _ from 'lodash';

import ClientState from '~/plugins/starpeace-client/state/client-state';
import Galaxy from '~/plugins/starpeace-client/galaxy/galaxy.js';
import GalaxyConfiguration from '~/plugins/starpeace-client/galaxy/galaxy-configuration';

declare interface WorkflowUniverseMultiverseData {
  galaxyConfigurations: Array<GalaxyConfiguration>;
  errorByGalaxyId: Record<string, boolean>;

  selectedGalaxyId: string | undefined;
}

export default {
  props: {
    clientState: { type: ClientState, required: true },
    ajaxState: { type: Object, required: true }
  },

  data (): WorkflowUniverseMultiverseData {
    return {
      galaxyConfigurations: [],
      errorByGalaxyId: {},

      selectedGalaxyId: undefined
    };
  },

  mounted () {
    this.refreshGalaxyConfigurations();

    this.clientState.subscribe_workflow_status_listener(() => {
      if (this.clientState.workflow_status === 'pending_universe') {
        this.refreshGalaxies();
      }
    });
    this.clientState.options.subscribe_galaxies_listener(() => {
      this.refreshGalaxyConfigurations();
    });
    // this.clientState.core.galaxy_cache.subscribe_configuration_listener(() => {
    //   if (this.isVisible) this.$forceUpdate();
    // });
    // this.clientState.core.galaxy_cache.subscribe_metadata_listener(() => {
    //   if (this.isVisible) this.$forceUpdate();
    // });
  },

  computed: {
    infoByGalaxyId (): Record<string, any> {
      return Object.fromEntries(this.galaxyConfigurations.map((g: GalaxyConfiguration) => {
        const galaxy = this.clientState.core.galaxy_cache.metadataForGalaxyId(g.id);
        const name = galaxy?.name ?? `${g.host}:${g.port}`;
        return [g.id, {
          loading: galaxy ? this.ajaxState.is_locked('galaxy_metadata', galaxy.id) : true,
          hasError: galaxy ? !!this.errorByGalaxyId[galaxy.id] : false,
          nameLong: name.length > 40,
          name: name,
          planetCount: galaxy?.planetCount ?? 0,
          onlineCount: galaxy?.onlineCount ?? 0,
          visitorIssueEnabled: galaxy?.visitorIssueEnabled ?? false,
          tycoonIssueEnabled: galaxy?.tycoonIssueEnabled ?? false,
          tycoonCreateEnabled: galaxy?.tycoonCreateEnabled ?? false,
          authenticatedTycoon: galaxy?.tycoon
        }];
      }));
    }
  },

  // watch: {
  //   galaxyConfigurations () {
  //     this.refreshGalaxies();
  //   }
  // },

  methods: {
    is_galaxy_loading (galaxy_id: string): boolean {
      return this.ajaxState.is_locked('galaxy_metadata', galaxy_id);
    },

    refreshGalaxyConfigurations (): void {
      this.galaxyConfigurations = this.clientState.options.galaxy.getGalaxies();
      this.refreshGalaxies();

      if (this.clientState.options.authentication.galaxyId) {
        this.selectedGalaxyId = this.clientState.options.authentication.galaxyId;
      }
    },

    async refreshGalaxies (): Promise<void> {
      const metadatas: Array<PromiseSettledResult<Galaxy>> = await Promise.allSettled(this.galaxyConfigurations.map(g => this.$starpeaceClient.managers.galaxy_manager.load_metadata(g.id)));
      for (let index = 0; index < metadatas.length; index++) {
        const galaxyId = this.galaxyConfigurations[index].id;
        if (metadatas[index].status === 'rejected') {
          console.error((metadatas[index] as PromiseRejectedResult).reason);
          this.errorByGalaxyId[galaxyId] = true;
        }
        else {
          this.errorByGalaxyId[galaxyId] = false;
        }
      }
    },

    async refreshGalaxy (galaxy_id: string): Promise<void> {
      if (this.is_galaxy_loading(galaxy_id)) {
        return;
      }

      try {
        this.errorByGalaxyId[galaxy_id] = false;
        await this.$starpeaceClient.managers.galaxy_manager.load_metadata(galaxy_id);
      }
      catch (err) {
        this.errorByGalaxyId[galaxy_id] = true
      }
    },

    toggle_remove_galaxy (): void {
      if (!this.galaxyConfigurations.length || this.clientState.interface.add_galaxy_visible || this.clientState.interface.show_create_tycoon) {
        return;
      }
      this.clientState.interface.show_remove_galaxy();
    },

    toggle_add_galaxy () {
      if (this.clientState.interface.remove_galaxy_visible || this.clientState.interface.show_create_tycoon) {
        return;
      }
      this.clientState.interface.show_add_galaxy();
    },

    selectGalaxy (galaxyId: string): void {
      this.selectedGalaxyId = this.selectedGalaxyId === galaxyId ? undefined : galaxyId;
    },

    loginVisitor (galaxyId: string): void {
      this.clientState.identity.set_visa(galaxyId, 'visitor', undefined);
    }
  }
}
</script>

<style lang='sass' scoped>
@import 'bulma/sass/utilities'
@import '~/assets/stylesheets/starpeace-variables'

.universe-multiverse-actions
  position: relative

.galaxy-list
  background-color: darken($sp-primary-bg, 17.5%)
  border-left: 1px solid darken($sp-primary-bg, 15%)
  border-top: 1px solid darken($sp-primary-bg, 15%)
  border-right: 1px solid darken($sp-primary-bg, 5%)
  border-bottom: 1px solid darken($sp-primary-bg, 5%)
  min-height: 20rem
  padding: .25rem 0
  overflow-y: scroll
  overflow-x: hidden

</style>
