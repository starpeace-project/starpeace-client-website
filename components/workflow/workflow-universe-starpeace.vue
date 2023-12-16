<template lang='pug'>
.columns.universe-starpeace-actions
  .column.is-6
    h3 {{$translate('identity.visitor')}} {{$translate('identity.visa')}}
    .visa-icon
      font-awesome-icon.tycoon-icon(:icon="['fas', 'user-secret']")
    .visa-info
      ul.fa-ul
        li
          font-awesome-icon.fa-li(:icon="['fas', 'check']")
          span {{$translate('ui.workflow.visa-type.visitor.bullet1')}}
        li
          font-awesome-icon.fa-li(:icon="['fas', 'check']")
          span {{$translate('ui.workflow.visa-type.visitor.bullet2')}}
        li
          font-awesome-icon.fa-li(:icon="['fas', 'check']")
          span {{$translate('ui.workflow.visa-type.visitor.bullet3')}}
    a.button.is-medium.is-starpeace.tooltip.is-tooltip-bottom(disabled=true, :data-tooltip="$translate('ui.workflow.visa-type.univerese.not_available')") {{$translate('identity.visitor')}} {{$translate('identity.visa')}}

  .column.is-6.tycoon-column
    h3 {{$translate('identity.tycoon')}} {{$translate('identity.visa')}}
    .visa-icon
      font-awesome-icon.tycoon-icon(:icon="['fas', 'user-tie']")
    .visa-info
      ul.fa-ul
        li
          font-awesome-icon.fa-li(:icon="['fas', 'check']")
          span {{$translate('ui.workflow.visa-type.tycoon.bullet1')}}
        li
          font-awesome-icon.fa-li(:icon="['fas', 'check']")
          span {{$translate('ui.workflow.visa-type.tycoon.bullet2')}}
        li
          font-awesome-icon.fa-li(:icon="['fas', 'check']")
          span {{$translate('ui.workflow.visa-type.tycoon.bullet3')}}
    a.button.is-medium.is-starpeace.is-inverted.tooltip.is-tooltip-bottom(disabled=true, :data-tooltip="$translate('ui.workflow.visa-type.univerese.not_available')") {{$translate('identity.tycoon')}} {{$translate('identity.visa')}}

</template>

<script lang='ts'>
import ClientState from '~/plugins/starpeace-client/state/client-state';

export default {
  props: {
    client_state: { type: ClientState, required: true }
  },

  methods: {
    proceed_as_visitor (): void { this.client_state.identity.set_visa_type('visitor'); },
    proceed_as_tycoon (): void { this.client_state.identity.set_visa_type('tycoon'); }
  }
}
</script>

<style lang='sass' scoped>
@import 'bulma/sass/utilities/_all'
@import '~/assets/stylesheets/starpeace-variables'

.identity-content
  height: 100%
  position: relative
  overflow: hidden

.welcome-message
  border-bottom: 1px solid $sp-primary
  color: #fff
  font-size: 1.5rem
  min-height: 6rem
  padding: 0 .5rem 1.5rem
  margin-bottom: 0

  .salut
    font-weight: bold

  a
    color: #fff
    font-size: 1.25rem

.universe-mode
  border-bottom: 1px solid $sp-primary
  margin: 0

  > .column
    padding: 0


.universe-starpeace-actions
  height: 22rem
  margin: 0

  .column
    padding-bottom: 2rem
    padding-top: 1.5rem
    text-align: center

    &:first-child
      +mobile
        border-bottom: 1px solid $sp-primary
        padding-bottom: 2rem

      +tablet
        border-right: 1px solid $sp-primary

    &.tycoon-column
      padding-left: 1.5rem

    h3
      color: #fff
      font-size: 1.75rem
      font-weight: 1000
      letter-spacing: .25rem

    .tycoon-icon
      color: #fff
      font-size: 4rem
      margin: .5rem 0 1rem

    ul
      display: inline-block
      font-size: 1.25rem
      margin: 0 0 1.5rem 2rem
      text-align: left

      li
        margin-bottom: .25rem

      .fa-li
        margin-top: .25rem


</style>
