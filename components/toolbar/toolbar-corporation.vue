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
    p.planet-date {{current_date}}

  .level-item.company-container
    .company-panel(v-for='company in companies', :class="is_selected(company.id) ? 'is-selected' : ''", v-on:click.stop.prevent="select_company(company.id)")
      .company-name-row
        span.company-icon-wrapper
          company-seal-icon.company-seal(:seal_id="client_state.seal_for_company_id(company.id)")
        span.company-name {{client_state.name_for_company_id(company.id)}}
      .company-building-count
        font-awesome-icon(:icon="['far', 'building']")
        span.count {{building_count_for_company_id(company.id)}}
      p.company-cashflow
        | (
        money-text(:value='company.cashflow')
        | /h)
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
    current_date: -> if @client_state?.planet?.current_date? then moment(@client_state?.planet?.current_date).format('MMM D, YYYY') else ''

    is_tycoon: -> @is_ready && @client_state?.is_tycoon()
    can_form_company: -> @is_tycoon && @client_state.player.corporation_id?.length
    companies: ->
      if @is_ready && @is_tycoon && @client_state?.corporation?.company_ids?.length
        _.map(_.sortBy(@client_state.corporation.company_ids, (id) => @client_state.name_for_company_id(id)), (id) => @client_state.core.company_cache.metadata_for_id(id))
      else
        []

    corporation_metadata: -> if @is_ready && @client_state.player.corporation_id?.length then @client_state.current_corporation_metadata() else null
    corporation_name: -> if @corporation_metadata? then @corporation_metadata.name else '[PENDING]'
    corporation_cash: -> if @is_ready && @corporation_metadata?.cash? then @corporation_metadata.cash else 0
    corporation_cashflow: -> if @is_ready && @corporation_metadata?.cashflow? then @corporation_metadata.cashflow else 0

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    building_count_for_company_id: (company_id) -> (@client_state.corporation.buildings_ids_by_company_id?[company_id] || []).length

    is_selected: (company_id) -> @client_state.player.company_id == company_id
    select_company: (company_id) -> @client_state.player.company_id = company_id
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
    min-width: 10rem
    padding: .5rem

    .company-icon-wrapper
      height: 1.2rem
      width: 1.2rem

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
