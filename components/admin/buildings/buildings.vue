<template lang='pug'>
.card.is-starpeace
  .card-header
    .card-header-title Town Buildings
  .card-content.sp-menu-background.columns.is-marginless.is-paddingless
    .column.is-paddingless
      .columns.columns.is-marginless.is-paddingless
        .column.is-narrow
          aside.menu.is-starpeace.planet-selection
            ul.menu-list
              li(v-for='planet in planets')
                a(:class="{'is-active': planetId == planet.id}" @click.stop.prevent='togglePlanet(planet.id)')
                  span {{ planet.name }}

          aside.menu.is-starpeace.town-selection.mt-6
            ul.menu-list
              li(v-for='town in towns')
                a(:class="{'is-active': townId == town.id}" @click.stop.prevent='toggleTown(town.id)')
                  span {{ town.name }}

        .column
          table.table.is-fullwidth.is-starpeace
            thead
              tr.nowrap
                th ID
                th Name
                th Definition ID
                th Tycoon ID
                th Corporation ID
                th Company ID
                th.has-text-right X
                th.has-text-right Y
                th.has-text-right Level
                th Upgrading
                th.has-text-right Started At
                th.has-text-right Finished At
                th.has-text-right Condemned At
                th.has-text-centered
            tbody
              template(v-if='!buildings.length')
                tr
                  td.has-text-centered(colspan=4) None
              template(v-else)
                tr(v-for='building in buildings')
                  td {{ building.id }}
                  td
                    span.is-flex.is-flex-direction-row.is-align-items-center
                      span.is-flex-grow-1 {{ building.name }}
                      button.button.is-small.is-starpeace(:disabled="building.corporationId == 'IFEL'" @click.stop.prevent='') Rename
                  td {{ building.definitionId }}
                  td {{ building.tycoonId }}
                  td {{ building.corporationId }}
                  td {{ building.companyId }}
                  td.has-text-right {{ building.mapX }}
                  td.has-text-right {{ building.mapY }}
                  td.has-text-right {{ building.level }}
                  td {{ building.upgrading }}
                  td.has-text-right {{ building.constructionStartedAt?.toFormat('yyyy-MM-dd HH:mm') }}
                  td.has-text-right {{ building.constructionFinishedAt?.toFormat('yyyy-MM-dd HH:mm') }}
                  td.has-text-right {{ building.condemnedAt?.toFormat('yyyy-MM-dd HH:mm') }}
                  td.has-text-centered
                    button.button.is-small.is-starpeace(:disabled="building.corporationId == 'IFEL'" @click.stop.prevent='demolishBuilding(building.id)') Demolish

</template>

<script lang='ts'>
import _ from 'lodash';

import Building from '~/plugins/starpeace-client/building/building';
import Galaxy from '~/plugins/starpeace-client/galaxy/galaxy';
import Planet from '~/plugins/starpeace-client/planet/planet';
import Town from '~/plugins/starpeace-client/planet/town';

declare interface AdminBuildingsData {
  planetId: string | undefined;
  townId: string | undefined;

  townById: Record<string, Town>;
  buildingById: Record<string, Building>;
}

export default {
  props: {
    tycoonById: { type: Object, require: false },
    galaxyMetadata: { type: Galaxy, require: false }
  },

  data (): AdminBuildingsData {
    return {
      planetId: undefined,
      townId: undefined,

      townById: {},
      buildingById: {}
    };
  },

  computed: {
    planets (): Array<Planet> {
      return _.orderBy(this.galaxyMetadata?.planets ?? [], ['name'], ['asc']);
    },

    towns (): Array<Town> {
      return _.orderBy(Object.values(this.townById), ['name'], ['asc']);
    },
    buildings (): Array<Building> {
      return _.orderBy(Object.values(this.buildingById), ['name', 'definitionId'], ['asc']);
    }
  },

  watch: {
    planets: {
      immediate: true,
      handler () {
        this.planetId = this.planets.length > 0 ? this.planets[0].id : undefined;
        this.townId = undefined;
      }
    },
    planetId: {
      immediate: true,
      handler () {
        this.refreshTowns();
      }
    },
    townId: {
      immediate: true,
      handler () {
        this.refreshBuildings();
      }
    }
  },

  methods: {
    togglePlanet (planetId: string): void {
      this.planetId = planetId;
    },
    toggleTown (townId: string): void {
      this.townId = townId;
    },

    async refreshTowns (): Promise<void> {
      try {
        this.townById = {};
        if (this.planetId) {
          this.$starpeaceClient.client_state.player.planet_id = this.planetId;
          this.townById = Object.fromEntries((await this.$starpeaceClient.api.towns_for_planet()).map(t => [t.id, t]));

          if (this.towns.length > 0) {
            this.townId = this.towns[0].id;
          }
        }
      }
      catch (err) {
        console.error(err);
      }
    },

    async refreshBuildings (): Promise<void> {
      try {
        this.buildingById = {};
        if (this.townId) {
          this.$starpeaceClient.client_state.player.planet_id = this.planetId;
          this.buildingById = Object.fromEntries((await this.$starpeaceClient.api.buildings_for_town(this.townId)).map(b => [b.id, b]));
        }
      }
      catch (err) {
        console.error(err);
      }
    },

    async demolishBuilding (buildingId: string): Promise<void> {
      try {
        if (!!buildingId && !!this.buildingById[buildingId] && this.buildingById[buildingId].corporationId !== 'IFEL') {
          this.$starpeaceClient.client_state.player.planet_id = this.planetId;
          await this.$starpeaceClient.api.demolish_building(buildingId);
          delete this.buildingById[buildingId];
        }
      }
      catch (err) {
        console.error(err);
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace'
@import '~/assets/stylesheets/starpeace-variables'

.button
  letter-spacing: 0.1rem
  text-transform: uppercase

.planet-selection
  border: 1px solid $sp-light-bg
  min-width: 10rem


</style>
