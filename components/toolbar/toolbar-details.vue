<template lang='pug'>
#toolbar-details.columns.is-marginless.is-paddingless(v-show='is_ready' v-cloak=true :oncontextmenu="'return ' + !$config.public.disableRightClick")
  .column.column-news-ticker {{ ticker_message }}
  .column.column-tycoon-details
    #corporation-details.level.is-mobile
      .level-left.content.corporation-panel
        p.corporation-name
          template(v-if='is_tycoon')
            | {{corporation_name}}
          template(v-else-if='!is_tycoon')
            span.corporation-name-temp
              | [{{$translate('identity.visitor')}} {{$translate('identity.visa')}}]
        p.corporation-cash
          misc-money-text(:value='corporation_cash')
        p.corporation-cashflow
          | (
          misc-money-text(:value='corporation_cashflow')
          | /h)
        p.planet-date {{planet_date}}

      .level-item.company-container
        .company-panel(v-for='company in sorted_companies' :class="{ 'is-selected': is_selected(company.id) }" @click.stop.prevent="select_company(company.id)")
          .company-name-row
            span.company-icon-wrapper
              misc-company-seal-icon.company-seal(:seal_id="client_state.seal_for_company_id(company.id)")
            span.company-name {{client_state.name_for_company_id(company.id)}}
          .company-building-count
            font-awesome-icon(:icon="['far', 'building']")
            span.count {{building_count_for_company_id(company.id)}}
          p.company-cashflow
            | (
            misc-money-text(:value='company_cashflow(company.id)')
            | /h)

        template(v-if='can_form_company')
          .company-panel.form-company(:class="{'is-selected':is_form_company_visible, 'no-companies':!companies.length}" @click.stop.prevent='toggle_form_company_menu')
            .form-label {{$translate('ui.menu.company.form.action.form')}}

</template>

<script lang='ts'>
import _ from 'lodash';
import ClientState from '~/plugins/starpeace-client/state/client-state.coffee';

export default {
  props: {
    ajax_state: Object,
    client_state: { type: ClientState, required: true }
  },

  computed: {
    is_ready () { return this.client_state.initialized && this.client_state?.workflow_status === 'ready'; },
    planet_date () { return this.client_state?.planet?.current_time ? this.client_state.planet.current_time.toFormat('MMM d, yyyy') : ''; },

    ticker_message () { return this.client_state?.interface?.event_ticker_message ?? ''; },

    is_tycoon () { return this.is_ready && this.client_state?.is_tycoon(); },
    can_form_company () { return this.is_tycoon && this.client_state.player.corporation_id?.length; },
    companies () {
      if (!this.is_ready || !this.is_tycoon || !this.client_state?.corporation?.company_ids?.length) return [];
      return _.compact(_.map(this.client_state.corporation.company_ids, (id) => this.client_state.core.company_cache.metadata_for_id(id)));
    },
    sorted_companies () { return _.orderBy(this.companies, ['name'], ['asc']); },

    corporation_metadata () { return this.is_ready && this.client_state.player.corporation_id?.length ? this.client_state.current_corporation_metadata() : null; },
    corporation_name () { return this.corporation_metadata ? this.corporation_metadata.name : '[PENDING]'; },
    corporation_cash () { return this.is_ready && this.client_state.corporation.cash ? this.client_state.corporation.cash : null; },
    corporation_cashflow () { return this.is_ready && this.client_state.corporation?.cashflow ? this.client_state.corporation.cashflow : null; },

    is_form_company_visible () { return this.client_state.initialized && !this.client_state.session_expired_warning && this.client_state?.workflow_status == 'ready' && this.client_state?.menu?.is_visible('company_form'); },
  },

  methods: {
    company_cashflow (company_id: string) { return this.is_ready && this.client_state.corporation.cashflow_by_company_id[company_id] ? this.client_state.corporation.cashflow_by_company_id[company_id] : null; },

    building_count_for_company_id (company_id: string) { return (this.client_state.corporation.buildings_ids_by_company_id?.[company_id] ?? []).length; },

    is_selected (company_id: string) { return this.client_state.player.company_id == company_id; },
    select_company (company_id: string) { return this.client_state.player.company_id = company_id; },

    toggle_form_company_menu () { return this.client_state.menu.toggle_menu('company_form'); }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.button
  &.is-starpeace
    &.is-small
      font-size: .875rem
      line-height: 1.5
      border-radius: .2rem

#toolbar-details
  grid-column: start-left / end-right
  grid-row: start-toolbar / end-toolbar
  pointer-events: auto
  position: relative

  .column-tycoon-details
    background: linear-gradient(to right, $sp-primary-bg, #000)
    padding: 0

  .column-news-ticker
    background-color: darken($sp-primary-bg, 10%)
    color: $sp-primary
    font-size: .85rem
    font-weight: 1000
    height: 100%
    max-width: 24rem
    padding: .5rem


#corporation-details
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
