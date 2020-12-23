<template lang='pug'>
div
  .information
    .details-column
      .detail-row
        span.detail-label {{translate('ui.menu.town_search.panel.details.population.label')}}:
        span.detail-value 0
      .detail-row
        span.detail-label {{translate('ui.menu.town_search.panel.details.investments.label')}}:
        span.detail-value
          money-text(:value='1000000000' no_styling)
      .detail-row
        span.detail-label {{translate('ui.menu.town_search.panel.details.qol.label')}}:
        span.detail-value 0%
      .detail-row
        span.detail-label {{translate('ui.menu.town_search.panel.details.unemployeement.label')}}:
        span.detail-value 0%
      .detail-row
        span.detail-label {{translate('ui.menu.town_search.panel.details.mayor.label')}}:
        span.detail-value
          template(v-if='town.mayor') {{town.mayor.tycoonName}}
          template(v-else) {{translate('ui.misc.none')}}

  .town-actions.level.is-mobile
    .level-item.action-column
      a.button.is-fullwidth.is-small.is-starpeace(@click.stop.prevent='show_in_map') {{translate('ui.menu.town_search.panel.action.show_in_map')}}
    .level-item.action-column
      a.button.is-fullwidth.is-small.is-starpeace(@click.stop.prevent='show_politics') {{translate('ui.menu.town_search.panel.action.show_politics')}}

  tree-menu-item(
    visible=true
    :managers='managers'
    :item='buildings_item'
    :level='1'
  )
  tree-menu-item(
    visible=true
    :managers='managers'
    :item='companies_item'
    :level='1'
  )

</template>

<script lang='coffee'>
import TreeMenuItem from '~/components/menu/shared/tree-menu/item.vue'
import MoneyText from '~/components/misc/money-text.vue'

export default
  components: {
    TreeMenuItem
    MoneyText
  }

  props:
    managers: Object
    clientState: Object

    visible: Boolean
    town: Object

  data: ->
    buildings_item: @refresh_buildings_item()
    companies_item: @refresh_companies_item()

  watch:
    visible: ->
      if @visible
        @buildings_item = @refresh_buildings_item()
        @companies_item = @refresh_companies_item()

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    refresh_buildings_item: ->
      {
        id: 'buildings'
        type: 'FOLDER'
        primary: true
        labelKey: 'ui.menu.town_search.panel.action.buildings'
        children: @managers.utils.tree_menu.organize_building_definitions(@clientState.player.planet_id, @town.id, _.values(@clientState.core.building_library.metadata_by_id))
      }

    refresh_companies_item: ->
      {
        id: 'companies'
        type: 'FOLDER'
        primary: true
        labelKey: 'ui.menu.town_search.panel.action.companies'
        load_children_callback: () => @managers.planets_manager.companies_by_town(@clientState.player.planet_id, @town.id)
        convert_children_callback: (companies) => _.map(companies, (company) => {
          id: company.id
          label: company.name
          type: 'COMPANY'
          seal_id: company.seal_id
          load_children_callback: () => @managers.building_manager.load_by_company(company.id)
          convert_children_callback: (buildings) => @managers.utils.tree_menu.organize_buildings(company.id, buildings)
        })
      }

    show_in_map: -> @clientState.jump_to(@town.map_x, @town.map_y, @town.building_id) if @town?.building_id? && @town?.map_x? && @town?.map_y?
    show_politics: -> @clientState.show_politics(@town.id) if @town?.id?

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

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
