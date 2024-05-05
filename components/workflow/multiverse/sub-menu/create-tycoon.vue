<template lang='pug'>
dialog.create-tycoon-dialog.m-0.is-block
  .card.is-starpeace.has-header
    .card-header
      .card-header-title {{$translate('ui.workflow.universe.create_tycoon.label')}}
      .card-header-icon.card-close(@click.stop.prevent='closeMenu')
        font-awesome-icon(:icon="['fas', 'times']")

    .card-content.sp-menu-background
      form.tycoon-form(method='dialog' @submit.prevent='createTycoon')
        .p-4
          .field.is-horizontal
            .field-body
              .field
                .control.has-icons-left.is-expanded
                  input.input(type='text' ref='username' v-model='username' :disabled='saving' :placeholder="$translate('ui.workflow.universe.username.label')")
                  span.icon.is-small.is-left
                    font-awesome-icon(:icon="['fas', 'user-tie']")

          .field.is-horizontal.mt-1
            .field-body
              .field
                .control.has-icons-left.is-expanded
                  input.input(type='text' v-model='username' :placeholder="$translate('ui.workflow.universe.name.label')" disabled)
                  span.icon.is-small.is-left
                    font-awesome-icon(:icon="['fas', 'user-tie']")

          .field.is-horizontal.mt-1
            .field-body
              .field
                .control.has-icons-left.is-expanded
                  input.input(type='password' v-model='password' :disabled='saving' :placeholder="$translate('ui.workflow.universe.password.label')")
                  span.icon.is-small.is-left
                    font-awesome-icon(:icon="['fas', 'lock']")

          .field.is-horizontal.mt-1
            .field-body
              .field
                .control.has-icons-left.is-expanded
                  input.input(type='password' v-model='passwordConfirm' :disabled='saving' :placeholder="$translate('ui.workflow.universe.confirm_password.label')")
                  span.icon.is-small.is-left
                    font-awesome-icon(:icon="['fas', 'lock']")

          .field.is-horizontal.mt-2
            .field-body
              .field
                .control.remember-toggle
                  misc-toggle-option(:value='rememberRefreshToken' @toggle='rememberRefreshToken=!rememberRefreshToken' :disabled='saving')
                  span.toggle-label(@click.stop.prevent='rememberRefreshToken=!rememberRefreshToken') {{ $translate('ui.workflow.universe.remember_tycoon.label') }}

          .notification.is-danger.p-4(v-if='errorCodeKey')
            strong {{ $translate(errorCodeKey) }}

        .is-flex.galaxy-actions.mt-4
          button.button.is-medium.is-flex-grow-1(type='reset' :disabled='saving' @click.stop.prevent='closeMenu') {{ $translate('misc.action.cancel') }}
          button.button.is-medium.is-primary.is-flex-grow-1(type='submit' :disabled='!canCreate' @click.stop.prevent='createTycoon') {{ $translate('misc.action.create') }}

</template>

<script lang='ts'>
import type { AxiosError } from 'axios';
import _ from 'lodash';
import ClientState from '~/plugins/starpeace-client/state/client-state';

const ERROR_CODE_GENERAL = 'GENERAL';
const ERROR_CODE_INVALID_NAME = 'INVALID_NAME';
const ERROR_CODE_PASSWORD_MISMATCH = 'PASSWORD_MISMATCH';
const ERROR_CODE_USERNAME_CONFLICT = 'USERNAME_CONFLICT';
const ERROR_CODES = [ERROR_CODE_GENERAL, ERROR_CODE_INVALID_NAME, ERROR_CODE_PASSWORD_MISMATCH, ERROR_CODE_USERNAME_CONFLICT];

const MIN_USERNAME = 1; // TODO: raise to like 3+ in future
const MIN_PASSWORD = 1; // TODO: raise to like 3+ in future

declare interface SubMenuCreateTycoonData {
  saving: boolean;
  errorCode: string | undefined;

  username: string;
  password: string;
  passwordConfirm: string;
  rememberRefreshToken: boolean;
}

export default {
  props: {
    clientState: { type: ClientState, required: true }
  },

  data (): SubMenuCreateTycoonData {
    return {
      saving: false,
      errorCode: undefined,

      username: '',
      password: '',
      passwordConfirm: '',
      rememberRefreshToken: true
    };
  },

  computed: {
    errorCodeKey (): string | undefined {
      if (this.errorCode) {
        switch (this.errorCode) {
          case ERROR_CODE_INVALID_NAME: return 'ui.workflow.universe.error.username_invalid.label';
          case ERROR_CODE_PASSWORD_MISMATCH: return 'ui.workflow.universe.error.password_mismatch.label';
          case ERROR_CODE_USERNAME_CONFLICT: return 'ui.workflow.universe.error.username_conflict.label';
        }
        return 'ui.workflow.universe.error.general_problem.label';
      }
      return undefined;
    },

    creationBlocker (): string | undefined {
      if (this.saving) {
        return 'saving';
      }

      if (_.trim(this.username).length < MIN_USERNAME) {
        return 'username_too_short';
      }

      if (_.trim(this.password).length < MIN_PASSWORD || _.trim(this.passwordConfirm).length < MIN_PASSWORD) {
        return 'password_too_short';
      }

      if (_.trim(this.password) !== _.trim(this.passwordConfirm)) {
        return 'password_mismatch';
      }

      return undefined;
    },
    canCreate (): boolean {
      return !this.creationBlocker;
    }
  },

  mounted () {
    if (this.$refs.username) {
      (this.$refs.username as any).focus();
    }
  },

  methods: {
    closeMenu (): void {
      if (!this.saving && this.clientState?.interface) {
        this.clientState.interface.show_create_tycoon = false;
        this.clientState.interface.create_tycoon_galaxy_id = null;
      }
    },

    async createTycoon (): Promise<void> {
      const galaxyId = this.clientState?.interface?.create_tycoon_galaxy_id;
      if (!this.canCreate || !galaxyId) {
        return;
      }

      this.errorCode = undefined;
      this.saving = true;

      try {
        const tycoon = await this.$starpeaceClient.managers.galaxy_manager.create(galaxyId, this.username, _.trim(this.password), this.rememberRefreshToken);
        this.clientState.identity.set_visa(galaxyId, 'tycoon', tycoon);
        this.clientState.player.tycoon_id = tycoon.id;

        this.saving = false;
        this.closeMenu();
      }
      catch (err: AxiosError | any) {
        this.errorCode = ERROR_CODES.indexOf(err?.response?.data?.code) >= 0 ? err?.response?.data?.code : ERROR_CODE_GENERAL;
        this.saving = false;
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import 'bulma/sass/utilities'
@import '~/assets/stylesheets/starpeace-variables'

.create-tycoon-dialog
  position: fixed
  left: calc(50% - 20rem)
  width: 40rem
  min-height: 20rem
  top: calc(50% - 10rem - 3rem)
  z-index: 2000

  .card
    height: 100%

  .card-content
    height: calc(100% - 3.5rem)
    padding: 0

  .remember-toggle
    align-items: center
    display: flex

    .toggle-label
      cursor: pointer
      margin-left: .5rem

  .galaxy-actions
    height: 3rem

    .level-item
      margin: 0

</style>
