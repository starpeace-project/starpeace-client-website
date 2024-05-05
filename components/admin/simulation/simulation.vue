<template lang='pug'>
.card.is-starpeace
  .card-header
    .card-header-title Simulation
  .card-content.sp-menu-background.columns.m-0.p-0
    .column.p-0
      .columns.columns.m-0.p-0
        .column.is-narrow
          aside.menu.is-starpeace.planet-selection
            ul.menu-list
              li(v-for='planet in planets')
                a(:class="{'is-active': planetId == planet.id}" @click.stop.prevent='togglePlanet(planet.id)')
                  span {{ planet.name }}
          div.mt-5
            label.checkbox.is-inline-flex.is-flex-direction-horizontal
              input.mr-2(type='checkbox' v-model='autoRefresh' @change='setupRefreshFinances')
              | Auto-Refresh

        .column
          table.table.is-fullwidth.is-starpeace
            thead
              tr
                th Town ID
                th Cash
            tbody
              tr(v-for='town in towns')
                td {{ town.id }}
                td {{ $format_money(town.cash) }}

        .column
          table.table.is-fullwidth.is-starpeace
            thead
              tr
                th Corporation ID
                th Cash
                th Cashflow
            tbody
              tr(v-for='corporation in corporations')
                td {{ corporation.id }}
                td {{ $format_money(corporation.cash) }}
                td {{ $format_money(corporation.cashflow) }}

        .column
          table.table.is-fullwidth.is-starpeace
            thead
              tr
                th Company ID
                th Cashflow
            tbody
              tr(v-for='company in companies')
                td {{ company.id }}
                td {{ $format_money(company.cashflow) }}

        .column
          table.table.is-fullwidth.is-starpeace
            thead
              tr
                th Building ID
                th Cashflow
            tbody
              tr(v-for='building in buildings')
                td {{ building.id }}
                td {{ $format_money(building.cashflow) }}

</template>

<script lang='ts'>
import _ from 'lodash';

import Galaxy from '~/plugins/starpeace-client/galaxy/galaxy';
import Planet from '~/plugins/starpeace-client/planet/planet';

declare interface DashboardData {
  planetId: string | undefined;
  finances: PlanetFinances | undefined;

  autoRefresh: boolean;
  scheduledRefresh: Function | undefined;
}

export default {
  props: {
    tycoonById: { type: Object, require: false },
    galaxyMetadata: { type: Galaxy, require: false }
  },

  data (): DashboardData {
    return {
      planetId: undefined,
      finances: undefined,

      autoRefresh: true,
      scheduledRefresh: undefined
    };
  },

  computed: {
    planets (): Array<Planet> {
      return _.orderBy(this.galaxyMetadata?.planets ?? [], ['name'], ['asc']);
    },

    towns (): Array<TownFinance> {
      return this.finances?.towns ?? [];
    },
    corporations (): Array<CorporationFinance> {
      return this.finances?.corporations ?? [];
    },
    companies (): Array<CompanyFinance> {
      return this.finances?.companies ?? [];
    },
    buildings (): Array<BuildingFinance> {
      return this.finances?.buildings ?? [];
    }
  },

  mounted () {
    this.setupRefreshFinances();
  },
  unmounted () {
    if (this.scheduledRefresh) {
      clearTimeout(this.scheduledRefresh);
    }
  },

  watch: {
    planets: {
      immediate: true,
      handler () {
        this.planetId = this.planets.length ? this.planets[0].id : undefined;
      }
    },
    planetId: {
      immediate: true,
      handler () {
        this.refreshFinances();
      }
    }
  },

  methods: {
    togglePlanet (planetId: string): void {
      this.planetId = planetId;
    },

    setupRefreshFinances (): void {
      if (this.autoRefresh) {
        if (!this.scheduledRefresh) {
          this.scheduledRefresh = setInterval(() => this.refreshFinances(), 15000);
        }
      }
      else {
        if (this.scheduledRefresh) {
          clearTimeout(this.scheduledRefresh);
          this.scheduledRefresh = undefined;
        }
      }
    },

    async refreshFinances (): Promise<void> {
      try {
        if (this.planetId) {
          this.$starpeaceClient.client_state.player.planet_id = this.planetId;
          this.finances = await this.$starpeaceClient.api.financesForPlanet();
        }
        else {
          this.finances = undefined;
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

.planet-container
  border: 1px solid $sp-light-bg

  &:not(:first-child)
    margin-top: .5rem

  .name
    background-color: $sp-light-bg
    color: #FFF

.event-log
  background-color: $sp-dark-bg
  border: 1px solid $sp-light-bg
  color: $sp-primary
  height: 100%
  min-height: 20rem
  overflow-y: scroll

</style>
