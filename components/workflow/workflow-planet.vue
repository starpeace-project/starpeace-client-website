<template lang='pug'>
.content.is-marginless

  .tile.is-ancestor(v-for='planet_chunk in sorted_planet_chunks')
    template(v-for='n in 3')
      template(v-if='planet_chunk.length < n')
        .tile.is-parent.planet.is-empty
          article.tile.is-child.planet-row

      template(v-else)
        .tile.is-parent.planet
          article.tile.is-child.planet-row
            .columns.is-vcentered
              .column.is-narrow.planet-image
                img.starpeace-logo.logo-loading(:src="planet_animation_url(planet_chunk[n - 1])" @load="$event.target.classList.remove('starpeace-logo', 'logo-loading')")

              .column.planet-item.info
                .planet-name {{planet_chunk[n - 1].name}}
                .planet-population.planet-info-row
                  span {{$translate('ui.menu.galaxy.details.population.label')}}:
                  span.planet-value {{planet_chunk[n - 1].population || 0}}
                .planet-investments.planet-info-row
                  span {{$translate('ui.menu.galaxy.details.investments.label')}}:
                  span.planet-value
                    misc-money-text(:value='planet_chunk[n - 1].investment_value')
                .planet-tycoons.planet-info-row
                  span {{$translate('ui.menu.galaxy.details.corporations.label')}}:
                  span.planet-value {{planet_chunk[n - 1].corporation_count || 0}}
                .planet-online.planet-info-row
                  span {{$translate('ui.menu.galaxy.details.online.label')}}:
                  span.planet-value {{planet_chunk[n - 1].online_count || 0}}

            .columns
              .column.is-5
                button.button.is-primary.is-fullwidth.is-outlined.workflow-action.visitor-action(@click.stop.prevent='select_visitor(planet_chunk[n - 1])' :disabled='!planet_chunk[n - 1].enabled || is_loading_corporation_identifiers') {{$translate('identity.visitor')}} {{$translate('identity.visa')}}
              .column.is-7
                template(v-if='corporations_by_planet_id[planet_chunk[n - 1].id]')
                  button.button.is-primary.is-fullwidth.workflow-action.corporation-action(@click.stop.prevent='select_tycoon(planet_chunk[n - 1])' :disabled='!planet_chunk[n - 1].enabled || is_loading_corporation_identifiers')
                    .action-text {{corporations_by_planet_id[planet_chunk[n - 1].id].name}}
                template(v-else)
                  button.button.is-primary.is-fullwidth.is-outlined.workflow-action.corporation-action(@click.stop.prevent='select_tycoon(planet_chunk[n - 1])' :disabled='!planet_chunk[n - 1].enabled || is_loading_corporation_identifiers || !tycoon_id?.length')
                    .action-text {{$translate('ui.menu.corporation.establish.action.establish')}}

          .disabled-overlay(v-if='is_loading_corporation_identifiers')
            .disabled-text {{$translate('ui.workflow.loading')}}

          .disabled-overlay(v-else-if='!planet_chunk[n - 1].enabled')
            .disabled-text {{$translate('ui.menu.galaxy.planet_not_available.label')}}

</template>

<script lang='ts'>
import _ from 'lodash';
import ClientState from '~/plugins/starpeace-client/state/client-state.coffee';

export default {
  props: {
    client_state: { type: ClientState, required: true }
  },

  data () {
    return {
      corporation_identifiers: null
    };
  },

  mounted () {
    this.client_state.core.corporation_cache.subscribe_corporation_metadata_listener(() => this.refresh_identities());
  },

  computed: {
    galaxy_id (): string { return this.client_state.identity.galaxy_id; },
    galaxy_metadata () { return this.galaxy_id && this.client_state.core.galaxy_cache.has_galaxy_metadata(this.galaxy_id) ? this.client_state.core.galaxy_cache.galaxy_metadata(this.galaxy_id) : null; },

    tycoon_id () { return this.client_state.identity?.galaxy_visa_type === 'tycoon' ? this.client_state.identity?.galaxy_tycoon_id : null; },

    is_loading_corporation_identifiers (): boolean { return this.tycoon_id?.length > 0 && !this.corporation_identifiers; },

    planets () { return this.galaxy_metadata ? _.sortBy(this.galaxy_metadata.planets ?? [], (planet) => planet.name) : []; },
    sorted_planet_chunks () { return _.chunk(this.planets, 3); },

    corporations_by_planet_id () { return this.corporation_identifiers ? _.keyBy(this.corporation_identifiers, 'planetId') : {}; }
  },

  watch: {
    tycoon_id: {
      immediate: true,
      handler () { this.refresh_identities(); }
    }
  },

  methods: {
    planet_animation_url (planet): string { return this.$starpeaceClient.managers.asset_manager.planet_animation_url(planet); },

    refresh_identities (): void {
      this.corporation_identifiers = this.tycoon_id?.length ? this.client_state.core.corporation_cache.identifiers_for_tycoon_id(this.tycoon_id) : [];
    },

    select_visitor (planet): void {
      if (!planet.enabled || this.is_loading_corporation_identifiers) return;

      this.client_state.player.set_planet_visa_type(planet.id, 'visitor');
      if (window?.document) window.document.title = `${planet.name} - STARPEACE`;
    },

    select_tycoon (planet): void {
      if (!planet.enabled || this.is_loading_corporation_identifiers || !this.tycoon_id?.length) return;

      this.client_state.player.set_planet_visa_type(planet.id, 'tycoon');
      if (window?.document) window.document.title = `${planet.name} - STARPEACE`;
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.workflow-action
  &.button
    min-width: 7rem

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

.tile
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
