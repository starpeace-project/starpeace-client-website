<template lang='pug'>
.card.has-header.is-starpeace.sp-menu
  .card-header
    .card-header-title {{translate('ui.menu.town_search.header')}}
    .card-header-icon.card-close(v-on:click.stop.prevent="client_state.menu.toggle_menu('town_search')")
      font-awesome-icon(:icon="['fas', 'times']")

  .card-content.sp-menu-background
    aside.sp-scrollbar.container-results
      town-option(
        v-for='town in towns'
        :key='town.id'
        :managers='managers'
        :client-state='client_state'
        :expanded='expanded_town_id == town.id'
        :town='town'
        @toggle='select_town'
      )

</template>

<script lang='coffee'>
import TownOption from '~/components/menu/town-search/town-option.vue'

export default
  components: {
    TownOption
  }

  props:
    client_state: Object
    managers: Object

  data: ->
    expanded_town_id: null

  computed:
    is_ready: -> @client_state?.workflow_status == 'ready'

    towns: -> _.orderBy(@client_state?.planet?.towns || [], ['name'], ['asc'])

  watch:
    is_ready: () ->
      @expanded_town_id = null unless @is_ready

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    select_town: (town_id) -> @expanded_town_id = if @expanded_town_id == town_id then null else town_id

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-menus'

.sp-menu
  grid-column: 3 / span 1
  grid-row: 2 / span 3

  > .card-content
    grid-template-columns: auto
    grid-template-rows: min-content auto

.container-results
  grid-row: 2 / span 1
  overflow-y: scroll

</style>
