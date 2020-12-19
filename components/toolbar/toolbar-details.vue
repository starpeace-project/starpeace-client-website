<template lang='pug'>
transition(name='fade')
  #toolbar-details.columns(v-show='is_ready', v-cloak=true)
    .column.column-news-ticker {{ ticker_message }}
    .column.column-tycoon-details
      toolbar-corporation(:managers='managers', :client_state='client_state')
</template>

<script lang='coffee'>
import moment from 'moment'

import ToolbarCorporation from '~/components/toolbar/toolbar-corporation.vue'
import ToolbarMenubar from '~/components/toolbar/toolbar-menubar.vue'
import MoneyText from '~/components/misc/money-text.vue'

export default
  props:
    ajax_state: Object
    client_state: Object
    managers: Object

  components:
    'toolbar-corporation': ToolbarCorporation
    'toolbar-menubar': ToolbarMenubar
    'money-text': MoneyText

  computed:
    is_ready: -> @client_state.initialized && @client_state?.workflow_status == 'ready'
    ticker_message: -> @client_state?.interface?.event_ticker_message || ''

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

.button
  &.is-starpeace
    &.is-small
      font-size: .875rem
      line-height: 1.5
      border-radius: .2rem

#toolbar-details
  grid-column-start: 1
  grid-column-end: 4
  grid-row-start: 6
  grid-row-end: 7
  margin: 0
  padding: 0
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

</style>
