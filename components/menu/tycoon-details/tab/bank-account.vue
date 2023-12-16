<template lang='pug'>
.sp-tab
  template(v-if='loadingLoans')
    .sp-loading.is-flex.is-align-items-center.is-justify-content-center
      img.starpeace-logo

  .bank-tab(v-else)
    .left-panel
      .sp-scrollbar
        table.basic-table.sp-striped.sp-solid-header.sp-sticky-header.bank-accounts
          thead
            tr
              th.sp-kv-key.column-account {{$translate('ui.menu.tycoon_details.tab.bank_account.accounts.account')}}
              th.sp-kv-key.column-banker {{$translate('ui.menu.tycoon_details.tab.bank_account.accounts.banker')}}
              th.has-text-right.sp-kv-key.column-balance {{$translate('ui.menu.tycoon_details.tab.bank_account.accounts.balance')}}
              th.has-text-right.sp-kv-key.column-interest {{$translate('ui.menu.tycoon_details.tab.bank_account.accounts.interest_rate')}}

          tbody
            tr
              td.is-size-5 {{$translate('ui.menu.tycoon_details.tab.bank_account.accounts.personal')}}
              td IFEL
              td.has-text-right
                misc-money-text(:value='corporation_cash' no_styling)
              td.has-text-right 0.00%

      .sp-scrollbar
        table.basic-table.sp-striped.sp-solid-header.sp-sticky-header.bank-loan-payments
          thead
            tr
              th.sp-kv-key.column-date {{$translate('ui.menu.tycoon_details.tab.bank_account.loans.maturity')}}
              th.sp-kv-key.column-banker {{$translate('ui.menu.tycoon_details.tab.bank_account.loans.banker')}}
              th.sp-kv-key.column-date {{$translate('ui.menu.tycoon_details.tab.bank_account.loans.next_payment')}}
              th.has-text-right.sp-kv-key.column-payment {{$translate('ui.menu.tycoon_details.tab.bank_account.loans.payment_amount')}}
              th.has-text-right.sp-kv-key.column-balance {{$translate('ui.menu.tycoon_details.tab.bank_account.loans.principle_balance')}}
              th.has-text-right.sp-kv-key.column-interest {{$translate('ui.menu.tycoon_details.tab.bank_account.loans.interest_rate')}}
              th.column-action

          tbody
            tr(v-for='payment in sortedLoanPayments')
              td {{payment.maturityAt.toFormat('MMM d, yyyy')}}
              td IFEL
              td {{payment.nextPaymentAt.toFormat('MMM d, yyyy')}}
              td.has-text-right
                misc-money-text(:value='payment.nextPaymentAmount' no_styling)
              td.has-text-right
                misc-money-text(:value='payment.principleBalance' no_styling)
              td.has-text-right {{payment.interestRatePercent.toFixed(2)}}%
              td.column-action
                .is-flex.is-justify-content-center(v-if='has_corporation && is_self')
                  button.button.is-small.is-starpeace(disabled) {{$translate('ui.menu.tycoon_details.tab.bank_account.loans.repay')}}

    .sp-scrollbar.right-panel
      table.basic-table.sp-striped.sp-solid-header.sp-sticky-header.bank-loan-offers
        thead
          tr
            th.sp-kv-key.column-banker {{$translate('ui.menu.tycoon_details.tab.bank_account.loans.banker')}}
            th.has-text-right.sp-kv-key.column-max-loan {{$translate('ui.menu.tycoon_details.tab.bank_account.loans.max_loan')}}
            th.has-text-right.sp-kv-key.column-interest {{$translate('ui.menu.tycoon_details.tab.bank_account.loans.interest_rate')}}
            th.has-text-right.sp-kv-key.column-term {{$translate('ui.menu.tycoon_details.tab.bank_account.loans.term')}}
            th.column-action

        tbody
          tr(v-for='offer in sortedLoanOffers')
            td IFEL
            td.has-text-right
              misc-money-text(:value='offer.maxAmount' no_styling)
            td.has-text-right {{offer.interestRatePercent.toFixed(2)}}%
            td.has-text-right
              template(v-if='offer.maxTermYears > 1')
                span {{offer.maxTermYears}} {{$translate('misc.unit.year.plural')}}
              template(v-else)
                span {{offer.maxTermYears}} {{$translate('misc.unit.year.singular')}}
            td
              .is-flex.is-justify-content-center(v-if='has_corporation && is_self')
                button.button.is-small.is-starpeace(disabled) {{$translate('ui.menu.tycoon_details.tab.bank_account.loans.apply')}}


</template>

<script lang='ts'>
import _ from 'lodash';
import ClientState from '~/plugins/starpeace-client/state/client-state';

export default {
  props: {
    clientState: { type: ClientState, required: true },
    tycoonId: String,
    corporationId: String
  },

  data () {
    return {
      loadingLoans: false,

      loanPayments: [],
      loanOffers: []
    };
  },

  computed: {
    has_corporation (): boolean { return (this.corporationId?.length ?? 0) > 0; },
    is_self (): boolean { return this.clientState.player.tycoon_id === this.tycoonId; },

    corporation (): any { return this.has_corporation ? this.clientState.core.corporation_cache.metadata_for_id(this.corporationId) : null; },

    corporation_cash (): number { return this.corporation?.cash ?? 0; },

    sortedLoanPayments (): Array<any> { return _.orderBy(this.loanPayments, ['nextPaymentAt', 'nextPaymentAmount'], ['asc', 'desc']); },
    sortedLoanOffers (): Array<any> { return _.orderBy(this.loanOffers, ['maxAmount', 'interestRate'], ['desc', 'asc']); }
  },

  mounted () {
    this.refresh_details();
  },

  watch: {
    tycoonId (newValue, oldValue) {
      if (newValue !== oldValue) {
        if (oldValue) this.reset_state();
        this.refresh_details();
      }
    },
    corporationId (newValue, oldValue) {
      if (newValue !== oldValue) {
        if (oldValue) this.reset_state();
        this.refresh_details();
      }
    }
  },

  methods: {
    reset_state () {
      this.loanPayments = [];
      this.loanOffers = [];
    },

    async refresh_details () {
      if (this.loadingLoans || !this.has_corporation) return;
      try {
        this.loadingLoans = true;
        const promiseResults = await Promise.all([
          this.$starpeaceClient.managers.corporation_manager.load_loan_payments_by_corporation(this.corporationId),
          this.$starpeaceClient.managers.corporation_manager.load_loan_offers_by_corporation(this.corporationId)
        ]);
        this.loanPayments = promiseResults[0] ?? [];
        this.loanOffers = promiseResults[1] ?? [];
      }
      catch (err) {
        this.clientState.add_error_message('Failure loading tycoon details from server', err);
        this.loanPayments = [];
        this.loanOffers = [];
      }
      finally {
        this.loadingLoans = false;
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-menus'
@import '~/assets/stylesheets/starpeace-menus-tycoon-details'


.tycoon-tabs
  .bank-tab
    display: grid
    grid-template-columns: auto max(40vw, 50rem)
    height: 100%

    .sp-scrollbar
      overflow-y: scroll

    .left-panel
      display: grid
      grid-template-rows: 20vh auto

.basic-table
  td
    &.column-action
      .is-flex
        column-gap: 1rem

  &.bank-accounts
    th
      &.column-balance
        width: 20rem

      &.column-interest
        width: 10rem

  &.bank-loan-payments
    th
      &.column-date
        width: 13rem

      &.column-payment
        width: 12rem

      &.column-balance
        width: 16rem

      &.column-interest
        width: 10rem

      &.column-action
        width: 10rem

  &.bank-loan-offers
    th
      &.column-max-loan
        width: 16rem

      &.column-interest
        width: 10rem

      &.column-term
        width: 10rem

      &.column-action
        width: 10rem

</style>
