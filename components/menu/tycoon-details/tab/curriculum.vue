<template lang='pug'>
.sp-tab
  template(v-if='loadingDetails')
    .sp-loading.is-flex.is-align-items-center.is-justify-content-center
      img.starpeace-logo

  .resume-tab(v-else)
    .is-flex.is-flex-direction-column.pr-2
      .resume-section.overview-section.is-flex.is-justify-content-space-between
        div
          div
            span.sp-kv-key {{translate('ui.menu.corporation.panel.details.corporation')}}:
            span.sp-kv-value
              template(v-if='corporation')
                | {{corporation.name}}
              template(v-else)
                | {{translate('ui.misc.none')}}
          div
            span.sp-kv-key {{translate('ui.menu.corporation.panel.details.fortune')}}:
            span.sp-kv-value
              misc-money-text(:value='corporation_cash' no_styling)
          div
            span.sp-kv-key {{translate('ui.menu.corporation.panel.details.fortune_ytd')}}:
            span.sp-kv-value
              misc-money-text(:value='corporation_current_year_cash' no_styling)
          div
            span.sp-kv-key {{translate('ui.menu.corporation.panel.details.fortune_ytd_average')}}:
            span.sp-kv-value
              misc-money-text(:value='corporation_current_year_hours > 0 ? (corporation_current_year_cash / corporation_current_year_hours) : 0' no_styling)
              | /h
          div
            span.sp-kv-key {{translate('misc.corporation.prestige')}}:
            span.sp-kv-value {{corporation_prestige}}

        div.is-flex.is-flex-direction-column.is-justify-content-space-around(v-if='has_corporation && is_self')
          button.button.is-starpeace(disabled) {{translate('ui.menu.tycoon_details.tab.curriculum.action.bankruptcy')}}
          button.button.is-starpeace(disabled) {{translate('ui.menu.tycoon_details.tab.curriculum.action.promotion')}}

      .resume-section.promotion-section
        .is-flex.is-flex-direction-column.level-current
          div
            span.sp-kv-key {{translate('misc.corporation.level')}}:
            span.sp-kv-value {{current_level_label}}

          div
            span {{current_level_description}}

        .is-flex.is-flex-direction-column.level-next
          div
            span.sp-kv-key {{translate('misc.corporation.level.next')}}:
            span.sp-kv-value {{next_level_label}}

          div
            span {{next_level_description}}
          div
            span.has-text-weight-bold {{next_level_requirements}}

    .sp-scrollbar
      table.basic-table.sp-striped.sp-solid-header.sp-sticky-header.rankings
        thead
          tr
            th.sp-kv-key {{translate('ui.menu.tycoon_details.tab.curriculum.ranking')}}
            th.has-text-right.sp-kv-key.column-rank {{translate('ui.menu.tycoon_details.tab.curriculum.rank')}}

        tbody
          template(v-if='!rankings.length')
            tr
              td.has-text-centered(colspan=2) {{translate('ui.misc.none')}}

          template(v-else)
            tr(v-for='rank in sortedRankings')
              td
                span(v-for='label,index in rank.labels' :class="{'ml-1': index > 0}") {{translate(label)}}
              td.has-text-right
                span(v-if='rank.rank < 1') -
                span(v-else) {{rank.rank}}

    .sp-scrollbar
      table.basic-table.sp-striped.sp-solid-header.sp-sticky-header.prestige-history
        thead
          tr
            th.sp-kv-key {{translate('misc.unit.year.singular')}}
            th.sp-kv-key {{translate('ui.menu.tycoon_details.tab.curriculum.history')}}
            th.has-text-right.sp-kv-key.column-prestige {{translate('misc.corporation.prestige')}}

        tbody
          template(v-if='!prestigeHistory.length')
            tr
              td.has-text-centered(colspan=3) {{translate('ui.misc.none')}}

          template(v-else)
            tr(v-for='history in sortedPrestigeHistory')
              td {{history.createdAt.year}}
              td {{history.label}}
              td.has-text-right
                span(v-if='history.prestige > 0') +
                span(v-else) -
                span {{history.prestige}}

</template>

<script lang='coffee'>
import _ from 'lodash';

import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

export default
  props:
    managers: Object
    clientState: Object
    tycoonId: String
    corporationId: String

  data: ->
    loadingDetails: false

    rankings: []
    prestigeHistory: []

  computed:
    has_corporation: -> @corporationId?.length
    is_self: -> @clientState.player.tycoon_id == @tycoonId

    corporation: -> if @has_corporation then @clientState.core.corporation_cache.metadata_for_id(@corporationId) else null

    corporation_cash: -> @corporation?.cash || 0
    corporation_current_year_cash: -> @corporation?.cashCurrentYear || 0
    corporation_current_year_hours: ->
      return 0 unless @corporation?.cashAsOf
      @corporation.cashAsOf.diff(@corporation.cashAsOf.startOf('year'), 'hours').toObject().hours
    corporation_prestige: -> @corporation?.prestige || 0

    current_level: -> if @corporation?.level_id? then @clientState.core.planet_library.level_for_id(@corporation.level_id) else null
    next_level: -> if @corporation?.level_id? then @clientState.core.planet_library.next_level_for_id(@corporation.level_id) else null

    current_level_label: -> if @current_level then @translate(@current_level.label) else ''
    current_level_description: -> @description_for_label(@current_level)
    next_level_label: -> if @next_level then @translate(@next_level.label) else ''
    next_level_description: -> if @next_level then @description_for_label(@next_level) else ''
    next_level_requirements: ->
      return '' if !@next_level
      parts = []
      if @next_level.requiredFee > 0
        parts.push("#{_.template(@translate('ui.menu.tycoon_details.tab.curriculum.levels.requirement.fee'))({ fee: Utils.format_money(@next_level.requiredFee) })}.")
      if @next_level.requiredHourlyProfit > 0
        parts.push("#{_.template(@translate('ui.menu.tycoon_details.tab.curriculum.levels.requirement.profit'))({ profit: Utils.format_money(@next_level.requiredHourlyProfit) })}.")
      if @next_level.requiredPrestige > 0
        parts.push("#{_.template(@translate('ui.menu.tycoon_details.tab.curriculum.levels.requirement.prestige'))({ prestige: @next_level.requiredPrestige })}.")
      parts.join(' ')

    sortedRankings: ->
      _.compact(_.map(@rankings, (r) =>
        ranking_type = @clientState?.core?.planet_library?.ranking_type_for_id(r.rankingTypeId)
        parent_ranking_type = if ranking_type.parent_id? then @clientState?.core?.planet_library?.ranking_type_for_id(ranking_type.parent_id) else null
        return null if !ranking_type? || ranking_type.type == 'FOLDER'
        {
          rankingTypeId: r.rankingTypeId
          labels: @labels_for_ranking_type(ranking_type, parent_ranking_type)
          rank: r.rank
        }
      ))
    sortedPrestigeHistory: -> _.orderBy(this.prestigeHistory, ['createdAt', 'label'], ['desc', 'asc'])

  mounted: ->
    @refresh_details()

  watch:
    tycoonId: (newValue, oldValue) ->
      if newValue != oldValue
        @reset_state() if oldValue
        @refresh_details()
    corporationId: (newValue, oldValue) ->
      if newValue != oldValue
        @reset_state() if oldValue
        @refresh_details()

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    description_for_label: (level) ->
      return '' if !level
      parts = []

      if level.rewardPrestige > 0
        parts.push("#{_.template(@translate('ui.menu.tycoon_details.tab.curriculum.levels.reward.prestige'))({ prestige: level.rewardPrestige })}.")

      parts.push(@translate(level.description))

      if level.supplierIfel || level.refundResearch > 0 || level.refundDemolition > 0
        parts.push("#{@translate('ui.menu.tycoon_details.tab.curriculum.levels.protection.ifel')},")
      else
        parts.push("#{@translate('ui.menu.tycoon_details.tab.curriculum.levels.protection.none')},")

      if level.supplierPriority
        parts.push("#{@translate('ui.menu.tycoon_details.tab.curriculum.levels.priority.supplier')}.")
      else
        parts.push("#{@translate('ui.menu.tycoon_details.tab.curriculum.levels.priority.none')}.")

      if level.supplierIfel
        parts.push("#{@translate('ui.menu.tycoon_details.tab.curriculum.levels.trade_center.ifel')}.")
      else
        parts.push("#{@translate('ui.menu.tycoon_details.tab.curriculum.levels.trade_center.none')}.")

      parts.push("#{_.template(@translate('ui.menu.tycoon_details.tab.curriculum.levels.facility.count'))({ count: level.facilityLimit })}.")

      if level.refundDemolition > 0
        parts.push("#{_.template(@translate('ui.menu.tycoon_details.tab.curriculum.levels.refund.demolition'))({ refund: (100 * level.refundDemolition).toFixed(0) })}.")

      if level.refundResearch > 0
        parts.push("#{_.template(@translate('ui.menu.tycoon_details.tab.curriculum.levels.refund.research'))({ refund: (100 * level.refundResearch).toFixed(0) })}.")

      parts.join(' ')

    labels_for_ranking_type: (type, parentType) ->
      if type.category_total
        return [...@labels_for_ranking_type(parentType, null), 'ui.menu.rankings.label.total'] if parentType?
        return ['ui.menu.rankings.label.total']
      return [type.label] if type.label?
      return [@clientState.core.planet_library.type_for_id(type.industry_type_id)?.label] if type.industry_type_id?
      return [@clientState.core.planet_library.category_for_id(type.industry_category_id)?.label] if type.industry_category_id?
      [type.id]

    reset_state: () ->
      @rankings = []
      @prestigeHistory = []

    refresh_details: () ->
      return if @loadingDetails || !@has_corporation
      try
        @loadingDetails = true
        promiseResults = await Promise.all([
          @managers.corporation_manager.load_rankings_by_corporation(@corporationId),
          @managers.corporation_manager.load_prestige_history_by_corporation(@corporationId)
        ])
        @rankings = promiseResults[0] || []
        @prestigeHistory = promiseResults[1] || []
      catch err
        @clientState.add_error_message('Failure loading tycoon details from server', err)
        @rankings = []
        @prestigeHistory = []
      finally
        @loadingDetails = false

</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-menus'
@import '~/assets/stylesheets/starpeace-menus-tycoon-details'


.tycoon-tabs
  .resume-tab
    display: grid
    grid-template-columns: auto max(15vw, 20rem) 30vw
    height: 100%

    > .is-flex
      row-gap: 1rem

    .sp-scrollbar
      overflow-y: scroll

    .resume-section,
    .overview-section
      border: 1px solid $sp-dark-bg
      padding: 1rem

    .promotion-section
      display: grid
      grid-template-columns: 50% 50%

      .level-current,
      .level-next
        row-gap: 1rem

      .level-current
        padding-right: 2rem

      .level-next
        border-left: 1px solid $sp-light-bg
        padding-left: 2rem

.mode-toggle
  position: relative
  padding: .5rem

  ul
    flex-direction: column

  li
    width: 100%

  a
    border-radius: 0 !important
    letter-spacing: .1rem
    padding: .5rem
    text-transform: uppercase


.basic-table
  td
    &.column-action
      .is-flex
        column-gap: 1rem

  &.rankings
    th
      &.column-rank
        width: 10rem

  &.prestige-history
    th
      &.column-prestige
        width: 10rem

</style>
