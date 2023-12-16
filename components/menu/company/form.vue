<template lang='pug'>
#form-company-container(:oncontextmenu="'return ' + !$config.public.disableRightClick")
  .card.is-starpeace.has-header
    .card-header
      .card-header-title {{$translate('ui.menu.company.form.header')}}
      .card-header-icon.card-close(@click.stop.prevent="client_state.menu.toggle_menu('company_form')")
        font-awesome-icon(:icon="['fas', 'times']")

    .card-content.sp-menu-background
      .content.company-form
        .instructions.is-size-5 {{$translate('ui.menu.company.form.instructions')}}

        .columns
          .column.is-narrow.seals-container
            template(v-for='seal in seals')
              .seal-option(:class="{'is-selected': seal_id == seal.id}" @click.stop.prevent='seal_id=seal.id')
                misc-company-seal-icon.company-seal(:seal_id="seal.id")
                span.company-label {{seal.nameLong}}

          .column
            template(v-for='seal in seals')
              .seal-information(v-show='seal_id == seal.id')
                .descriptions
                  p(v-for='description in seal.descriptions') {{$translate(description)}}

                .columns
                  .column
                    template(v-if='seal.strengths')
                      .has-text-weight-semibold {{$translate('ui.menu.company.form.info.strengths')}}
                      p {{$translate(seal.strengths)}}
                    template(v-if='seal.weaknesses')
                      .has-text-weight-semibold {{$translate('ui.menu.company.form.info.weaknesses')}}
                      p {{$translate(seal.weaknesses)}}

                  .column
                    template(v-if='seal.pros')
                      .has-text-weight-semibold {{$translate('ui.menu.company.form.info.pros')}}
                      p {{$translate(seal.pros)}}
                    template(v-if='seal.cons')
                      .has-text-weight-semibold {{$translate('ui.menu.company.form.info.cons')}}
                      p {{$translate(seal.cons)}}

        .error-message(v-show='error_code')
          span.has-text-danger {{$translate(error_code_key)}}

    footer.card-footer
      .card-footer-item.level.is-mobile
        .level-left
          button.button.is-primary.is-medium.is-outlined(@click.stop.prevent='cancel') {{$translate('ui.menu.company.form.action.cancel')}}
        .level-item.company-name
          input.input.is-medium.is-primary(type='text' v-model='company_name' :disabled='saving' :placeholder="$translate('ui.menu.company.form.field.name')")
        .level-right
          button.button.is-primary.is-medium(@click.stop.prevent='establish' :disabled='!can_establish') {{$translate('ui.menu.company.form.action.form')}}

</template>

<script lang='ts'>
import _ from 'lodash';
import ClientState from '~/plugins/starpeace-client/state/client-state';

const ERROR_CODE_GENERAL = 'GENERAL';
const ERROR_CODE_INVALID_NAME = 'INVALID_NAME';
const ERROR_CODE_INVALID_SEAL = 'INVALID_SEAL';
const ERROR_CODE_TYCOON_LIMIT = 'TYCOON_LIMIT';
const ERROR_CODE_NAME_CONFLICT = 'NAME_CONFLICT';
const ERROR_CODES = [ERROR_CODE_GENERAL, ERROR_CODE_INVALID_NAME, ERROR_CODE_INVALID_SEAL, ERROR_CODE_TYCOON_LIMIT, ERROR_CODE_NAME_CONFLICT];

export default {
  props: {
    client_state: { type: ClientState, required: true }
  },

  data () {
    return {
      saving: false,
      error_code: null,

      company_name: '',
      seal_id: ''
    };
  },

  computed: {
    is_visible (): boolean {
      return this.client_state.initialized && !this.client_state.session_expired_warning && this.client_state?.workflow_status === 'ready' && this.client_state?.menu?.is_visible('company_form');
    },
    can_establish (): boolean {
      return this.is_visible && !this.saving && _.trim(this.company_name).length >= 3 && this.seal_id?.length > 0 && !!_.find(this.seals, (s) => s.id == this.seal_id);
    },

    seals () { return this.is_visible ? _.filter(_.values(this.client_state.core.planet_library.company_seals_by_id), (c) => c.playable) : []; },

    error_code_key () {
      if (this.error_code === ERROR_CODE_GENERAL) return 'ui.menu.company.form.error.general';
      if (this.error_code === ERROR_CODE_INVALID_NAME) return 'ui.menu.company.form.error.name';
      if (this.error_code === ERROR_CODE_INVALID_SEAL) return 'ui.menu.company.form.error.seal';
      if (this.error_code === ERROR_CODE_TYCOON_LIMIT) return 'ui.menu.company.form.error.limit';
      if (this.error_code === ERROR_CODE_NAME_CONFLICT) return 'ui.menu.company.form.error.conflict';
      return '';
    }
  },

  watch: {
    is_visible (new_value, old_value) {
      if (this.is_visible) {
        this.saving = false;
        this.error_code = null;
        this.company_name = '';
        this.seal_id = _.first(this.seals)?.id;
      }
    }
  },

  methods: {
    cancel () { this.client_state.menu.toggle_menu('company_form'); },

    async establish () {
      if (!this.can_establish) return;
      this.saving = true;
      try {
        const company = await this.$starpeaceClient.managers.company_manager.create(_.trim(this.company_name), this.seal_id);
        this.client_state.player.set_company_id(company.id);
        this.client_state.menu.toggle_menu('company_form');
      }
      catch (err) {
        this.client_state.add_error_message('Failure establishing company, please try again', err);
        this.error_code = ERROR_CODES.indexOf(err?.response?.data?.code) >= 0 ? err?.response?.data?.code : ERROR_CODE_GENERAL;
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
@import '~/assets/stylesheets/starpeace-variables'

#form-company-container
  align-items: center
  display: flex
  grid-column-start: 1
  grid-column-end: 4
  grid-row-start: start-render
  grid-row-end: end-render
  justify-content: center
  position: relative
  overflow: hidden
  z-index: 1500

  > .card
    background-color: $sp-dark-bg
    max-width: 75rem
    z-index: 1500

    .content
      color: $sp-primary

.company-form
  margin-bottom: 1rem

  .instructions
    margin-bottom: 1rem

.seals-container
  display: inline-flex
  flex-direction: column

.seal-option
  border: 1px solid $sp-primary-bg
  cursor: pointer
  font-size: 1.3rem
  padding: .75rem .5rem

  &:hover
    background-color: darken($sp-primary, 25%)
    color: lighten($sp-primary, 5%)

  &.is-selected,
  &:active
    background-color: darken($sp-primary, 20%)
    color: lighten($sp-primary, 10%)

  &:not(:first-child)
    border-top: 0

  .company-label
    margin-left: .5rem

.seal-information
  .descriptions
    border-bottom: 1px solid darken($sp-primary-bg, 2.5%)
    padding-bottom: 1rem
    margin-bottom: 1rem

.company-name
  &.level-item
    margin-left: .75rem


</style>
