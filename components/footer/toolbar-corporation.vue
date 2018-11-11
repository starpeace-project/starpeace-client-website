<template lang='haml'>
#footer-corporation-details.level.is-mobile
  .level-left.content.corporation-panel
    %p.corporation-name {{corporation_name}}
    %p.corporation-cash
      %money-text{'v-bind:value':'corporation_cash'}
    %p.corporation-cashflow
      %span (
      %money-text{'v-bind:value':'corporation_cashflow'}
      %span \/h)
    %p.planet-date {{current_date}}
  .level-item.company-container
    .company-panel{'v-for':'company in companies', 'v-bind:class':"is_selected(company.id) ? 'is-selected' : ''", 'v-on:click.stop.prevent':"select_company(company.id)"}
      .company-name-row
        %company-seal-icon.company-seal{'v-bind:seal_id':"seal_for_company_id(company.id)"}
        %span.company-name {{name_for_company_id(company.id)}}
      .company-building-count
        %font-awesome-icon{':icon':"['far', 'building']"}
        %span.count {{building_count_for_company_id(company.id)}}
      %p.company-cashflow
        %span (
        %money-text{'v-bind:value':'company.cashflow'}
        %span \/h)
</template>

<script lang='coffee'>
import moment from 'moment'

import MoneyText from '~/components/misc/money-text.vue'
import CompanySealIcon from '~/components/misc/company-seal-icon.vue'

export default
  props:
    game_state: Object

  components:
    'money-text': MoneyText
    'company-seal-icon': CompanySealIcon

  computed:
    is_ready: -> @game_state?.initialized
    current_date: -> moment(@game_state?.current_date).format('MMM D, YYYY')

    can_form_company: -> @is_ready && @game_state?.session_state.state_counter && @game_state?.session_state.identity?.is_tycoon() && @game_state.session_state.corporation_id?.length
    companies: ->
      if @is_ready && @game_state?.session_state.state_counter && @game_state?.session_state.identity.is_tycoon() && @game_state?.session_state.corporation?
        _.sortBy(_.values(@game_state?.session_state.corporation.companies_by_id || {}), (company) => @name_for_company_id(company.id))
      else
        []

    corporation_name: ->
      if @is_ready && @game_state?.session_state.state_counter && @game_state?.session_state.identity.is_tycoon()
        if @game_state.session_state.corporation_id? then @game_state.name_for_corporation_id(@game_state.session_state.corporation_id) else '[PENDING]'
      else
        '[VISITOR VISA]'
    corporation_cash: -> if @is_ready then @game_state.session_state.corporation?.cash || 0 else 0
    corporation_cashflow: -> if @is_ready then @game_state.session_state.corporation?.cashflow || 0 else 0

  methods:
    seal_for_company_id: (company_id) -> @game_state.seal_for_company_id(company_id)
    name_for_company_id: (company_id) -> @game_state.name_for_company_id(company_id)
    building_count_for_company_id: (company_id) -> (@game_state.session_state.buildings_metadata_by_company_id?[company_id] || []).length

    is_selected: (company_id) -> @game_state.session_state.company_id == company_id
    select_company: (company_id) -> @game_state.session_state.company_id = company_id
</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

#footer-corporation-details
  align-items: stretch
  max-height: 8rem

.corporation-panel
  align-items: start
  flex-direction: column
  padding: .5rem
  padding-left: 1rem

  p
    margin: 0

  .corporation-name
    color: #fff

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
    min-width: 10rem
    padding: .5rem

    .company-seal
      color: $sp-primary

    .company-name
      color: $sp-primary
      margin-left: .25rem

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

    &.is-selected
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
