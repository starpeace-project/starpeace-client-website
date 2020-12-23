<template lang='pug'>
.card.is-starpeace.has-header.sp-menu
  .card-header
    .card-header-title {{translate('ui.menu.chat.header')}}
    .card-header-icon.card-close(v-on:click.stop.prevent="client_state.menu.toggle_menu('chat')")
      font-awesome-icon(:icon="['fas', 'times']")

  .card-content.sp-menu-background
    .section-discord
      | {{translate('ui.menu.chat.discord.prefix')}}
      |
      a.header-item.discord(href='https://discord.gg/TF9Bmsj', target='_blank') Discord
      |
      | {{translate('ui.menu.chat.discord.suffix')}}

    aside.sp-scrollbar.container-results
      .sp-menu-loading-container(v-if='loading || !onlineTycoons')
        img.starpeace-logo

      template(v-else-if='sortedTycoons.length')
        toggle-list-item(
          v-for='(tycoon,index) in sortedTycoons'
          :key='tycoon.corporationId || index'
          :label='tycoon.tycoonName'
          :details-id='tycoon.corporationId'
          :details-callback="tycoon.type == 'visitor' ? null : loadCorporation()"
          v-slot:default='slotProps'
        )
          menu-panel-corporation(
            hide-tycoon
            :managers='managers'
            :client-state='client_state'
            :tycoon='tycoon'
            :corporation='slotProps.details'
          )

      template(v-else)
        .none-container {{translate('ui.misc.none')}}

</template>

<script lang='coffee'>
import ToggleListItem from '~/components/menu/shared/toggle-list-menu/item.vue'
import MenuPanelCorporation from '~/components/menu/shared/menu-panel/corporation.vue'

export default
  components: {
    ToggleListItem
    MenuPanelCorporation
  }

  props:
    managers: Object
    client_state: Object

  data: ->
    visible: @client_state?.menu?.is_visible('chat')
    onlinePromise: null
    onlineTycoons: null

  computed:
    loading: -> @detailsPromise?
    sortedTycoons: -> _.orderBy(_.map(@onlineTycoons, (tycoon) =>
      if tycoon.type == 'visitor'
        tycoon.tycoonName = @translate('identity.visitor')
        tycoon.corporationId = tycoon.tycoonId
      tycoon
    ), ['tycoonName'], ['asc'])

  mounted: ->
    @client_state?.menu?.subscribe_menu_listener =>
      @visible = @client_state?.menu?.is_visible('chat')

  watch:
    visible: ->
      if @visible
        @refreshTycoons()
      else
        @onlineTycoons = null

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)
    loadCorporation: -> (corporationId) => @managers.corporation_manager.load_by_corporation(corporationId)

    refreshTycoons: ->
      try
        @onlinePromise = @managers.planets_manager.load_online_tycoons(@client_state.player.planet_id)
        @onlineTycoons = await @onlinePromise
        @onlinePromise = null
      catch err
        @onlinePromise = null
        console.error err

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-menus'
@import '~assets/stylesheets/starpeace-variables'

.sp-menu
  grid-column: 3 / span 1
  grid-row: 2 / span 3

  > .card-content
    grid-template-columns: auto
    grid-template-rows: min-content min-content auto

.container-results
  grid-row: 3 / span 1
  overflow-y: scroll

.section-discord
  padding: .5rem

.none-container
  padding: .5rem

</style>
