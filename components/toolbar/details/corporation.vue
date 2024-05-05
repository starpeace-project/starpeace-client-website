<template lang='pug'>
.column-tycoon-details.is-flex.is-flex-direction-row
  .corporation-panel.py-2.pr-2.pl-4.mr-4
    p.corporation-name
      span(v-if='isTycoon') {{ corporationName }}
      span.corporation-name-temp(v-else) [{{ $translate('identity.visitor') }} {{ $translate('identity.visa') }}]
    p.corporation-cash.mt-1(:class="{'is-negative': corporationCash < 0}")
      misc-money-text(no_styling :value='corporationCash')
    p.corporation-cashflow.mt-1(:class="{'is-negative': corporationCashflow < 0}")
      | (
      misc-money-text(no_styling :value='corporationCashflow')
      | /h)
    p.planet-date {{ planetDate }}

  toolbar-details-company-list.is-flex-grow-1(:client-state='clientState')

</template>

<script lang='ts'>
import _ from 'lodash';
import type Corporation from '~/plugins/starpeace-client/corporation/corporation';
import ClientState from '~/plugins/starpeace-client/state/client-state';

export default {
  props: {
    clientState: { type: ClientState, required: true }
  },

  computed: {
    planetDate (): string {
      return this.clientState?.planet?.current_time ? this.clientState.planet.current_time.toFormat('MMM d, yyyy') : '';
    },

    isTycoon (): boolean {
      return this.clientState.identity.galaxy_visa_type === 'tycoon' && this.clientState.player.planet_visa_type === 'tycoon' && !!this.clientState.identity.galaxy_tycoon_id;
    },

    corporationMetadata (): Corporation | undefined | null {
      return this.clientState.player.corporation_id?.length ? this.clientState.core.corporation_cache.metadata_for_id(this.clientState.player.corporation_id) : undefined;
    },
    corporationName (): string {
      return this.corporationMetadata?.name ?? '[PENDING]';
    },
    corporationCash (): number {
      return this.clientState.corporation?.cash ?? 0;
    },
    corporationCashflow (): number {
      return this.clientState.corporation?.cashflow ?? 0;
    },
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.column-tycoon-details
  align-items: stretch
  background: linear-gradient(to right, $sp-primary-bg, #000)
  max-height: 8rem

  .corporation-panel
    align-items: start
    flex-direction: column

    .corporation-name
      color: #fff

    .corporation-name-temp
      text-transform: uppercase

    .corporation-cash
      color: $sp-primary
      font-size: 1.5rem
      font-weight: 1000
      line-height: 1.25rem

    .corporation-cash,
    .corporation-cashflow
      color: $sp-primary

      &.is-negative
        color: $color-negative

    .planet-date
      color: lighten($sp-primary, 10%)

</style>
