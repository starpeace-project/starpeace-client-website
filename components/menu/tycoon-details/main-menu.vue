<template lang='pug'>
.card.has-header.is-starpeace.sp-menu
  .card-header
    .card-header-title {{translate('ui.menu.tycoon_details.header')}}
    .card-header-icon.card-close(@click.stop.prevent="client_state.menu.toggle_menu('tycoon')")
      font-awesome-icon(:icon="['fas', 'times']")

  .card-content.sp-menu-background.overall-container
    .tycoon-menu-panel
      template(v-if='tycoon && !loadingTycoon')
        .tycoon-name
          span.tycoon-icon
            font-awesome-icon(:icon="['fas', 'user-tie']")
          span.tycoon-label {{tycoon.name}}

        .sp-profile.profile-logo
          .profile-container
            .profile-image
              .profile-none
              .profile-mask

        .tabs.is-centered.is-small.is-toggle.sp-tabs.mode-toggle
          ul
            li(:class="{'is-active':mode=='CURRICULUM'}" @click.stop.prevent="mode='CURRICULUM'")
              a {{translate('ui.menu.tycoon_details.tab.curriculum')}}
            li(:class="{'is-active':mode=='BANK_ACCOUNT'}" @click.stop.prevent="mode='BANK_ACCOUNT'" v-show='is_self')
              a {{translate('ui.menu.tycoon_details.tab.bank_account')}}
            li(:class="{'is-active':mode=='PROFIT_LOSS'}" @click.stop.prevent="mode='PROFIT_LOSS'")
              a {{translate('ui.menu.tycoon_details.tab.profit_loss')}}
            li(:class="{'is-active':mode=='INITIAL_SUPPLIERS'}" @click.stop.prevent="mode='INITIAL_SUPPLIERS'" v-show='is_self')
              a {{translate('ui.menu.tycoon_details.tab.initial_suppliers')}}
            li(:class="{'is-active':mode=='COMPANIES'}" @click.stop.prevent="mode='COMPANIES'")
              a {{translate('ui.menu.tycoon_details.tab.companies')}}
            li(:class="{'is-active':mode=='STRATEGY'}" @click.stop.prevent="mode='STRATEGY'" v-show='is_self')
              a {{translate('ui.menu.tycoon_details.tab.strategy')}}

    .tycoon-tabs(v-if='has_tycoon')
      template(v-if='!tycoon || loadingTycoon')
        .sp-loading.is-flex.is-align-items-center.is-justify-content-center
            img.starpeace-logo

      template(v-else-if="mode=='CURRICULUM'")
        menu-tycoon-details-tab-curriculum(:managers='managers' :client-state='client_state' :tycoon-id='tycoon_id' :corporation-id='corporation_id')

      template(v-else-if="mode=='BANK_ACCOUNT'")
        menu-tycoon-details-tab-bank-account(:managers='managers' :client-state='client_state' :tycoon-id='tycoon_id' :corporation-id='corporation_id')

      template(v-else-if="mode=='PROFIT_LOSS'")

      template(v-else-if="mode=='INITIAL_SUPPLIERS'")
        menu-tycoon-details-tab-initial-suppliers(:managers='managers' :client-state='client_state' :tycoon-id='tycoon_id' :corporation-id='corporation_id')

      template(v-else-if="mode=='COMPANIES'")
        menu-tycoon-details-tab-companies(:managers='managers' :client-state='client_state' :tycoon-id='tycoon_id' :corporation-id='corporation_id')

      template(v-else-if="mode=='STRATEGY'")
        menu-tycoon-details-tab-strategy(:managers='managers' :client-state='client_state' :tycoon-id='tycoon_id' :corporation-id='corporation_id')

</template>

<script lang='coffee'>
import _ from 'lodash';

import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

export default
  props:
    managers: Object
    client_state: Object

  data: ->
    mode: 'CURRICULUM'
    loading: false
    loadingTycoon: false
    loadingSuppliers: false
    loadingStrategies: false

    suppliersByResourceTypeId: {}
    selectedSupplierResourceTypeId: null

    corporation_id: null

    allyMode: 'TYCOON'
    allyValue: ''
    embargoMode: 'TYCOON'
    embargoValue: ''

    strategies: []

    details_promise: null
    details: null

  computed:
    is_ready: -> @client_state.initialized && @client_state?.workflow_status == 'ready'
    is_visible: -> @is_ready && @client_state?.menu?.is_visible('tycoon')

    planet_id: -> if @is_visible then @client_state.player.planet_id else null
    tycoon_id: -> if @is_visible then @client_state.interface.selected_tycoon_id else null

    has_tycoon: -> @tycoon_id?.length
    is_self: -> @client_state.player.tycoon_id == @tycoon_id

    tycoon: -> if @is_visible && @has_tycoon then @client_state.core.tycoon_cache.metadata_for_id(@tycoon_id) else null

  watch:
    tycoon_id: (newValue, oldValue) ->
      if newValue != oldValue
        @reset_state() if oldValue
        @refresh_details()
    corporation_id: (newValue, oldValue) ->
      if newValue != oldValue
        @reset_state() if oldValue
        @refresh_details()
    is_visible: (newValue, oldValue) ->
      if newValue != oldValue
        @reset_state() unless @is_visible
        @refresh_details()
    mode: (newValue, oldValue) ->
      if newValue != oldValue
        @refresh_details()

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    reset_state: () ->
      @mode = 'CURRICULUM'

    refresh_details: ->
      return unless @is_visible

      if @tycoon_id?.length
        try
          @loadingTycoon = true
          await @managers.tycoon_manager.load_metadata_by_tycoon_id(@tycoon_id)

          identifiers = await @managers.corporation_manager.load_identifiers_by_tycoon(@tycoon_id)
          corporation_id = identifiers.find((i) => i.planetId == @planet_id)?.id
          await @managers.corporation_manager.load_by_corporation(corporation_id) if corporation_id?
          @corporation_id = corporation_id
        catch err
          @client_state.add_error_message('Failure loading tycoon details from server', err)
        finally
          @loadingTycoon = false

</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-menus'
@import '~/assets/stylesheets/starpeace-menus-tycoon-details'

.sp-menu
  grid-column: start-left / end-render
  grid-row: start-render / end-inspect

  > .card-content
    grid-template-columns: 15rem auto


.tycoon-menu-panel
  grid-column: 1 / 2
  grid-row: 1 / 2

.tycoon-tabs
  grid-column: 2 / 3
  grid-row: 1 / 2
  padding: .5rem 0 0 .5rem
  position: relative

.tycoon-name
  color: $sp-primary
  font-size: 1.25rem
  font-weight: bold
  padding: 1rem .5rem .5rem
  text-align: center

  .tycoon-label
    color: #fff
    margin-left: .5rem

.profile-logo
  padding: .5rem 2.5rem

.mode-toggle
  position: relative
  padding: .5rem

  ul
    flex-direction: column

  li
    width: 100%

  a
    border-radius: 0 !important
    letter-spacing: .1rem
    padding: .5rem
    text-transform: uppercase

</style>
