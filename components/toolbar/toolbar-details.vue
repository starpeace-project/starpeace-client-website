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

  data: ->
    client_version: process.env.CLIENT_VERSION
    show_game_music: @client_state.options?.option('music.show_game_music')

  mounted: ->
    @client_state.options?.subscribe_options_listener =>
      @show_game_music = @client_state.options?.option('music.show_game_music')

  computed:
    music_state: -> @client_state?.music

    is_ready: -> @client_state.initialized && @client_state?.workflow_status == 'ready'
    ticker_message: -> @client_state?.interface?.event_ticker_message || ''

    menu_class_release_notes: -> { 'is-active': @client_state?.menu?.is_visible('release_notes') || false }

    game_music_playing: -> @music_state.game_music_playing
    game_music_class: -> if @music_state.game_music_playing then 'music-pause' else 'music-play'
    game_music_volume_class: -> if @music_state.game_music_volume then 'music-volume' else 'music-mute'

    notification_loading_css_class: -> { 'ajax-loading': (@ajax_state?.ajax_requests || 0) > 0 }

    tycoon_name: -> if @is_ready && @client_state?.is_tycoon() then @client_state?.current_tycoon_metadata()?.name || '' else 'Visitor'
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
