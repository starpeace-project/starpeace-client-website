<template lang='pug'>
.create-tycoon-dialog
  .card.is-starpeace.has-header
    .card-header
      .card-header-title {{$translate('ui.workflow.universe.create_tycoon.label')}}
      .card-header-icon.card-close(v-on:click.stop.prevent="close_sub_menu")
        font-awesome-icon(:icon="['fas', 'times']")

    .card-content.sp-menu-background
      form.tycoon-form
        .field.is-horizontal
          .field-body
            .field
              .control.has-icons-left.is-expanded
                input.input(type='text' v-model='username' :disabled='saving' :placeholder="$translate('ui.workflow.universe.username.label')")
                span.icon.is-small.is-left
                  font-awesome-icon(:icon="['fas', 'user-tie']")

        .field.is-horizontal
          .field-body
            .field
              .control.has-icons-left.is-expanded
                input.input(type='text' v-model='username' :placeholder="$translate('ui.workflow.universe.name.label')" disabled)
                span.icon.is-small.is-left
                  font-awesome-icon(:icon="['fas', 'user-tie']")

        .field.is-horizontal
          .field-body
            .field
              .control.has-icons-left.is-expanded
                input.input(type='password' v-model='password' :disabled='saving' :placeholder="$translate('ui.workflow.universe.password.label')")
                span.icon.is-small.is-left
                  font-awesome-icon(:icon="['fas', 'lock']")

        .field.is-horizontal
          .field-body
            .field
              .control.has-icons-left.is-expanded
                input.input(type='password' v-model='password_confirm' :disabled='saving' :placeholder="$translate('ui.workflow.universe.confirm_password.label')")
                span.icon.is-small.is-left
                  font-awesome-icon(:icon="['fas', 'lock']")

        .field.is-horizontal
          .field-body
            .field
              .control.remember-toggle
                misc-toggle-option(:value='remember_me' @toggle="remember_me=!remember_me" :disabled='saving')
                span.toggle-label(@click.stop.prevent="remember_me=!remember_me") {{$translate('ui.workflow.universe.remember_tycoon.label')}}

        .field.is-horizontal(v-show='error_code')
          .field-body
            .field
              .control.is-narrow
                span.has-text-danger {{$translate(error_code_key)}}

      .level.is-mobile.galaxy-actions
        .level-item
          button.button.is-medium.is-fullwidth.is-starpeace.is-square(@click.stop.prevent="close_sub_menu") {{$translate('misc.action.cancel')}}
        .level-item
          button.button.is-medium.is-fullwidth.is-starpeace.is-square(@click.stop.prevent="create_tycoon" :disabled='!can_create') {{$translate('misc.action.create')}}
</template>

<script lang='ts'>
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
  error_code: string | null;

  username: string;
  password: string;
  password_confirm: string;
  remember_me: boolean;
}

export default {
  props: {
    client_state: { type: ClientState, required: true }
  },

  data (): SubMenuCreateTycoonData {
    return {
      saving: false,
      error_code: null,

      username: '',
      password: '',
      password_confirm: '',
      remember_me: true
    };
  },

  computed: {
    is_visible (): boolean { return this.client_state?.interface?.show_create_tycoon && this.client_state?.interface?.create_tycoon_galaxy_id; },

    error_code_key (): string {
      if (this.error_code === ERROR_CODE_GENERAL) return 'ui.workflow.universe.error.general_problem.label';
      if (this.error_code === ERROR_CODE_INVALID_NAME) return 'ui.workflow.universe.error.username_invalid.label';
      if (this.error_code === ERROR_CODE_PASSWORD_MISMATCH) return 'ui.workflow.universe.error.password_mismatch.label';
      if (this.error_code == ERROR_CODE_USERNAME_CONFLICT) return 'ui.workflow.universe.error.username_conflict.label';
      return '';
    },

    can_create (): boolean { return !this.saving && _.trim(this.username).length >= MIN_USERNAME && _.trim(this.password).length >= MIN_PASSWORD && _.trim(this.password_confirm).length >= MIN_PASSWORD; }
  },

  watch: {
    is_visible (new_value, old_value) {
      if (this.is_visible) {
        this.saving = false;
        this.error_code = null;
        this.username = '';
        this.password = '';
        this.password_confirm = '';
        this.remember_me = true;
      }
    }
  },

  methods: {
    close_sub_menu (): void {
      if (this.client_state?.interface) {
        this.client_state.interface.show_create_tycoon = false;
        this.client_state.interface.create_tycoon_galaxy_id = null;
      }
    },

    async create_tycoon (): Promise<void> {
      if (!this.can_create) return;

      if (this.password != this.password_confirm) {
        this.error_code = ERROR_CODE_PASSWORD_MISMATCH;
        return;
      }

      this.error_code = null;
      this.saving = true;
      const galaxy_id = this.client_state?.interface?.create_tycoon_galaxy_id;

      try {
        const tycoon = await this.$starpeaceClient.managers.galaxy_manager.create(galaxy_id, this.username, this.password, this.remember_me);
        this.client_state.identity.set_visa(galaxy_id, 'tycoon', tycoon);
        this.client_state.player.tycoon_id = tycoon.id;

        try {
          await this.$starpeaceClient.managers.galaxy_manager.load_metadata(galaxy_id);
        }
        finally {
          this.close_sub_menu();
        }
      }
      catch (err) {
        this.error_code = ERROR_CODES.indexOf(err?.data?.code) >= 0 ? err?.data?.code : ERROR_CODE_GENERAL;
        if (this.is_visible) this.$forceUpdate();
      }
      finally {
        this.saving = false;
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import 'bulma/sass/utilities/_all'
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

  .tycoon-form
    padding: 1rem

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
