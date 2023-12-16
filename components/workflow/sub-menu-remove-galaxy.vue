<template lang='pug'>
.remove-galaxy-dialog
  .card.is-starpeace.has-header
    .card-header
      .card-header-title {{$translate('ui.workflow.universe.galaxy.remove.label')}}
      .card-header-icon.card-close(@click.stop.prevent="close_sub_menu")
        font-awesome-icon(:icon="['fas', 'times']")

    .card-content.sp-menu-background
      .galaxies-container.sp-scrollbar
        .columns.is-vcentered.galaxy-row(v-for='galaxy,index in galaxies')
          .column.is-1.has-text-centered
            span.select-galaxy-toggle(@click.stop.prevent="toggle_galaxy_index(index)")
              font-awesome-icon(v-show="selected_indices.indexOf(index) >= 0" :icon="['fas', 'square']")
              font-awesome-icon(v-show="!(selected_indices.indexOf(index) >= 0)" :icon="['far', 'square']")
          .column.is-11
            .galaxy-name(@click.stop.prevent="toggle_galaxy_index(index)") {{galaxy_name(galaxy)}}

      .level.is-mobile.galaxy-actions
        .level-item
          button.button.is-medium.is-fullwidth.is-starpeace.is-square(@click.stop.prevent="close_sub_menu") {{$translate('misc.action.cancel')}}
        .level-item
          button.button.is-medium.is-fullwidth.is-starpeace.is-square(@click.stop.prevent="remove_galaxies" :disabled='selected_indices.length == 0') {{$translate('misc.action.remove')}}

</template>

<script lang='ts'>
import ClientState from '~/plugins/starpeace-client/state/client-state';
import Galaxy from '~/plugins/starpeace-client/galaxy/galaxy.js';

declare interface SubMenuRemoveGalaxyData {
  selected_indices: Array<number>;
    galaxies: Array<Galaxy>;
}

export default {
  props: {
    client_state: { type: ClientState, required: true }
  },

  data (): SubMenuRemoveGalaxyData {
    return {
      selected_indices: [],
      galaxies: []
    };
  },

  computed: {
    is_visible (): boolean {
      return this.client_state.interface.remove_galaxy_visible;
    }
  },

  mounted () {
    this.galaxies = this.client_state.options.get_galaxies();

    this.client_state.options.subscribe_galaxies_listener(() => {
      this.galaxies = this.client_state.options.get_galaxies();
      this.selected_indices = [];
    });
    this.client_state.core.galaxy_cache.subscribe_configuration_listener(() => {
      if (this.is_visible) this.$forceUpdate();
    });
    this.client_state.core.galaxy_cache.subscribe_metadata_listener(() => {
      if (this.is_visible) this.$forceUpdate();
    });
  },

  watch: {
    is_visible (new_value, old_value) {
      if (this.is_visible) {
        this.galaxies = this.client_state.options.get_galaxies();
      }
      else {
        this.selected_indices = [];
      }
    }
  },

  methods: {
    metadata_for_galaxy (galaxy_id: string) {
      return this.client_state.core.galaxy_cache.has_galaxy_metadata(galaxy_id) ? this.client_state.core.galaxy_cache.galaxy_metadata(galaxy_id) : null;
    },

    galaxy_name (galaxy: Galaxy) {
      const metadata = this.metadata_for_galaxy(galaxy.id);
      return metadata ? metadata.name : `${galaxy.api_url}:${galaxy.api_port}`;
    },

    toggle_galaxy_index (index: number) {
      const array_index: number = this.selected_indices.indexOf(index);
      if (array_index >= 0) {
        this.selected_indices.splice(array_index, 1);
      }
      else {
        this.selected_indices.push(index);
      }
    },

    close_sub_menu () {
      this.client_state.interface.hide_remove_galaxy();
    },

    remove_galaxies () {
      if (!this.selected_indices.length) return;

      const galaxies: Array<Galaxy> = [];
      for (const index of this.selected_indices) {
        galaxies.push(this.galaxies[index]);
      }

      for (const galaxy of galaxies) {
        this.client_state.core.galaxy_cache.remove_galaxy(galaxy.id);
        this.client_state.options.remove_galaxy(galaxy.id);
      }

      this.galaxies = this.client_state.options.get_galaxies();
      this.selected_indices = [];
    }
  }
}
</script>

<style lang='sass' scoped>
@import 'bulma/sass/utilities/_all'
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
    padding: 1rem

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
