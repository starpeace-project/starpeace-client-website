<template lang='pug'>
.card.is-starpeace
  .card-header
    .card-header-title Admin Dashboard
  .card-content.sp-menu-background.columns.is-marginless.is-paddingless
    .column.is-paddingless
      .columns.columns.is-marginless.is-paddingless
        .column.is-narrow
          .planet-container.is-flex.is-flex-direction-column(v-for='planet in planets')
            span.name.p-2 {{ planet.name }}
            span.p-2.is-flex.is-flex-direction-column
              div
                span.sp-kv-key ID:
                span.sp-kv-value {{ planet.id }}
              div
                span.sp-kv-key Name:
                span.sp-kv-value {{ planet.name }}
              div
                span.sp-kv-key Enabled:
                span.sp-kv-value {{ planet.enabled ? 'Yes' : 'No' }}
              div
                span.sp-kv-key Type:
                span.sp-kv-value {{ planet.planetType }}
              div
                span.sp-kv-key Width:
                span.sp-kv-value {{ planet.planetWidth }}
              div
                span.sp-kv-key Height:
                span.sp-kv-value {{ planet.planetHeight }}
              div
                span.sp-kv-key Map ID:
                span.sp-kv-value {{ planet.mapId }}
              div
                span.sp-kv-key Population:
                span.sp-kv-value {{ $format_number(planet.population) }}
              div
                span.sp-kv-key Investments:
                span.sp-kv-value {{ $format_money(planet.investmentValue) }}
              div
                span.sp-kv-key Corporations:
                span.sp-kv-value {{ planet.corporationCount }}
              div
                span.sp-kv-key Online:
                span.sp-kv-value {{ planet.onlineCount }}

        .column.is-narrow
          aside.menu.is-starpeace.planet-selection
            ul.menu-list
              li(v-for='planet in planets')
                a(:class="{'is-active': selectedPlanetById[planet.id]}" @click.stop.prevent='togglePlanet(planet.id)')
                  span {{ planet.name }}

        .column
          .event-log.sp-scrollbar

</template>

<script lang='ts'>
import _ from 'lodash';

import Galaxy from '~/plugins/starpeace-client/galaxy/galaxy';
import Planet from '~/plugins/starpeace-client/planet/planet';

declare interface DashboardData {
  selectedPlanetById: Record<string, boolean>;
}

export default {
  props: {
    tycoonById: { type: Object, require: false },
    galaxyMetadata: { type: Galaxy, require: false }
  },

  data (): DashboardData {
    return {
      selectedPlanetById: {}
    };
  },

  computed: {
    planets (): Array<Planet> {
      return _.orderBy(this.galaxyMetadata?.planets ?? [], ['name'], ['asc']);
    }
  },

  watch: {
    planets: {
      immediate: true,
      handler () {
        this.selectedPlanetById = Object.fromEntries(this.planets.map(p => [p.id, true]));
      }
    }
  },

  methods: {
    togglePlanet (planetId: string): void {
      this.selectedPlanetById[planetId] = !this.selectedPlanetById[planetId];
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
