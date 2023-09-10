<template lang='pug'>
div
  .information
    .details-column
      .detail-row
        span.detail-label {{$translate('ui.menu.town_search.panel.details.population.label')}}:
        span.detail-value 0
      .detail-row
        span.detail-label {{$translate('ui.menu.town_search.panel.details.investments.label')}}:
        span.detail-value
          misc-money-text(:value='1000000000' no_styling)
      .detail-row
        span.detail-label {{$translate('ui.menu.town_search.panel.details.qol.label')}}:
        span.detail-value 0%
      .detail-row
        span.detail-label {{$translate('ui.menu.town_search.panel.details.unemployeement.label')}}:
        span.detail-value 0%
      .detail-row
        span.detail-label {{$translate('ui.menu.town_search.panel.details.mayor.label')}}:
        span.detail-value
          template(v-if='town.mayor') {{town.mayor.tycoonName}}
          template(v-else) {{$translate('ui.misc.none')}}

  .town-actions.level.is-mobile
    .level-item.action-column
      a.button.is-fullwidth.is-small.is-starpeace(@click.stop.prevent='show_in_map') {{$translate('ui.menu.town_search.panel.action.show_in_map')}}
    .level-item.action-column
      a.button.is-fullwidth.is-small.is-starpeace(@click.stop.prevent='show_politics') {{$translate('ui.menu.town_search.panel.action.show_politics')}}

  menu-shared-tree-menu-item(
    visible=true
    :client-state='clientState'
    :item='buildings_item'
    :level='1'
  )
  menu-shared-tree-menu-item(
    visible=true
    :client-state='clientState'
    :item='companies_item'
    :level='1'
  )

</template>

<script lang='ts'>
import _ from 'lodash';
import ClientState from '~/plugins/starpeace-client/state/client-state.coffee';

export default {
  props: {
    clientState: { type: ClientState, required: true },

    visible: Boolean,
    town: { type: Object, required: true },
  },

  data () {
    return {
      buildings_item: this.refresh_buildings_item(),
      companies_item: this.refresh_companies_item()
    };
  },

  watch: {
    visible () {
      if (this.visible) {
        this.buildings_item = this.refresh_buildings_item();
        this.companies_item = this.refresh_companies_item();
      }
    }
  },

  methods: {
    refresh_buildings_item () {
      return {
        id: 'buildings',
        type: 'FOLDER',
        primary: true,
        labelKey: 'ui.menu.town_search.panel.action.buildings',
        children: this.$starpeaceClient.managers.utils.tree_menu.organize_building_definitions(this.clientState.player.planet_id, this.town.id, _.values(this.clientState.core.building_library.metadata_by_id))
      };
    },

    refresh_companies_item () {
      return {
        id: 'companies',
        type: 'FOLDER',
        primary: true,
        labelKey: 'ui.menu.town_search.panel.action.companies',
        load_children_callback: () => this.$starpeaceClient.managers.planets_manager.companies_by_town(this.clientState.player.planet_id, this.town.id),
        convert_children_callback: (companies: Array<any>) => _.map(companies, (company) => {
          return {
            id: company.id,
            label: company.name,
            type: 'COMPANY',
            seal_id: company.seal_id,
            load_children_callback: () => this.$starpeaceClient.managers.building_manager.load_by_company(company.id),
            convert_children_callback: (buildings: Array<any>) => this.$starpeaceClient.managers.utils.tree_menu.organize_buildings(company.id, buildings)
          };
        })
      };
    },

    show_in_map () {
      if (this.town?.building_id && _.isNumber(this.town?.map_x) && _.isNumber(this.town?.map_y)) {
        this.clientState.jump_to(this.town.map_x, this.town.map_y, this.town.building_id);
      }
    },
    show_politics () {
      if (this.town?.id) {
        this.clientState.show_politics(this.town.id);
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.information
  display: grid
  grid-template-columns: auto
  grid-template-rows: auto

  .details-column
    padding: .5rem

    .detail-label
      color: darken($sp-primary, 5%)
      font-size: .7rem
      letter-spacing: 0.05rem
      text-transform: uppercase

    .detail-value
      color: #ddd
      font-size: 1.1rem
      margin-left: .5rem

.town-actions
  padding: 0 .5rem .5rem .5rem
  margin: 0

</style>
