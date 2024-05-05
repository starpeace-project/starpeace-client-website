<template lang='pug'>
dialog.is-relative.is-block.content.m-0
  template(v-if='isLoading')
    .is-flex.is-justify-content-center.p-2
      img.starpeace-logo.logo-loading

  template(v-else)
    form(method='dialog' @submit.prevent='selectMostRecentTycoon')
      .grid(v-for='chunk in planetChunks')
        template(v-for='n in 3')
          template(v-if='n > chunk.length')
            .cell.planet.is-empty
              article.box.planet-row

          template(v-else)
            workflow-planet-card(
              :client-state='clientState'
              :planet='chunk[n - 1]'
              :is-loading='isLoading'
              :main-planet='n === 1'
              :has-tycoon='!!tycoonId'
              :corporation-identifier='corporationIdentifierByPlanetId ? corporationIdentifierByPlanetId[chunk[n - 1].id] : undefined'
              @select-visitor='selectVisitor'
              @select-tycoon='selectTycoon'
            )
</template>

<script lang='ts'>
import _ from 'lodash';

import ClientState from '~/plugins/starpeace-client/state/client-state';
import type CorporationIdentifier from '~/plugins/starpeace-client/corporation/corporation-identifier';
import type Galaxy from '~/plugins/starpeace-client/galaxy/galaxy';
import type Planet from '~/plugins/starpeace-client/planet/planet';

interface PlanetsData {
  loading: boolean;
  galaxyMetadata: Galaxy | undefined;
  corporationIdentifierByPlanetId: Record<string, CorporationIdentifier> | undefined;
}

export default {
  props: {
    clientState: { type: ClientState, required: true }
  },

  data (): PlanetsData {
    return {
      loading: false,
      galaxyMetadata: undefined,
      corporationIdentifierByPlanetId: undefined
    };
  },

  mounted () {
    this.clientState.core.corporation_cache.subscribe_corporation_metadata_listener(() => this.refreshIdentities());
  },

  computed: {
    galaxyId (): string | undefined {
      return this.clientState.identity.galaxy_id ?? undefined;
    },

    tycoonId (): string | undefined {
      return this.clientState.identity?.galaxy_visa_type === 'tycoon' ? (this.clientState.identity?.galaxy_tycoon_id ?? undefined) : undefined;
    },
    hasTycoon (): boolean {
      return (this.tycoonId?.length ?? 0) > 0;
    },

    isLoading (): boolean {
      return this.loading || !this.galaxyMetadata || this.hasTycoon && !this.corporationIdentifierByPlanetId;
    },

    planets (): Array<Planet> {
      const byPlayedAt = _.orderBy(this.galaxyMetadata?.planets ?? [], ['lastPlayedAt'], ['asc']);
      if (byPlayedAt.length) {
        const mostRecent = byPlayedAt.splice(0, 1)[0];
        return [mostRecent, ..._.orderBy(byPlayedAt, ['name'], ['asc'])];
      }
      return [];
    },
    planetChunks (): Array<Array<Planet>> {
      return _.chunk(this.planets, 3);
    }
  },

  watch: {
    tycoonId: {
      immediate: true,
      handler () {
        this.refreshIdentities();
      }
    },

    galaxyId: {
      immediate: true,
      handler () {
        this.refreshGalaxyMetadata();
      }
    }
  },

  methods: {
    async refreshGalaxyMetadata () {
      this.galaxyMetadata = undefined;
      if (!this.galaxyId) {
        return;
      }

      try {
        this.loading = true;
        this.galaxyMetadata = await this.$starpeaceClient.managers.galaxy_manager.load_metadata(this.galaxyId);
      }
      catch (err) {
        console.error(err);
      }
      finally {
        this.loading = false;
      }
    },

    async refreshIdentities (): Promise<void> {
      this.corporationIdentifierByPlanetId = undefined;
      if (!this.tycoonId) {
        return;
      }

      try {
        this.loading = true;
        const identifiers = await this.$starpeaceClient.managers.corporation_manager.load_identifiers_by_tycoon(this.tycoonId);
        this.corporationIdentifierByPlanetId = _.keyBy(identifiers, 'planetId');
      }
      catch (err) {
        console.error(err);
        this.corporationIdentifierByPlanetId = {};
      }
      finally {
        this.loading = false;
      }
    },

    selectVisitor (planet: Planet): void {
      if (planet.enabled && !this.isLoading) {
        this.clientState.player.set_planet_visa_type(planet.id, 'visitor');

        if (window?.document) {
          window.document.title = `${planet.name} - STARPEACE`;
        }
      }
    },

    selectMostRecentTycoon (): void {
      if (this.planets.length) {
        this.selectTycoon(this.planets[0]);
      }
    },

    selectTycoon (planet: Planet): void {
      if (planet.enabled && !this.isLoading) {
        this.clientState.player.set_planet_visa_type(planet.id, 'tycoon');

        if (window?.document) {
          window.document.title = `${planet.name} - STARPEACE`;
        }
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.logo-loading
  background-size: 7.5rem
  height: 7.5rem
  width: 7.5rem

dialog
  background-color: transparent
  height: unset
  width: unset

.disabled-overlay
  background-color: #000
  border: 1px solid rgba(8, 59, 44, .8)
  cursor: not-allowed
  height: calc(100% + 2px)
  left: -1px
  opacity: .85
  position: absolute
  text-align: center
  top: -1px
  width: calc(100% + 2px)

  .disabled-text
    color: #ddd
    font-size: 1.25rem
    font-style: italic
    left: calc(50% - 10rem)
    position: absolute
    top: calc(50% - 1rem)
    width: 20rem

.cell
  &.planet
    background-color: opacify(lighten($sp-primary-bg, 1%), .3)
    border: 1px solid rgba(110, 161, 146, .2)
    margin: .25rem
    padding: 0
    position: relative

    &.is-empty
      opacity: 0

    .columns
      margin: 0

    .planet-row
      .logo-loading
        background-size: 7.5rem
        height: 7.5rem
        width: 7.5rem

      .planet-image
        padding-right: .4rem

        img
          background-size: 7.5rem
          height: 7.5rem
          width: 7.5rem

      .planet-item
        color: #fff
        padding-left: .4rem

        &.description
          padding-left: 1rem
          margin-right: 2rem
          max-width: 14rem

        .planet-info-row
          border-bottom: 1px solid darken($sp-primary, 10%)
          padding-bottom: .25rem
          margin-bottom: .25rem

        .planet-name
          font-size: 1.5rem
          font-weight: 1000
          margin-bottom: .25rem

        .planet-value
          margin-left: .5rem

  .action-text
    overflow: hidden
    text-overflow: ellipsis
    white-space: nowrap

</style>
