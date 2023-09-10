<template lang='pug'>
.card.has-header.is-starpeace.sp-menu(:oncontextmenu="'return ' + !$config.public.disableRightClick")
  .card-header
    .card-header-title {{$translate('ui.menu.town_search.header')}}
    .card-header-icon.card-close(v-on:click.stop.prevent="client_state.menu.toggle_menu('town_search')")
      font-awesome-icon(:icon="['fas', 'times']")

  .card-content.sp-menu-background
    aside.sp-scrollbar.container-results
      menu-shared-toggle-list-menu-item(
        v-for='town in towns'
        :key='town.id'
        :client-state='client_state'
        :label="town.name"
        :details-id='town.id'
        :details-callback='town_callback(town)'
        v-slot:default='slotProps'
      )
        menu-shared-menu-panel-town(
          :client-state='client_state'
          :town='slotProps.details'
        )

</template>

<script lang='ts'>
import _ from 'lodash';
import ClientState from '~/plugins/starpeace-client/state/client-state.coffee';

export default {
  props: {
    client_state: { type: ClientState, required: true }
  },

  computed: {
    towns () { return _.orderBy(this.client_state.planet?.towns ?? [], ['name'], ['asc']); }
  },

  methods: {
    town_callback (town: any) {
      return (town_id: string) => Promise.resolve(town);
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-menus'

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
