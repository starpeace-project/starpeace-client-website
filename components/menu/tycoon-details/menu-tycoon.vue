<template lang='pug'>
.card.has-header.is-starpeace.sp-menu(v-show='visible')
  .card-header
    .card-header-title {{translate('ui.menu.tycoon_details.header')}}
    .card-header-icon.card-close(v-on:click.stop.prevent="client_state.menu.toggle_menu('tycoon')")
      font-awesome-icon(:icon="['fas', 'times']")

  .card-content.sp-menu-background.overall-container
    .tycoon-menu-panel
      .tycoon-name
        span.tycoon-icon
          font-awesome-icon(:icon="['fas', 'user-tie']")
        span.tycoon-label {{tycoon_id}}

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

    .tycoon-tabs
      template(v-if="mode=='CURRICULUM'")
        | CURRICULUM

      template(v-else-if="mode=='BANK_ACCOUNT'")
        | BANK_ACCOUNT

      template(v-else-if="mode=='PROFIT_LOSS'")
        | PROFIT_LOSS

      template(v-else-if="mode=='INITIAL_SUPPLIERS'")
        | INITIAL_SUPPLIERS

      template(v-else-if="mode=='COMPANIES'")
        | COMPANIES

      template(v-else-if="mode=='STRATEGY'")
        | STRATEGY

</template>

<script lang='coffee'>
export default
  props:
    managers: Object
    client_state: Object
    visible: Boolean

  data: ->
    mode: 'CURRICULUM'
    details_promise: null
    details: null

  computed:
    tycoon_id: -> @client_state.interface.selected_tycoon_id
    is_self: -> @client_state.player.tycoon_id == @tycoon_id

  watch:
    tycoon_id: ->
      @mode = 'CURRICULUM'
      @refresh_details()
    visible: -> @refresh_details()

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    refresh_details: ->
      @details = null
      return unless @tycoon_id?.length && @visible

      try
        #@details_promise = @managers.corporation_manager.load_by_corporation(@tycoon_id)
        @details_promise = null
      catch err
        @client_state.add_error_message('Failure loading tycoon details from server', err)
        @details_promise = null

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-menus'

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
  padding: .5rem

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
