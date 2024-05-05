<template lang='pug'>
.remove-galaxy-dialog.p-2
  .card.is-starpeace.has-header
    .card-header
      .card-header-title {{ $translate('ui.workflow.universe.galaxy.remove.label') }}
      .card-header-icon.card-close(@click.stop.prevent="closeMenu")
        font-awesome-icon(:icon="['fas', 'times']")

    .card-content.sp-menu-background
      .galaxies-container.sp-scrollbar
        .columns.is-vcentered.galaxy-row(v-for='galaxy,index in galaxyConfigurations')
          .column.is-1.has-text-centered
            span.select-galaxy-toggle(@click.stop.prevent="toggleGalaxyIndex(index)")
              font-awesome-icon(v-show="selected_indices.indexOf(index) >= 0" :icon="['fas', 'square']")
              font-awesome-icon(v-show="!(selected_indices.indexOf(index) >= 0)" :icon="['far', 'square']")
          .column.is-11
            .galaxy-name(@click.stop.prevent="toggleGalaxyIndex(index)") {{ nameByGalaxyId[galaxy.id] }}

      .galaxy-actions.is-flex
        button.button.is-medium.is-flex-grow-1(@click.stop.prevent="closeMenu") {{ $translate('misc.action.cancel') }}
        button.button.is-medium.is-flex-grow-1(@click.stop.prevent="removeSelected" :disabled='selected_indices.length == 0') {{ $translate('misc.action.remove') }}

</template>

<script lang='ts'>
import ClientState from '~/plugins/starpeace-client/state/client-state';
import Galaxy from '~/plugins/starpeace-client/galaxy/galaxy.js';
import GalaxyConfiguration from '~/plugins/starpeace-client/galaxy/galaxy-configuration';

declare interface SubMenuRemoveGalaxyData {
  selected_indices: Array<number>;
  galaxyConfigurations: Array<GalaxyConfiguration>;
}

export default {
  props: {
    clientState: { type: ClientState, required: true }
  },

  data (): SubMenuRemoveGalaxyData {
    return {
      selected_indices: [],
      galaxyConfigurations: []
    };
  },

  computed: {
    isVisible (): boolean {
      return this.clientState.interface.remove_galaxy_visible;
    },

    nameByGalaxyId (): Record<string, string> {
      return Object.fromEntries(this.galaxyConfigurations.map(g => [g.id, this.clientState.core.galaxy_cache.metadataForGalaxyId(g.id)?.name ?? `${g.host}:${g.port}`]));
    }
  },

  mounted () {
    this.galaxyConfigurations = this.clientState.options.galaxy.getGalaxies();

    this.clientState.options.subscribe_galaxies_listener(() => {
      this.galaxyConfigurations = this.clientState.options.galaxy.getGalaxies();
      this.selected_indices = [];
    });
    this.clientState.core.galaxy_cache.subscribe_configuration_listener(() => {
      if (this.isVisible) this.$forceUpdate();
    });
    this.clientState.core.galaxy_cache.subscribe_metadata_listener(() => {
      if (this.isVisible) this.$forceUpdate();
    });
  },

  watch: {
    isVisible () {
      if (this.isVisible) {
        this.galaxyConfigurations = this.clientState.options.galaxy.getGalaxies();
      }
      else {
        this.selected_indices = [];
      }
    }
  },

  methods: {
    toggleGalaxyIndex (index: number) {
      const array_index: number = this.selected_indices.indexOf(index);
      if (array_index >= 0) {
        this.selected_indices.splice(array_index, 1);
      }
      else {
        this.selected_indices.push(index);
      }
    },

    closeMenu () {
      this.clientState.interface.hide_remove_galaxy();
    },

    removeSelected () {
      if (!this.selected_indices.length) return;

      const galaxyIds: Array<string> = [];
      for (const index of this.selected_indices) {
        galaxyIds.push(this.galaxyConfigurations[index].id);
      }

      for (const id of galaxyIds) {
        this.clientState.core.galaxy_cache.removeGalaxy(id);
        this.clientState.options.galaxy.removeGalaxy(id);
      }

      this.galaxyConfigurations = this.clientState.options.galaxy.getGalaxies();
      this.selected_indices = [];
    }
  }
}
</script>

<style lang='sass' scoped>
@import 'bulma/sass/utilities'
@import '~/assets/stylesheets/starpeace-variables'

.remove-galaxy-dialog
  position: fixed
  left: calc(50% - 20rem)
  width: 40rem
  height: 30rem
  top: calc(50% - 15rem - 3rem)
  z-index: 2000

  .card
    height: 100%

  .card-content
    height: calc(100% - 3.5rem)
    padding: 0

  .galaxies-container
    height: calc(100% - 3rem)
    overflow-y: scroll

    > .columns
      margin: 0

      > .column
       padding: .5rem

  .select-galaxy-toggle
    cursor: pointer

  .galaxy-name
    font-size: 1.25rem
    cursor: pointer

  .galaxy-actions
    height: 3rem

    .level-item
      margin: 0

</style>
