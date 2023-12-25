<template lang='pug'>
.universe-multiverse-actions
  .galaxy-list.sp-scrollbar

    template(v-for='galaxy in galaxyConfigurations')
      .columns.is-vcentered.galaxy-row
        .column
          h3.galaxy-name(:class="{'is-smaller': infoByGalaxyId[galaxy.id].nameLong }")
            .galaxy-name-text {{ infoByGalaxyId[galaxy.id].name }}
        .column.is-narrow
          .content
            .galaxy-planets
              span.planet-label {{$translate('ui.menu.galaxy.details.planets.label')}}:
              span.planet-value {{ infoByGalaxyId[galaxy.id].planetCount }}
            .galaxy-online
              span.planet-label {{$translate('ui.menu.galaxy.details.online.label')}}:
              span.planet-value {{ infoByGalaxyId[galaxy.id].onlineCount }}

        .column.is-narrow.has-text-right.ml-6
          button.button.is-medium.is-starpeace.is-inverted.is-outlined(
            :disabled='!infoByGalaxyId[galaxy.id].visitorIssueEnabled'
            @click.stop.prevent="proceed_as_visitor(galaxy.id)"
          ) {{$translate('identity.visitor')}}
          button.button.is-medium.is-starpeace.is-inverted.ml-2(
            :class="{'is-outlined': tycoon_galaxy_id != galaxy.id}"
            :disabled='!infoByGalaxyId[galaxy.id].tycoonIssueEnabled'
            @click.stop.prevent="toggle_tycoon_galaxy(galaxy.id)"
          ) {{$translate('identity.tycoon')}}

        .galaxy-loading-modal(v-show='is_galaxy_loading(galaxy.id) || errorByGalaxyId[galaxy.id]')
          img.starpeace-logo(v-show='is_galaxy_loading(galaxy.id)')
          .galaxy-error-message(v-show='errorByGalaxyId[galaxy.id]')
            | {{$translate('misc.unable_to_connect.label')}}
            a(@click.stop.prevent='refresh_galaxy(galaxy.id)') {{$translate('misc.try_again.label')}}

      .columns.is-vcentered.galaxy-login-row(v-show="tycoon_galaxy_id && galaxy.id == tycoon_galaxy_id && !is_galaxy_loading(galaxy.id) && !errorByGalaxyId[galaxy.id]")
        .column.is-12
          form
            .field.is-horizontal
              .field-body
                .field.is-grouped
                  template(v-if='infoByGalaxyId[galaxy.id] && infoByGalaxyId[galaxy.id].authenticatedTycoon')
                    .control
                      button.button.is-starpeace.is-inverted.is-outlined(@click.stop.prevent="logout_tycoon(galaxy.id)") {{$translate('ui.workflow.universe.signout.label')}}
                    .control.is-expanded
                      | Signed in as {{ infoByGalaxyId[galaxy.id].authenticatedTycoon.username }}
                    .control
                      button.button.is-starpeace.is-inverted(@click.stop.prevent="proceed_as_tycoon(galaxy.id)") Proceed

                  template(v-else)
                    .control
                      button.button.is-starpeace.is-inverted.is-outlined(
                        @click.stop.prevent="toggle_create_tycoon(galaxy.id)"
                        :disabled='!infoByGalaxyId[galaxy.id].tycoonCreateEnabled'
                      ) {{$translate('misc.action.create')}}
                    .control.has-icons-left.is-expanded
                      input.input(type='text' autocomplete='username' :placeholder="$translate('ui.workflow.universe.username.label')" v-model='username' :disabled='!!authorizing')
                      span.icon.is-small.is-left
                        font-awesome-icon(:icon="['fas', 'user-tie']")
                    .control.has-icons-left.is-expanded
                      input.input(type='password' autocomplete='current-password' :placeholder="$translate('ui.workflow.universe.password.label')" v-model='password' :disabled='!!authorizing')
                      span.icon.is-small.is-left
                        font-awesome-icon(:icon="['fas', 'lock']")
                    .control
                      misc-toggle-option(:value='remember_me' @toggle="remember_me=!remember_me")
                      span.toggle-label(@click.stop.prevent="remember_me=!remember_me") {{ $translate('ui.workflow.universe.remember_tycoon.label') }}
                    .control
                      button.button.is-starpeace.is-inverted(
                        :disabled='!hasTycoonCredentials || !infoByGalaxyId[galaxy.id] || !infoByGalaxyId[galaxy.id].tycoonIssueEnabled'
                        @click.stop.prevent="login_tycoon(galaxy.id)"
                      ) {{$translate('ui.workflow.universe.signin.label')}}

            .field.is-horizontal(v-if='errorCode')
              .field-body
                .field.is-grouped
                  .control.is-narrow
                    span.has-text-danger {{ $translate(errorCodeKey) }}

  .level.galaxy-actions-level
    .level-left
      .level-item
        button.button.is-small.is-starpeace(@click.stop.prevent='toggle_remove_galaxy' :disabled='!galaxyConfigurations.length') {{ $translate('ui.workflow.universe.galaxy.remove.label') }}
    .level-right
      .level-item
        button.button.is-small.is-starpeace(@click.stop.prevent='toggle_add_galaxy') {{$translate('ui.workflow.universe.galaxy.add.label')}}

</template>

<script lang='ts'>
import _ from 'lodash';
import ClientState from '~/plugins/starpeace-client/state/client-state';
import Galaxy from '~/plugins/starpeace-client/galaxy/galaxy.js';
import GalaxyConfiguration from '~/plugins/starpeace-client/galaxy/galaxy-configuration';

const MIN_USERNAME = 1; // TODO: raise to like 3+ in future
const MIN_PASSWORD = 1; // TODO: raise to like 3+ in future

const ERROR_CODE_GENERAL = 'GENERAL';
const ERROR_CODE_INVALID = 'INVALID';
const ERROR_CODES = [ERROR_CODE_GENERAL, ERROR_CODE_INVALID];

declare interface WorkflowUniverseMultiverseData {
  galaxyConfigurations: Array<GalaxyConfiguration>;
  errorByGalaxyId: Record<string, boolean>;

  authorizing: boolean;
  username: string;
  password: string;
  remember_me: boolean;
  errorCode: string | null;

  tycoon_galaxy_id: string | null;
}

export default {
  props: {
    client_state: { type: ClientState, required: true },
    ajax_state: { type: Object, required: true }
  },

  data (): WorkflowUniverseMultiverseData {
    return {
      galaxyConfigurations: [],
      errorByGalaxyId: {},

      authorizing: false,
      username: '',
      password: '',
      remember_me: true,
      errorCode: null,

      tycoon_galaxy_id: null
    };
  },

  mounted () {
    this.galaxyConfigurations = this.client_state.options.galaxy.getGalaxies();

    this.client_state.options.subscribe_galaxies_listener(() => {
      this.galaxyConfigurations = this.client_state.options.galaxy.getGalaxies();
    });
    this.client_state.core.galaxy_cache.subscribe_configuration_listener(() => {
      if (this.isVisible) this.$forceUpdate();
    });
    this.client_state.core.galaxy_cache.subscribe_metadata_listener(() => {
      if (this.isVisible) this.$forceUpdate();
    });
  },

  computed: {
    isVisible (): boolean {
      return this.client_state.workflow_status === 'pending_universe';
    },

    hasTycoonCredentials () {
      return _.trim(this.username).length >= MIN_USERNAME && _.trim(this.password).length >= MIN_PASSWORD;
    },

    infoByGalaxyId (): Record<string, any> {
      return Object.fromEntries(this.galaxyConfigurations.map((g: GalaxyConfiguration) => {
        const galaxy = this.client_state.core.galaxy_cache.metadataForGalaxyId(g.id);
        const name = galaxy?.name ?? `${g.host}:${g.port}`;
        return [g.id, {
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
    },

    errorCodeKey () {
      if (this.errorCode === ERROR_CODE_GENERAL) return 'ui.workflow.universe.error.signin_problem.label';
      if (this.errorCode === ERROR_CODE_INVALID) return 'ui.workflow.universe.error.signin_invalid.label';
      return '';
    }
  },

  watch: {
    isVisible () {
      if (this.isVisible) {
        this.galaxyConfigurations = this.client_state.options.galaxy.getGalaxies();
        this.refresh_galaxies();
      }
    },

    tycoon_galaxy_id (new_value, old_value) {
      this.clear_tycoon_credentials();

      if (new_value == 'browser-sandbox') {
        this.username = 'test';
        this.password = 'test';
      }
    },

    galaxyConfigurations () {
      this.refresh_galaxies();
    }
  },

  methods: {
    is_galaxy_loading (galaxy_id: string): boolean {
      return this.ajax_state.is_locked('galaxy_metadata', galaxy_id);
    },

    async refresh_galaxies () {
      const pending_galaxies = _.reject(this.galaxyConfigurations, (galaxy) => !!this.client_state.core.galaxy_cache.metadataForGalaxyId(galaxy.id) || this.is_galaxy_loading(galaxy.id));
      await Promise.all(pending_galaxies.map((galaxy) => new Promise<void>((done, _error) => {
        if (this.errorByGalaxyId[galaxy.id]) {
          this.errorByGalaxyId[galaxy.id] = false;
        }
        this.$starpeaceClient.managers.galaxy_manager.load_metadata(galaxy.id)
          .then((metadata: Galaxy) => {
            if (galaxy.id !== metadata.id) {
              this.client_state.options.galaxy.change_galaxy_id(galaxy.id, metadata.id);
              this.client_state.core.galaxy_cache.change_galaxy_id(galaxy.id, metadata.id);
            }
          })
          .catch((e: Error) => {
            console.error(e);
            this.errorByGalaxyId[galaxy.id] = true;
            done();
          });
      })))
    },

    async refresh_galaxy (galaxy_id: string) {
      if (this.is_galaxy_loading(galaxy_id)) return;
      if (this.errorByGalaxyId[galaxy_id]) this.errorByGalaxyId[galaxy_id] = false;

      try {
        await this.$starpeaceClient.managers.galaxy_manager.load_metadata(galaxy_id);
      }
      catch (err) {
        this.errorByGalaxyId[galaxy_id] = true
      }
      finally {
        if (this.isVisible) {
          this.$forceUpdate();
        }
      }
    },


    toggle_remove_galaxy () {
      if (!this.galaxyConfigurations.length) return;
      if (this.client_state.interface.add_galaxy_visible || this.client_state.interface.show_create_tycoon) return;
      this.client_state.interface.show_remove_galaxy();
    },

    toggle_add_galaxy () {
      if (this.client_state.interface.remove_galaxy_visible || this.client_state.interface.show_create_tycoon) return;
      this.client_state.interface.show_add_galaxy();
    },

    toggle_tycoon_galaxy (galaxyId: string) {
      if (this.client_state?.interface?.remove_galaxy_visible || this.client_state?.interface?.add_galaxy_visible || this.client_state?.interface?.show_create_tycoon) return;
      this.tycoon_galaxy_id = this.tycoon_galaxy_id === galaxyId ? null : galaxyId;
    },

    toggle_create_tycoon (galaxyId: string) {
      if (!this.infoByGalaxyId[galaxyId]?.tycoonCreateEnabled || this.client_state?.interface?.remove_galaxy_visible || this.client_state?.interface?.add_galaxy_visible) return;
      if (this.client_state?.interface) {
        this.client_state.interface.show_create_tycoon = true;
        this.client_state.interface.create_tycoon_galaxy_id = galaxyId;
      }
    },

    clear_tycoon_credentials () {
      this.username = '';
      this.password = '';
      this.remember_me = true;
      this.errorCode = null;
    },

    async login_tycoon (galaxyId: string) {
      if (!this.hasTycoonCredentials || !this.infoByGalaxyId[galaxyId]?.tycoonIssueEnabled) return;

      this.authorizing = true;
      try {
        const tycoon = await this.$starpeaceClient.managers.galaxy_manager.login(galaxyId, this.username, this.password, this.remember_me);
        this.clear_tycoon_credentials();
        this.authorizing = false;
        this.client_state.identity.set_visa(galaxyId, 'tycoon', tycoon);
        this.client_state.player.tycoon_id = tycoon.id;
        this.refresh_galaxy(galaxyId);
      }
      catch (err) {
        console.error(err);
        this.authorizing = false;
        this.errorCode = ERROR_CODES.indexOf(err?.data?.code) >= 0 ? err?.data?.code : ERROR_CODE_GENERAL;
        if (this.isVisible) this.$forceUpdate();
      }
    },

    async logout_tycoon (galaxy_id: string) {
      this.clear_tycoon_credentials();

      try {
        await this.$starpeaceClient.managers.galaxy_manager.logout(galaxy_id);
        this.client_state.reset_full_state();
        this.refresh_galaxies();
      }
      catch (err) {
        this.errorCode = ERROR_CODES.indexOf(err?.data?.code) >= 0 ? err?.data?.code : ERROR_CODE_GENERAL;
        if (this.isVisible) this.$forceUpdate();
      }
    },

    proceed_as_visitor (galaxyId: string) {
      if (!this.infoByGalaxyId[galaxyId].visitorIssueEnabled) return;
      this.client_state.identity.set_visa(galaxyId, 'visitor', null);
    },

    proceed_as_tycoon (galaxyId: string) {
      if (!this.infoByGalaxyId[galaxyId].tycoonIssueEnabled) return;
      const galaxy = this.client_state.core.galaxy_cache.metadataForGalaxyId(galaxyId);
      if (!galaxy?.tycoon) return;
      this.client_state.identity.set_visa(galaxyId, 'tycoon', galaxy.tycoon);
      this.client_state.player.tycoon_id = galaxy.tycoon.id;
    }
  }
}
</script>

<style lang='sass' scoped>
@import 'bulma/sass/utilities/_all'
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

  .galaxy-row
    background-color: opacify(lighten($sp-primary-bg, 1%), .3)
    border: 1px solid rgba(110, 161, 146, .2)
    color: #fff
    margin: 0
    padding: 0
    position: relative

    &:not(:first-child)
      margin-top: .25rem

    .galaxy-name-text
      overflow: hidden
      text-overflow: ellipsis
      white-space: nowrap

    .is-smaller
      font-size: 1.25rem

    .planet-label
      display: inline-block
      min-width: 4rem
      text-align: right

    .planet-value
      margin-left: .75rem

    .galaxy-loading-modal
      background-color: #000
      border: 1px solid #000
      height: calc(100% + 2px)
      left: -1px
      opacity: .85
      position: absolute
      top: -1px
      width: calc(100% + 2px)

      .starpeace-logo
        animation: spin-and-blink 1.5s linear infinite
        background-size: 2rem
        filter: $sp-filter-primary
        height: 2rem
        left: calc(50% - 1rem)
        opacity: .7
        position: absolute
        top: calc(50% - 1rem)
        width: 2rem

      .galaxy-error-message
        font-size: 1.1rem
        left: calc(50% - 20rem)
        position: absolute
        text-align: center
        top: calc(50% - 1rem)
        width: 40rem

        a
          margin-left: .5rem

  .galaxy-login-row
    background-color: opacify(darken($sp-primary-bg, 5%), .3)
    border: 1px solid rgba(110, 161, 146, .2)
    margin: 0
    padding: 0
    position: relative

    label
      color: #fff

    .control
      display: flex
      align-items: center

      .checkbox
        align-items: flex-end
        display: flex

        &:hover
          color: lighten($sp-primary-bg, 40%)

        input
          margin-right: .25rem

    .toggle-label
      cursor: pointer
      margin-left: .5rem

  .galaxy-actions-level
    margin-top: .5rem
    margin-bottom: 1rem

</style>
