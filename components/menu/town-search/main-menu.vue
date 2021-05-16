<template lang='pug'>
.card.has-header.is-starpeace.sp-menu(oncontextmenu='return false')
  .card-header
    .card-header-title {{translate('ui.menu.town_search.header')}}
    .card-header-icon.card-close(v-on:click.stop.prevent="client_state.menu.toggle_menu('town_search')")
      font-awesome-icon(:icon="['fas', 'times']")

  .card-content.sp-menu-background
    aside.sp-scrollbar.container-results
      toggle-list-item(
        v-for='town in towns'
        :key='town.id'
        :client-state='client_state'
        :label="town.name"
        :details-id='town.id'
        :details-callback='town_callback(town)'
        v-slot:default='slotProps'
      )
        menu-panel-town(
          :managers='managers'
          :client-state='client_state'
          :town='slotProps.details'
        )

</template>

<script lang='coffee'>
import ToggleListItem from '~/components/menu/shared/toggle-list-menu/item.vue'
import MenuPanelTown from '~/components/menu/shared/menu-panel/town.vue'

export default
  components: {
    ToggleListItem
    MenuPanelTown
  }

  props:
    client_state: Object
    managers: Object

  computed:
    towns: -> _.orderBy(@client_state?.planet?.towns || [], ['name'], ['asc'])

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)
    town_callback: (town) -> (town_id) -> Promise.resolve(town)

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-menus'

.sp-menu
  grid-column: start-right / end-right
  grid-row: start-render / end-inspect

  > .card-content
    grid-template-columns: auto
    grid-template-rows: min-content auto

.container-results
  grid-row: 2 / span 1
  overflow-y: scroll

</style>
