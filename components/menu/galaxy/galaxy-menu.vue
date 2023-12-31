<template lang='pug'>
#galaxy-container.card.is-starpeace.has-header(:oncontextmenu="'return ' + !$config.public.disableRightClick")
  .card-header
    .card-header-title {{ $translate('ui.menu.galaxy.header') }}
    .card-header-icon.card-close(@click.stop.prevent="client_state.menu.toggle_menu('galaxy')")
      font-awesome-icon(:icon="['fas', 'times']")

  .card-content.sp-menu-background.overall-container
    aside.sp-scrollbar
      template(v-if='loading_galaxy || loading_tycoons || !galaxyMetadata')
        img.loading-image.starpeace-logo.logo-loading

      template(v-else)
        .planet(v-for='planet in planets' :class="{'is-disabled': !planet.enabled}")
          .columns.is-vcentered
            .column.is-narrow.planet-image
              template(v-if='true')
                img.starpeace-logo.logo-loading
              template(v-else)
                img.starpeace-logo.logo-loading(:src="planet_animation_url(planet)" @load="$event.target.classList.remove('starpeace-logo', 'logo-loading')")

            .column.planet-item
              .planet-name {{planet.name}}
              .planet-population.planet-info-row
                span {{$translate('ui.menu.galaxy.details.population.label')}}:
                span.planet-value {{planet.population}}
              .planet-investments.planet-info-row
                span {{$translate('ui.menu.galaxy.details.investments.label')}}:
                span.planet-value
                  misc-money-text(:value='planet.investment_value')
              .planet-tycoons.planet-info-row
                span {{$translate('ui.menu.galaxy.details.corporations.label')}}:
                span.planet-value {{ planet.corporation_count }}
              .planet-online.planet-info-row
                span {{$translate('ui.menu.galaxy.details.online.label')}}:
                span.planet-value {{ planet.onlineCount }}

          .columns
            .column.is-5
              button.button.is-primary.is-fullwidth.is-outlined.workflow-action.visitor-action(
                :disabled='!galaxyMetadata.visitorIssueEnabled || !planet.enabled'
                @click.stop.prevent='select_visitor(planet)'
              ) {{$translate('identity.visitor')}} {{$translate('identity.visa')}}

            .column.is-7
              template(v-if='corporation_identifiers_by_planet_id[planet.id]')
                button.button.is-primary.is-fullwidth.workflow-action.corporation-action(
                  :disabled='!galaxyMetadata.tycoonIssueEnabled || !planet.enabled'
                  @click.stop.prevent='select_tycoon(planet)'
                )
                  .action-text {{ corporation_identifiers_by_planet_id[planet.id].name }}

              template(v-else)
                button.button.is-primary.is-fullwidth.is-outlined.workflow-action.corporation-action(
                  :disabled='!galaxyMetadata.tycoonIssueEnabled || !planet.enabled || !is_tycoon_in_galaxy'
                  @click.stop.prevent='select_tycoon(planet)'
                )
                  .action-text {{$translate('ui.menu.corporation.establish.action.establish')}}

          .disabled-overlay(v-show='!planet.enabled')
            .disabled-text {{$translate('ui.menu.galaxy.planet_not_available.label')}}

</template>

<script lang='ts'>
import _ from 'lodash';
import Galaxy from '~/plugins/starpeace-client/galaxy/galaxy';
import ClientState from '~/plugins/starpeace-client/state/client-state';

declare interface GalaxyMenuData {
  menu_visible: boolean;
  loading_galaxy: boolean;
  loading_tycoons: boolean;

  galaxy_metadata_by_id: Record<string, Galaxy>;
  corporation_identifiers_by_planet_id: Record<string, any>;
}

export default {
  props: {
    client_state: { type: ClientState, required: true },
    ajax_state: Object
  },

  data (): GalaxyMenuData {
    return {
      menu_visible: this.client_state.menu?.is_visible('galaxy') ?? false,

      loading_galaxy: false,
      loading_tycoons: false,
      galaxy_metadata_by_id: {},
      corporation_identifiers_by_planet_id: {}
    };
  },

  mounted () {
    this.client_state.menu?.subscribe_menu_listener(() => {
      this.menu_visible = this.client_state.menu?.is_visible('galaxy') ?? false;
    });
  },

  watch: {
    galaxy_id (new_value, old_value) { this.refresh_galaxy_metadata(); },
    tycoon_id (new_value, old_value) { this.refresh_tycoon_metadata(); },
    is_visible (new_value, old_value) {
      if (this.is_visible) {
        this.refresh_galaxy_metadata();
        this.refresh_tycoon_metadata();
      }
    }
  },

  computed: {
    is_visible (): boolean { return this.client_state.initialized && this.menu_visible; },

    galaxy_id (): string | undefined {
      return this.client_state.identity.galaxy_id ?? undefined;
    },
    galaxyMetadata (): Galaxy | undefined {
      return this.galaxy_id ? this.galaxy_metadata_by_id[this.galaxy_id] : undefined;
    },

    is_tycoon_in_galaxy (): boolean {
      return this.client_state.identity?.galaxy_visa_type === 'tycoon' && (this.tycoon_id?.length ?? 0) > 0;
    },
    tycoon_id (): string | undefined {
      return this.client_state.identity?.galaxy_tycoon_id ?? undefined;
    },

    planets (): Array<any> {
      return this.galaxyMetadata && this.is_visible ? _.sortBy(this.galaxyMetadata.planets ?? [], (planet) => planet.name) : [];
    },
    sorted_planet_chunks (): Array<Array<any>> {
      return _.chunk(this.planets, 3);
    }
  },


  methods: {
    planet_animation_url (planet: any) { return this.$starpeaceClient.managers.asset_manager.planet_animation_url(planet); },

    async refresh_galaxy_metadata () {
      if (!this.is_visible || this.loading_galaxy || !this.galaxy_id?.length) return;
      this.loading_galaxy = true;
      try {
        this.galaxy_metadata_by_id[this.galaxy_id] = await this.$starpeaceClient.managers.galaxy_manager.load_metadata(this.galaxy_id);
      }
      catch (err) {
        console.error(err);
      }
      finally {
        this.loading_galaxy = false;
      }
    },

    async refresh_tycoon_metadata () {
      if (!this.is_visible || this.loading_tycoons || !this.galaxy_id?.length || !this.tycoon_id?.length) return;
      this.loading_tycoons = true;
      try {
        this.corporation_identifiers_by_planet_id = _.keyBy(await this.$starpeaceClient.managers.corporation_manager.load_identifiers_by_tycoon(this.tycoon_id), 'planetId');
      }
      catch (err) {
        console.error(err);
      }
      finally {
        this.loading_tycoons = false;
      }
    },

    select_visitor (planet: any) {
      if (!this.galaxyMetadata?.visitorIssueEnabled || !planet.enabled) return;
      this.client_state.change_planet_id('visitor', planet.id);
      if (window?.document) window.document.title = `${planet.name} - STARPEACE`;
    },

    select_tycoon (planet: any) {
      if (!this.galaxyMetadata?.tycoonIssueEnabled || !planet.enabled || !this.is_tycoon_in_galaxy) return;
      this.client_state.change_planet_id('tycoon', planet.id);
      if (window?.document) window.document.title = `${planet.name} - STARPEACE`;
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

#galaxy-container
  grid-column: 1 / 4
  grid-row: start-render / end-render
  margin: 0
  max-width: 25rem
  overflow: hidden
  position: relative
  width: 100%
  z-index: 1100

  .overall-container
    height: calc(100% - 3.2rem)
    padding: 0
    position: relative

    .sp-scrollbar
      height: 100%
      overflow-x: hidden
      overflow-y: scroll

.loading-image
  background-size: 5rem
  height: 5rem
  left: calc(50% - 2.5rem)
  margin: 1rem 0
  position: absolute
  top: calc(25% - 2.5rem)
  width: 5rem

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

.planet
  background-color: opacify(lighten($sp-primary-bg, 1%), .3)
  border: 1px solid rgba(110, 161, 146, .2)
  margin-top: .25rem
  padding-bottom: .25rem
  position: relative

  > .columns
    margin: 0

  .planet-image
    padding-right: .4rem

    img
      background-size: 5rem
      height: 5rem
      width: 5rem

  .planet-item
    color: #fff
    font-size: .9rem
    justify-content: left
    padding-left: .4rem
    text-align: left

    .planet-info-row
      border-bottom: 1px solid darken($sp-primary, 10%)
      padding-bottom: .25rem
      margin-bottom: .25rem

    .planet-name
      font-size: 1.3rem
      font-weight: 1000
      margin-bottom: .25rem

    .planet-value
      margin-left: .5rem

</style>
