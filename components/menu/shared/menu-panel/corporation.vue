<template lang='pug'>
div
  .information
    .sp-profile.profile-column
      .profile-container
        .profile-image
          .profile-none
          .profile-mask

    .details-column
      .detail-row(v-if='!hideTycoon && tycoon')
        span.detail-label {{translate('ui.menu.corporation.panel.details.tycoon')}}:
        span.detail-value {{tycoon.tycoonName}}
      .detail-row(v-if='!hideCorporation && corporation')
        span.detail-label {{translate('ui.menu.corporation.panel.details.corporation')}}:
        span.detail-value {{corporation.name}}
      .detail-row
        span.detail-label {{translate('ui.menu.corporation.panel.details.fortune')}}:
        span.detail-value
          money-text(:value='100000000000000' no_styling)
      .detail-row
        span.detail-label {{translate('ui.menu.corporation.panel.details.fortune_ytd')}}:
        span.detail-value
          money-text(:value='1000000000' no_styling)
      .detail-row
        span.detail-label {{translate('ui.menu.corporation.panel.details.ranking')}}:
        span.detail-value 0
      .detail-row
        span.detail-label {{translate('ui.menu.corporation.panel.details.level')}}:
        span.detail-value
          template(v-if='level') {{translate(level.label)}}
      .detail-row
        span.detail-label {{translate('ui.menu.corporation.panel.details.prestige')}}:
        span.detail-value 0

  .corporation-actions.level.is-mobile
    .level-item.action-column
      a.button.is-fullwidth.is-small.is-starpeace(@click.stop.prevent='show_profile') {{translate('ui.menu.corporation.panel.action.show_profile')}}
    .level-item.action-column
      a.button.is-fullwidth.is-small.is-starpeace(@click.stop.prevent='send_mail') {{translate('ui.menu.corporation.panel.action.send_mail')}}

  tree-menu-item(
    visible=true
    :managers='managers'
    :item='item'
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

    hideTycoon: Boolean
    hideCorporation: Boolean

    corporation: Object
    tycoon: Object

  data: ->
    item: @companies_item()

  computed:
    level: -> if @corporation?.level_id? then @clientState?.core?.planet_library?.level_for_id(@corporation?.level_id) else null

  watch:
    corporation: () ->
      @item = @companies_item()

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    companies_item: ->
      {
        id: 'companies'
        type: 'FOLDER'
        primary: true
        labelKey: 'ui.menu.corporation.panel.action.companies'
        children: if !@corporation? then [] else _.map(@corporation.companies, (company) => {
          id: company.id
          label: company.name
          type: 'COMPANY'
          seal_id: company.seal_id
          load_children_callback: () => @managers.building_manager.load_by_company(company.id)
          convert_children_callback: (buildings) => @managers.utils.tree_menu.organize_buildings(company.id, buildings)
        })
      }

    show_profile: -> @clientState.show_tycoon_profile(@tycoon.tycoonId) if @tycoon?.tycoonId?
    send_mail: -> @clientState.send_mail(@tycoon.tycoonId, @tycoon.tycoonName, @corporation.id) if @tycoon?.tycoonId? && @corporation?.id?


</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

.information
  display: grid
  grid-template-columns: 30% auto
  grid-template-rows: auto

  .profile-column
    padding: .5rem
    padding-right: .25rem

  .details-column
    padding: .5rem
    padding-left: .25rem

    .detail-label
      color: darken($sp-primary, 5%)
      font-size: .7rem
      letter-spacing: 0.05rem
      text-transform: uppercase

    .detail-value
      color: #ddd
      font-size: 1.1rem
      margin-left: .5rem

.corporation-actions
  padding: 0 .5rem .5rem .5rem
  margin: 0

</style>
