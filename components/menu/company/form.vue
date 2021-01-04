<template lang='pug'>
#form-company-container
  .card.is-starpeace.has-header
    .card-header
      .card-header-title {{translate('ui.menu.company.form.header')}}
      .card-header-icon.card-close(@click.stop.prevent="client_state.menu.toggle_menu('company_form')")
        font-awesome-icon(:icon="['fas', 'times']")

    .card-content.sp-menu-background
      .content.company-form
        .instructions.is-size-5 {{translate('ui.menu.company.form.instructions')}}

        .columns
          .column.is-narrow.seals-container
            template(v-for='seal in seals')
              .seal-option(:class="{'is-selected': seal_id == seal.id}" @click.stop.prevent='seal_id=seal.id')
                company-seal-icon.company-seal(:seal_id="seal.id")
                span.company-label {{seal.name_long}}

          .column
            template(v-for='seal in seals')
              .seal-information(v-show='seal_id == seal.id')
                .descriptions
                  p(v-for='description in seal.descriptions') {{translate(description)}}

                .columns
                  .column
                    template(v-if='seal.strengths')
                      .has-text-weight-semibold {{translate('ui.menu.company.form.info.strengths')}}
                      p {{translate(seal.strengths)}}
                    template(v-if='seal.weaknesses')
                      .has-text-weight-semibold {{translate('ui.menu.company.form.info.weaknesses')}}
                      p {{translate(seal.weaknesses)}}

                  .column
                    template(v-if='seal.pros')
                      .has-text-weight-semibold {{translate('ui.menu.company.form.info.pros')}}
                      p {{translate(seal.pros)}}
                    template(v-if='seal.cons')
                      .has-text-weight-semibold {{translate('ui.menu.company.form.info.cons')}}
                      p {{translate(seal.cons)}}

        .error-message(v-show='error_message')
          span.has-text-danger {{translate('ui.menu.company.form.error.general')}}

    footer.card-footer
      .card-footer-item.level.is-mobile
        .level-left
          a.button.is-primary.is-medium.is-outlined(@click.stop.prevent='cancel') {{translate('ui.menu.company.form.action.cancel')}}
        .level-item.company-name
          input.input.is-medium.is-primary(type='text' v-model='company_name' :disabled='saving' :placeholder="translate('ui.menu.company.form.field.name')")
        .level-right
          a.button.is-primary.is-medium(@click.stop.prevent='establish' :disabled='!can_establish') {{translate('ui.menu.company.form.action.form')}}

</template>

<script lang='coffee'>
import CompanySealIcon from '~/components/misc/company-seal-icon.vue'

export default
  components: {
    CompanySealIcon
  }

  props:
    managers: Object
    client_state: Object

  data: ->
    saving: false
    error_message: null

    company_name: ''
    seal_id: ''

  computed:
    is_visible: -> @client_state.initialized && !@client_state.session_expired_warning && @client_state?.workflow_status == 'ready' && @client_state?.menu?.is_visible('company_form')
    can_establish: -> @is_visible && !@saving && _.trim(@company_name).length && @seal_id?.length && _.find(@seals, (s) => s.id == @seal_id)?

    seals: -> if @is_visible then _.filter(_.values(@client_state.core.planet_library.company_seals_by_id), (c) -> c.playable) else []

  watch:
    is_visible: (new_value, old_value) ->
      if @is_visible
        @saving = false
        @error_message = null
        @company_name = ''
        @seal_id = _.first(@seals)?.id

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    cancel: () -> @client_state.menu.toggle_menu('company_form')

    establish: () ->
      return unless @can_establish
      @saving = true
      @managers.company_manager.create(_.trim(@company_name), @seal_id)
        .then (company) =>
          @client_state.player.set_company_id(company.id)
          @client_state.menu.toggle_menu('company_form')
          @saving = false

        .catch (e) =>
          console.error e
          @saving = false
          @error_message = true
          @$forceUpdate() if @is_visible

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

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
