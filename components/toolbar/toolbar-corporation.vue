<template lang='pug'>
#footer-corporation-details.level.is-mobile
  .level-left.content.corporation-panel
    p.corporation-name
      template(v-if='is_tycoon')
        | {{corporation_name}}
      template(v-else-if='!is_tycoon')
        span.corporation-name-temp
          | [{{translate('identity.visitor')}} {{translate('identity.visa')}}]
    p.corporation-cash
      money-text(:value='corporation_cash')
    p.corporation-cashflow
      | (
      money-text(:value='corporation_cashflow')
      | /h)
    p.planet-date {{planet_date}}

  .level-item.company-container
    .company-panel(v-for='company in sorted_companies' :class="{ 'is-selected': is_selected(company.id) }" @click.stop.prevent="select_company(company.id)")
      .company-name-row
        span.company-icon-wrapper
          company-seal-icon.company-seal(:seal_id="client_state.seal_for_company_id(company.id)")
        span.company-name {{client_state.name_for_company_id(company.id)}}
      .company-building-count
        font-awesome-icon(:icon="['far', 'building']")
        span.count {{building_count_for_company_id(company.id)}}
      p.company-cashflow
        | (
        money-text(:value='company_cashflow(company.id)')
        | /h)

    template(v-if='can_form_company')
      .company-panel.form-company(:class="{'is-selected':is_form_company_visible, 'no-companies':!companies.length}" @click.stop.prevent='toggle_form_company_menu')
        .form-label {{translate('ui.menu.company.form.action.form')}}

</template>

<script lang='coffee'>
import moment from 'moment'

import MoneyText from '~/components/misc/money-text.vue'
import CompanySealIcon from '~/components/misc/company-seal-icon.vue'

export default
  props:
    client_state: Object
    managers: Object

  components:
    'money-text': MoneyText
    'company-seal-icon': CompanySealIcon

  computed:
    is_ready: -> @client_state?.workflow_status == 'ready'
    planet_date: -> if @client_state?.planet?.current_time? then moment(@client_state.planet.current_time).format('MMM D, YYYY') else ''

    is_tycoon: -> @is_ready && @client_state?.is_tycoon()
    can_form_company: -> @is_tycoon && @client_state.player.corporation_id?.length
    companies: ->
      return [] unless @is_ready && @is_tycoon && @client_state?.corporation?.company_ids?.length
      _.compact(_.map(@client_state.corporation.company_ids, (id) => @client_state.core.company_cache.metadata_for_id(id)))
    sorted_companies: -> _.orderBy(@companies, ['desc'], ['name'])

    corporation_metadata: -> if @is_ready && @client_state.player.corporation_id?.length then @client_state.current_corporation_metadata() else null
    corporation_name: -> if @corporation_metadata? then @corporation_metadata.name else '[PENDING]'
    corporation_cash: -> if @is_ready && @client_state.corporation.cash? then @client_state.corporation.cash else null
    corporation_cashflow: -> if @is_ready && @client_state.corporation?.cashflow? then @client_state.corporation.cashflow else null

    is_form_company_visible: () -> @client_state.initialized && !@client_state.session_expired_warning && @client_state?.workflow_status == 'ready' && @client_state?.menu?.is_visible('company_form')

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    company_cashflow: (company_id) -> if @is_ready && @client_state.corporation.cashflow_by_company_id[company_id]? then @client_state.corporation.cashflow_by_company_id[company_id] else null

    building_count_for_company_id: (company_id) -> (@client_state.corporation.buildings_ids_by_company_id?[company_id] || []).length

    is_selected: (company_id) -> @client_state.player.company_id == company_id
    select_company: (company_id) -> @client_state.player.company_id = company_id

    toggle_form_company_menu: () -> @client_state.menu.toggle_menu('company_form')
</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

#footer-corporation-details
  align-items: stretch
  max-height: 8rem

.corporation-panel
  align-items: start
  flex-direction: column
  margin-right: 1rem
  padding: .5rem
  padding-left: 1rem

  p
    margin: 0

  .corporation-name
    color: #fff

    .corporation-name-temp
      text-transform: uppercase

  .corporation-cash
    color: $sp-primary
    font-size: 1.5rem
    font-weight: 1000
    line-height: 1.25rem
    margin-top: .25rem

    .positive
      color: $sp-primary

  .corporation-cashflow
    color: $sp-primary
    padding-bottom: 0
    padding-top: .25rem

    .positive
      color: $sp-primary

  .planet-date
    color: lighten($sp-primary, 10%)
    padding-top: 0
    padding-bottom: 1rem

.company-container
  align-items: stretch
  justify-content: left
  margin-bottom: .5rem
  padding: .5rem

  .company-panel
    border: 1px solid $sp-primary-bg
    cursor: pointer
    margin-left: .5rem
    min-width: 8em
    padding: .5rem

    &.form-company
      align-items: center
      border: 1px solid darken($sp-primary-bg, 5%)
      color: darken($sp-primary, 15%)
      display: flex
      flex-direction: column
      font-size: 1.1rem
      justify-content: center
      letter-spacing: .1rem
      text-align: center
      text-transform: uppercase
      width: 8rem

      &.no-companies
        border: 1px solid lighten($sp-primary-bg, 5%)
        color: $sp-primary

      &:hover
        background-color: darken($sp-primary, 25%)
        border: 1px solid darken($sp-primary, 15%)
        color: lighten($sp-primary, 5%)

      &.is-selected,
      &:active
        background-color: darken($sp-primary, 20%)
        border: 1px solid darken($sp-primary, 5%)
        color: lighten($sp-primary, 10%)

    .company-icon-wrapper
      height: 1.2rem
      width: 1.2rem

    .company-seal
      color: $sp-primary

    .company-name
      color: $sp-primary
      margin-left: .5rem

    .company-building-count
      color: $sp-primary
      font-size: 1rem
      line-height: 1.05rem
      margin-top: .25rem

      .count
        font-size: 1.3rem
        margin-left: .5rem
        vertical-align: bottom

    .company-cashflow
      color: $sp-primary
      margin-top: .25rem

      .positive
        color: $sp-primary

    &:hover
      background-color: darken($sp-primary, 30%)
      border: 1px solid darken($sp-primary, 15%)

    &.is-selected,
    &:active
      background-color: darken($sp-primary, 20%)
      border: 1px solid darken($sp-primary, 5%)

      .company-seal
        color: #ddd

      .company-name
        color: #ddd

      .company-building-count
        color: #ddd

      .company-cashflow
        color: #ddd

        .positive
          color: #ddd

        .negative
          color: #ff4949
          font-weight: bold


</style>
