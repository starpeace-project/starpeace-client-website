<template lang='pug'>
#establish-corporation-container(:oncontextmenu="'return ' + !$config.public.disableRightClick")
  .modal-background
  .card.is-starpeace.has-header(v-if='is_visible')
    .card-header
      .card-header-title {{$translate('ui.menu.corporation.establish.header')}}
    .card-content.sp-menu-background
      .content
        p.intro
          | {{$translate('ui.menu.corporation.establish.planet.welcome')}}
          |
          span.planet-name {{planet_name}}
          | ,
          |
          | {{$translate('identity.tycoon')}}!
        p.info
          | {{$translate('ui.menu.corporation.establish.description')}}

        form.corporation-form
          .field.is-horizontal
            .field-body
              .field
                .control.is-expanded
                  input.input.is-large(type='text' v-model='corporation_name' :disabled='saving' :placeholder="$translate('ui.menu.corporation.establish.field.name')")

          .field.is-horizontal(v-show='error_code')
            .field-body
              .field
                .control.is-narrow
                  span.has-text-danger {{$translate(error_code_key)}}

    footer.card-footer
      .card-footer-item.level.is-mobile
        .level-left
          button.button.is-primary.is-medium.is-outlined(@click.stop.prevent='cancel') {{$translate('ui.menu.corporation.establish.action.cancel')}}
        .level-right
          button.button.is-primary.is-medium(@click.stop.prevent='establish' :disabled='!can_establish') {{$translate('ui.menu.corporation.establish.action.establish')}}

</template>

<script lang='ts'>
import _ from 'lodash';
import ClientState from '~/plugins/starpeace-client/state/client-state.coffee';

const ERROR_CODE_GENERAL = 'GENERAL';
const ERROR_CODE_INVALID_NAME = 'INVALID_NAME';
const ERROR_CODE_TYCOON_LIMIT = 'TYCOON_LIMIT';
const ERROR_CODE_NAME_CONFLICT = 'NAME_CONFLICT';
const ERROR_CODES = [ERROR_CODE_GENERAL, ERROR_CODE_INVALID_NAME, ERROR_CODE_TYCOON_LIMIT, ERROR_CODE_NAME_CONFLICT];

export default {
  props: {
    client_state: { type: ClientState, required: true }
  },

  data () {
    return {
      saving: false,
      error_code: null,

      corporation_name: ''
    };
  },

  computed: {
    is_visible (): boolean {
      return this.client_state.initialized && this.client_state.workflow_status === 'ready' && this.client_state.is_tycoon() && !(this.client_state.player.corporation_id?.length ?? 0);
    },
    can_establish () { return this.is_visible && !this.saving && _.trim(this.corporation_name).length >= 3; },

    error_code_key (): string {
      if (this.error_code === ERROR_CODE_GENERAL) return 'ui.menu.corporation.establish.error.general';
      if (this.error_code === ERROR_CODE_INVALID_NAME) return 'ui.menu.corporation.establish.error.name';
      if (this.error_code === ERROR_CODE_TYCOON_LIMIT) return 'ui.menu.corporation.establish.error.limit';
      if (this.error_code === ERROR_CODE_NAME_CONFLICT) return 'ui.menu.corporation.establish.error.conflict';
      return '';
    },

    planet_name () { return this.client_state.current_planet_metadata()?.name ?? ''; }
  },

  watch: {
    is_visible (new_value, old_value) {
      if (this.is_visible) {
        this.saving = false;
        this.error_code = null;
        this.corporation_name = '';
      }
    }
  },

  methods: {
    cancel () {
      this.client_state.reset_to_galaxy();
      if (window?.document) {
        window.document.title = "STARPEACE";
      }
    },

    async establish () {
      if (!this.can_establish) return;
      this.saving = true
      try {
        const corporation = await this.$starpeaceClient.managers.corporation_manager.create(_.trim(this.corporation_name));
        this.client_state.player.set_planet_corporation_id(corporation.id);
      }
      catch (err) {
        this.client_state.add_error_message('Failure establishing corporation, please try again', err);
        this.error_code = ERROR_CODES.indexOf(err?.response?.data?.code) >= 0 ? err?.response?.data?.code : ERROR_CODE_GENERAL;
        if (this.is_visible) {
          this.$forceUpdate();
        }
      }
      finally {
        this.saving = false;
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

#establish-corporation-container
  align-items: center
  display: flex
  grid-column: start-left / end-right
  grid-row: start-render / end-toolbar
  justify-content: center
  position: relative
  overflow: hidden
  z-index: 1500

  > .card
    background-color: $sp-dark-bg
    max-width: 50rem
    z-index: 1500

    .content
      color: $sp-primary

      .intro
        font-size: 1.3rem
        font-weight: bold

      .info
        font-size: 1.15rem

      .planet-name
        color: #fff

      .corporation-form
        margin-bottom: 1rem
        margin-top: 2rem

</style>
