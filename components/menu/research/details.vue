<template lang='pug'>
.research-container
  .invention-details(v-if="selected_invention != null")
    .invention-selected-details
      .invention-name {{translate(invention_name)}}
      .invention-description {{translate(invention_description)}}
      .invention-cost
        span.sp-kv-key {{translate('ui.menu.research.cost.label')}}:
        span.cost-value {{invention_cost}}
      .invention-level(v-if="invention_level_label != null")
        span.sp-kv-key {{translate('ui.menu.research.level.label')}}:
        span.level-value {{translate(invention_level_label)}}

      .invention-requires.is-flex
        span.sp-kv-key.mt-2 {{translate('ui.menu.research.requires.label')}}:
        span.is-inline-flex.is-flex-direction-column.ml-3
          span.none-value(v-if="invention_requires.length == 0") {{translate('ui.menu.research.none.label')}}
          ul.inventions
            li(v-for='option in sort_inventions(invention_requires)')
              a(@click.stop.prevent="select_invention(option.id)") {{translate(option.name)}}

      .invention-allows.is-flex
        span.sp-kv-key.mt-2 {{translate('ui.menu.research.allows.label')}}:
        span.is-inline-flex.is-flex-direction-column.ml-3
          span.none-value(v-if="invention_allows.length == 0") {{translate('ui.menu.research.none.label')}}
          ul.inventions
            li(v-for='option in sort_inventions(invention_allows).slice(0, 3)')
              a(@click.stop.prevent="select_invention(option.id)") {{translate(option.name)}}
            li(v-if='invention_allows.length > 5') {{invention_allows.length - 3}} {{translate('ui.menu.research.others.label')}}
            li(v-else-if='invention_allows.length > 4') 1 {{translate('ui.menu.research.other.label')}}

      .invention-properties.inverse-card(v-if='invention_properties.length')
        ul.inventions
          li(v-for='option in invention_properties')
            span.property-label(:class='option.class') {{option.type}}:
            span.property-value(:class='option.class') {{option.text_parts[0]}}{{option.text_parts[1]}}{{option.text_parts[2]}}
        div.is-clearfix

    .actions-container(v-if="invention_status != 'NONE'")
      .action-row.invention-status
        span.sp-kv-key {{translate('ui.menu.research.status.label')}}:
        span.invention-status-value.available(v-if="invention_status == 'AVAILABLE'") {{translate('ui.menu.research.details.status.available')}}
        span.invention-status-value.blocked(v-else-if="invention_status == 'AVAILABLE_BUILDING'") {{translate(first_allowing_building_name)}} {{translate('ui.menu.research.details.status.building_required')}}
        span.invention-status-value.blocked(v-else-if="invention_status == 'AVAILABLE_LEVEL'") {{translate('ui.menu.research.details.status.level_required')}}
        span.invention-status-value.blocked(v-else-if="invention_status == 'AVAILABLE_BLOCKED'") {{translate('ui.menu.research.details.status.dependencies_required')}}
        span.invention-status-value.pending(v-else-if="invention_status == 'PENDING'")
          span(v-if="selected_invention_active") {{translate('ui.menu.research.details.status.in_progress')}}
          span(v-else-if="selected_invention_pending") {{translate('ui.menu.research.details.status.queued')}}
          span(v-if="selected_invention_progress > 0 && selected_invention_progress < 100")
            |
            | - {{selected_invention_progress}}%
        span.invention-status-value.completed(v-else-if="invention_status == 'COMPLETED' || invention_status == 'COMPLETED_SUPPORT'") {{translate('ui.menu.research.details.status.completed')}}

      .action-row
        button.button.is-fullwidth.is-starpeace(v-if="invention_status == 'AVAILABLE'" @click.stop.prevent='queue_invention' :disabled='actions_disabled') {{translate('ui.menu.research.actions.start.label')}}
        button.button.is-fullwidth.is-starpeace(v-else-if="invention_status == 'AVAILABLE_BUILDING' || invention_status == 'AVAILABLE_LEVEL' || invention_status == 'AVAILABLE_BLOCKED'", disabled=true) {{translate('ui.menu.research.actions.start.label')}}
        button.button.is-fullwidth.is-starpeace(v-else-if="invention_status == 'PENDING'" @click.stop.prevent='sell_invention' :disabled='actions_disabled') {{translate('ui.menu.research.actions.cancel.label')}}
        button.button.is-fullwidth.is-starpeace(v-else-if="invention_status == 'COMPLETED'" @click.stop.prevent='sell_invention' :disabled='actions_disabled') {{translate('ui.menu.research.actions.sell.label')}}
        button.button.is-fullwidth.is-starpeace(v-else-if="invention_status == 'COMPLETED_SUPPORT'" disabled=true) {{translate('ui.menu.research.actions.sell.label')}}

</template>

<script lang='coffee'>
import _ from 'lodash';
import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

export default
  props:
    managers: Object
    ajax_state: Object
    client_state: Object

  mounted: ->
    @client_state?.options?.subscribe_options_listener => @$forceUpdate()

  computed:
    is_ready: -> @client_state?.workflow_status == 'ready'

    selected_invention_id: -> @client_state.interface.inventions_selected_invention_id
    selected_invention: -> if @selected_invention_id? then @client_state.core.invention_library.metadata_for_id(@selected_invention_id) else null

    corporation_level_id: -> @client_state.current_corporation_metadata()?.level_id
    corporation_level: -> if @corporation_level_id? then @client_state.core.planet_library.level_for_id(@corporation_level_id) else null

    invention_name: -> if @selected_invention? then @selected_invention.name else ''
    invention_description: -> if @selected_invention? then @selected_invention.description else ''
    invention_level_id: -> @selected_invention?.properties?.levelId
    invention_level: -> if @invention_level_id? then @client_state.core.planet_library.level_for_id(@invention_level_id) else null
    invention_level_label: -> @invention_level?.label
    invention_cost: ->
      cost = @selected_invention?.properties?.price || 0
      if cost > 0 then "$#{Utils.format_money(cost)}" else ''

    invention_allowing_building_ids: ->
      return [] unless @company_seal? && @selected_invention_id?
      building_ids = @client_state.core.invention_library.allowing_building_by_seal_id[@company_seal]?[@selected_invention_id]
      if building_ids?.size then Array.from(building_ids) else []
    first_allowing_building_id: -> if @invention_allowing_building_ids.length then @invention_allowing_building_ids[0] else null
    first_allowing_building_name: -> if @first_allowing_building_id? then @client_state.core.building_library.metadata_by_id[@first_allowing_building_id]?.name else ''

    invention_ids_for_company: ->
      return [] unless @client_state.player.company_id? || @is_ready
      _.map(@client_state.inventions_for_company(), 'id')

    invention_requires: ->
      upstream = []
      for invention_id in (if @selected_invention? then @client_state.core.invention_library.upstream_ids_for(@selected_invention.id) else [])
        metadata = @client_state.core.invention_library.metadata_for_id(invention_id)
        if metadata? && @invention_ids_for_company.indexOf(metadata.id) >= 0
          upstream.push {
            id: metadata.id
            name: metadata.name
          }
      upstream

    invention_allows: ->
      return [] unless @selected_invention?.id?
      downstream = []
      for invention_id in (if @selected_invention? then @client_state.core.invention_library.downstream_ids_for(@selected_invention.id) else [])
        metadata = @client_state.core.invention_library.metadata_for_id(invention_id)
        if metadata? && @invention_ids_for_company.indexOf(metadata.id) >= 0
          downstream.push {
            id: metadata.id
            name: metadata.name
          }
      downstream

    invention_properties: ->
      properties = []
      if @selected_invention?
        properties_by_type = {}
        properties_by_type[key] = value for key,value of @selected_invention.properties

        properties.push @property_points('Prestige', properties_by_type.prestige) if properties_by_type.prestige?
        properties.push @property_points('Nobility', properties_by_type.nobility) if properties_by_type.nobility?

        properties.push @property_points('Quality', properties_by_type.quality) if properties_by_type.quality?
        properties.push @property_points('Desirability', properties_by_type.desirability) if properties_by_type.desirability?
        properties.push @property_percent('Efficiency', properties_by_type.efficiency) if properties_by_type.efficiency?

        properties.push @property_percent('Beauty', properties_by_type.beauty) if properties_by_type.beauty?
        properties.push @property_percent('Environment', properties_by_type.environment) if properties_by_type.environment?
        properties.push @property_percent('Maintenance', properties_by_type.maintenance) if properties_by_type.maintenance?
        properties.push @property_percent('Privacy', properties_by_type.privacy) if properties_by_type.privacy?
        properties.push @property_percent('Security', properties_by_type.security) if properties_by_type.security?

      properties

    company_id: -> if @is_ready && @client_state.player.company_id? then @client_state.player.company_id else null
    company_seal: -> if @company_id? then @client_state.current_company_metadata().seal_id else null
    company_inventions: -> if @company_id? then @client_state.corporation.inventions_metadata_by_company_id[@company_id] else null

    company_building_ids: -> @client_state.corporation.buildings_ids_by_company_id[@company_id] || []
    company_building_definition_ids: -> new Set(_.compact(_.map(@company_building_ids, (id) => @client_state.core.building_cache.building_metadata_by_id[id]?.definition_id)))

    company_has_allowing_building: ->
      return false unless @invention_allowing_building_ids.length && @company_building_definition_ids.size
      for id in @invention_allowing_building_ids
        return true if @company_building_definition_ids.has(id)
      false

    selected_invention_active: -> @company_inventions?.activeInventionId == @selected_invention_id
    selected_invention_pending: -> @company_inventions?.pendingIds?.indexOf(@selected_invention_id) >= 0
    selected_invention_progress: ->
      return -1 unless @selected_invention_active && @company_inventions?
      price = @client_state.core.invention_library.metadata_for_id(@selected_invention_id)?.properties?.price || 1
      Math.round(100 * @company_inventions.activeInvestment / price)

    invention_status: ->
      return 'NONE' unless @selected_invention? && @company_inventions? && @company_seal?
      if @company_inventions?.isQueued(@selected_invention_id)
        return 'PENDING'
      else if @company_inventions?.completedIds?.has(@selected_invention_id)
        return 'COMPLETED_SUPPORT' if @invention_allows.find((allows) => @company_inventions?.isQueued(allows.id)|| @company_inventions?.isCompleted(allows.id))
        'COMPLETED'
      else
        return 'AVAILABLE_LEVEL' if @invention_level? && @invention_level.level > (@corporation_level?.level || 0)
        return 'AVAILABLE_BLOCKED' if @invention_requires.find((requires) => !@company_inventions?.isCompleted(requires.id))?
        return 'AVAILABLE_BUILDING' unless @company_has_allowing_building
        'AVAILABLE'

    actions_disabled: ->
      return true unless @is_ready && @company_inventions?
      return true if @ajax_state.request_mutex['player.sell_invention']?[@client_state.player.company_id] || @ajax_state.request_mutex['player.queue_invention']?[@client_state.player.company_id]
      !@selected_invention_id? || @company_inventions?.canceledIds?.has(@selected_invention_id)

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    sort_inventions: (inventions) -> _.sortBy(inventions, (invention) => @managers.translation_manager.text(invention.text_key))

    property_points: (type, value) ->
      {
        type: type
        text_parts: [(if value > 0 then '+' else ''), value, ' pts']
        class: if value > 0 then 'positive' else if value < 0 then 'negative' else ''
      }
    property_percent: (type, value) ->
      {
        type: type
        text_parts: [(if value > 0 then '+' else ''), value, '%']
        class: if value > 0 then 'positive' else if value < 0 then 'negative' else ''
      }

    is_invention_completed: (invention_id) -> @company_inventions?.completedIds.has(invention_id)

    select_invention: (invention_id) -> @client_state.interface.inventions_selected_invention_id = invention_id

    sell_invention: () ->
      return unless @selected_invention_id? && @company_inventions? && (@invention_status == 'PENDING' || @invention_status == 'COMPLETED')
      try
        await @managers.invention_manager.sell_invention(@client_state.player.company_id, @selected_invention_id)
        @$forceUpdate()
      catch err
        console.error(err)

    queue_invention: () ->
      return unless @selected_invention_id? && @company_inventions? && @invention_status == 'AVAILABLE'
      try
        await @managers.invention_manager.queue_invention(@client_state.player.company_id, @selected_invention_id)
        @$forceUpdate()
      catch err
        console.error(err)

</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.research-container
  grid-column: 3 / 4
  grid-row: 1 / 2
  position: relative

.invention-details
  color: lighten($sp-primary, 10%)
  font-size: 1.15rem
  height: 100%
  padding: 1rem

  .invention-selected-details
    height: calc(100% - 8rem)

  .invention-name
    color: #ddd
    font-size: 1.5rem
    font-weight: bold
    margin-bottom: .5rem
    min-height: 2rem

  .invention-cost
    margin-top: 1rem
    min-height: 2rem

    .cost-value
      color: #ddd
      font-size: 1.3rem
      font-weight: bold
      margin-left: .75rem

  .invention-level
    margin-top: .25rem
    min-height: 2rem

    .level-value
      font-size: 1.3rem
      font-weight: bold
      margin-left: .75rem
      text-transform: capitalize

  .invention-requires
    margin-top: 1rem
    min-height: 2rem

  .invention-allows
    margin-top: .5rem
    min-height: 2rem

  .invention-requires,
  .invention-allows
    .none-value
      font-weight: lighter
      opacity: .7

    ul
      &.inventions
        li
          &:not(:first-child)
            margin-top: .25rem

        a
          color: lighten($sp-primary, 15%)
          font-size: 1.25rem

  .invention-properties
    background-color: #000D07
    margin-top: 1.5rem
    padding: 1rem

    ul
      li
        font-weight: bold

        &:not(:first-child)
          margin-top: .25rem

    .positive
      color: $color-positive

    .negative
      color: $color-negative

    .property-value
      font-size: 1.3rem
      margin-left: .75rem

  .actions-container
    height: 6rem

    .action-row
      &.invention-status
        min-height: 4rem
        margin-bottom: 1rem

        .invention-status-value
          font-size: 1.3rem
          margin-left: .75rem

          &.available
            font-weight: bold

          &.blocked
            color: $color-negative

          &.pending
            font-style: italic

          &.completed
            font-weight: bold
            color: $color-positive

      .button
        letter-spacing: .1rem
        text-transform: uppercase

</style>
