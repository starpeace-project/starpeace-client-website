<template lang='pug'>
dialog.galaxy-login-row.is-flex.is-align-items-center.p-2
  form.is-flex-grow-1(method='dialog' @submit.prevent='loginTycoon')
    .field.is-horizontal
      .field-body
        .field.is-grouped
          template(v-if='isAuthenticated')
            .control
              button.button.is-primary.is-outlined(type='reset' @click.stop.prevent='logoutTycoon') {{ $translate('ui.workflow.universe.signout.label') }}
            .control.is-expanded.has-text-white.is-size-6.ml-2
              | {{ $translate('ui.workflow.visa-type.return_greeting') }},
              |
              | {{ authenticatedUsername }}!
            .control
              button.button.is-primary(type='submit' ref='proceedAction' autofocus :disabled='!canProceedTycoon' @click.stop.prevent='proceedAsTycoon') Proceed

          template(v-else)
            .control
              button.button.is-primary.is-outlined(type='button' :disabled='!canCreateTycoon' @click.stop.prevent='toggleCreateTycoon') {{ $translate('misc.action.create') }}

            .control.has-icons-left.is-expanded
              input.input(type='text' autocomplete='username' ref='username' autofocus :placeholder="$translate('ui.workflow.universe.username.label')" v-model='username' :disabled='!!authorizing')
              span.icon.is-small.is-left
                font-awesome-icon(:icon="['fas', 'user-tie']")

            .control.has-icons-left.is-expanded
              input.input(type='password' autocomplete='current-password' :placeholder="$translate('ui.workflow.universe.password.label')" v-model='password' :disabled='!!authorizing')
              span.icon.is-small.is-left
                font-awesome-icon(:icon="['fas', 'lock']")

            .control
              misc-toggle-option(label-suffix='ui.workflow.universe.remember_tycoon.label' :value='rememberRefreshToken' :disabled='!!authorizing' @toggle='toggleRememberRefreshToken')

            .control
              button.button.is-primary(type='submit' :disabled='!canLoginTycoon' @click.stop.prevent='loginTycoon') {{ $translate('ui.workflow.universe.signin.label') }}

    .field.is-horizontal(v-if='errorCode')
      .field-body
        .field.is-grouped
          .control.is-narrow
            span.has-text-danger {{ $translate(errorCodeKey) }}

</template>

<script lang='ts'>
import _ from 'lodash';
import ClientState from '~/plugins/starpeace-client/state/client-state';
import GalaxyConfiguration from '~/plugins/starpeace-client/galaxy/galaxy-configuration';
import type { AxiosError } from 'axios';

const MIN_USERNAME = 1; // TODO: raise to like 3+ in future
const MIN_PASSWORD = 1; // TODO: raise to like 3+ in future

const ERROR_CODE_GENERAL = 'GENERAL';
const ERROR_CODE_INVALID = 'INVALID';
const ERROR_CODES = [ERROR_CODE_GENERAL, ERROR_CODE_INVALID];

declare interface WorkflowUniverseMultiverseData {
  authorizing: boolean;
  username: string;
  password: string;
  rememberRefreshToken: boolean;
  errorCode: string | undefined;
}

export default {
  props: {
    clientState: { type: ClientState, required: true },
    ajaxState: { type: Object, required: true },

    galaxy: { type: GalaxyConfiguration, required: true },
    galaxyInfo: { type: Object, required: true }
  },

  data (): WorkflowUniverseMultiverseData {
    return {
      authorizing: false,
      username: '',
      password: '',
      rememberRefreshToken: true,
      errorCode: undefined,
    };
  },

  computed: {
    isAuthenticated (): boolean {
      return !!this.galaxyInfo.authenticatedTycoon || this.hasRefreshTokenTycoon;
    },
    hasRefreshTokenTycoon (): boolean {
      return this.galaxy.id === this.clientState.options.authentication.galaxyId && !!this.clientState.options.authentication.galaxyUsername && !!this.clientState.options.authentication.galaxyToken;
    },
    authenticatedUsername (): string | undefined {
      return this.galaxyInfo.authenticatedTycoon?.username ?? (this.galaxy.id === this.clientState.options.authentication.galaxyId ? this.clientState.options.authentication.galaxyUsername : undefined);
    },

    hasTycoonCredentials (): boolean {
      return _.trim(this.username).length >= MIN_USERNAME && _.trim(this.password).length >= MIN_PASSWORD;
    },

    errorCodeKey () {
      if (this.errorCode === ERROR_CODE_GENERAL) {
        return 'ui.workflow.universe.error.signin_problem.label';
      }
      if (this.errorCode === ERROR_CODE_INVALID) {
        return 'ui.workflow.universe.error.signin_invalid.label';
      }
      return '';
    },

    canProceedTycoon (): boolean {
      return this.galaxyInfo?.tycoonIssueEnabled && this.isAuthenticated && !this.authorizing;
    },
    canLoginTycoon (): boolean {
      return this.hasTycoonCredentials && (this.galaxyInfo?.tycoonIssueEnabled ?? false) && !this.authorizing;
    },
    canCreateTycoon (): boolean {
      return this.galaxyInfo.tycoonCreateEnabled;
    }
  },

  mounted () {
    if (this.galaxy.id === 'browser-sandbox') {
      this.username = 'test';
      this.password = 'test';
    }
    if (this.$refs.username) {
      (this.$refs.username as any).focus();
    }
    else if (this.$refs.proceedAction) {
      (this.$refs.proceedAction as any).focus();
    }
  },

  methods: {
    toggleCreateTycoon (): void {
      if (!this.galaxyInfo?.tycoonCreateEnabled || this.clientState?.interface?.remove_galaxy_visible || this.clientState?.interface?.add_galaxy_visible || !this.clientState?.interface) {
        return;
      }

      this.clientState.interface.show_create_tycoon = true;
      this.clientState.interface.create_tycoon_galaxy_id = this.galaxy.id;
    },

    toggleRememberRefreshToken (): void {
      this.rememberRefreshToken = !this.rememberRefreshToken;
    },

    clearTycoonForm () {
      this.username = '';
      this.password = '';
      this.rememberRefreshToken = true;
      this.errorCode = undefined;
    },

    async loginTycoon (): Promise<any> {
      if (!this.canLoginTycoon) {
        return;
        // this.$emit('login-visitor', this.galaxy.id);
      }

      this.authorizing = true;
      try {
        const tycoon = await this.$starpeaceClient.managers.galaxy_manager.login(this.galaxy.id, this.username, this.password, this.rememberRefreshToken);
        this.clearTycoonForm();
        this.authorizing = false;
        this.clientState.identity.set_visa(this.galaxy.id, 'tycoon', tycoon);
        this.clientState.player.tycoon_id = tycoon.id;
      }
      catch (err: AxiosError | any) {
        this.authorizing = false;
        this.errorCode = ERROR_CODES.indexOf(err?.response?.data?.code) >= 0 ? err?.response?.data?.code : ERROR_CODE_GENERAL;
      }
    },

    async logoutTycoon (): Promise<any> {
      if (!this.isAuthenticated || this.authorizing) {
        return;
      }

      this.authorizing = true;
      try {
        await this.$starpeaceClient.managers.galaxy_manager.logout(this.galaxy.id);
        this.clientState.reset_full_state();
        this.clearTycoonForm();
        this.$emit('logout');
      }
      catch (err: AxiosError | any) {
        this.errorCode = ERROR_CODES.indexOf(err?.response?.data?.code) >= 0 ? err?.response?.data?.code : ERROR_CODE_GENERAL;
      }
      finally {
        this.authorizing = false;
      }
    },

    async proceedAsTycoon (): Promise<void> {
      if (!this.canProceedTycoon) {
        return;
      }

      const galaxy = this.clientState.core.galaxy_cache.metadataForGalaxyId(this.galaxy.id);
      if (this.galaxyInfo.authenticatedTycoon && galaxy?.tycoon) {
        this.clientState.identity.set_visa(this.galaxy.id, 'tycoon', galaxy.tycoon);
        this.clientState.player.tycoon_id = galaxy.tycoon.id;
      }
      else if (this.hasRefreshTokenTycoon && this.clientState.options.authentication.galaxyToken) {
        this.authorizing = true;
        try {
          const tycoon = await this.$starpeaceClient.managers.galaxy_manager.loginToken(this.galaxy.id, this.username, this.clientState.options.authentication.galaxyToken);
          this.clearTycoonForm();
          this.clientState.identity.set_visa(this.galaxy.id, 'tycoon', tycoon);
          this.clientState.player.tycoon_id = tycoon.id;
          this.authorizing = false;
        }
        catch (err: AxiosError | any) {
          this.errorCode = ERROR_CODES.indexOf(err?.response?.data?.code) >= 0 ? err?.response?.data?.code : ERROR_CODE_GENERAL;
          this.authorizing = false;
        }
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

dialog
  width: unset

.galaxy-login-row
  background-color: opacify(darken($sp-primary-bg, 5%), .3)
  border: 1px solid rgba(110, 161, 146, .2)
  color: $sp-primary
  position: relative

  .control
    display: flex
    align-items: center

  .checkbox
    align-items: flex-end
    display: flex

  input
    margin-right: .25rem

</style>
