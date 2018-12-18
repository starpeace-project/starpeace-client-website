<template lang='haml'>
#research-details-container.card.is-starpeace.has-header
  .card-header
    .card-header-title
  .card-content.sp-menu-background.overall-container
    .invention-details{'v-if':"selected_invention != null"}
      .invention-selected-details
        .invention-name {{invention_name}}
        .invention-description {{invention_description}}
        .invention-cost
          %span.cost-label Cost:
          %span.cost-value {{invention_cost}}
        .invention-level{'v-if':"invention_level.length"}
          %span.level-label Level:
          %span.level-value {{invention_level}}
        .invention-requires
          %span.invention-label Requires:
          %span.none-value{'v-if':"invention_requires.length == 0"} None
          %ul.inventions
            %li{'v-for':'option in invention_requires'}
              %a{'v-on:click.stop.prevent':"select_invention(option.id)"} {{option.text}}
          %div.is-clearfix
        .invention-allows
          %span.invention-label Allows:
          %span.none-value{'v-if':"invention_allows.length == 0"} None
          %ul.inventions
            %li{'v-for':'option in invention_allows.slice(0, 3)'}
              %a{'v-on:click.stop.prevent':"select_invention(option.id)"} {{option.text}}
            %li{'v-if':'invention_allows.length > 3'} {{invention_allows_leftover}}
          %div.is-clearfix
        .invention-properties.inverse-card{'v-if':'invention_properties.length'}
          %ul.inventions
            %li{'v-for':'option in invention_properties'}
              %span.property-label{'v-bind:class':'option.class'} {{option.type}}:
              %span.property-value{'v-bind:class':'option.class'} {{option.text}}
          %div.is-clearfix
      .actions-container{'v-if':"invention_status != 'NONE'"}
        .action-row.invention-status
          %span.invention-status-label Status:
          %span.invention-status-value.available{'v-if':"invention_status == 'AVAILABLE'"} Available for Research
          %span.invention-status-value.blocked{'v-else-if':"invention_status == 'AVAILABLE_BLOCKED'"} Dependencies Required
          %span.invention-status-value.pending{'v-else-if':"invention_status == 'PENDING'"}
            %span{'v-if':"company_pending_invention.order == 0"} In Progress
            %span{'v-else-if':"company_pending_invention.order > 0"} Queued
            %span{'v-if':"company_pending_invention.progress > 0 && company_pending_invention.progress < 100"}&nbsp;- {{Math.round(company_pending_invention.progress)}}%
          %span.invention-status-value.completed{'v-else-if':"invention_status == 'COMPLETED' || invention_status == 'COMPLETED_SUPPORT'"} Researched
        .action-row
          %a.button.is-fullwidth.is-starpeace{'v-if':"invention_status == 'AVAILABLE'", 'v-on:click.stop.prevent':'queue_invention', ':disabled':'actions_disabled'} Start Research
          %a.button.is-fullwidth.is-starpeace{'v-else-if':"invention_status == 'AVAILABLE_BLOCKED'", 'disabled':true} Start Research
          %a.button.is-fullwidth.is-starpeace{'v-else-if':"invention_status == 'PENDING'", 'v-on:click.stop.prevent':'sell_invention', ':disabled':'actions_disabled'} Cancel Research
          %a.button.is-fullwidth.is-starpeace{'v-else-if':"invention_status == 'COMPLETED'", 'v-on:click.stop.prevent':'sell_invention', ':disabled':'actions_disabled'} Sell Research
          %a.button.is-fullwidth.is-starpeace{'v-else-if':"invention_status == 'COMPLETED_SUPPORT'", 'disabled':true} Sell Research

</template>

<script lang='coffee'>
import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

property_points = (type, value) ->
  {
    type: type
    text: "#{if value > 0 then '+' else ''}#{value} pts"
    class: if value > 0 then 'positive' else if value < 0 then 'negative' else ''
  }
property_percent = (type, value) ->
  {
    type: type
    text: "#{if value > 0 then '+' else ''}#{value}%"
    class: if value > 0 then 'positive' else if value < 0 then 'negative' else ''
  }


export default
  props:
    managers: Object
    ajax_state: Object
    client_state: Object
    options: Object

  computed:
    is_ready: -> @client_state?.workflow_status == 'ready'

    selected_invention_id: -> @client_state.interface.inventions_selected_invention_id
    selected_invention: -> if @selected_invention_id? then @client_state.core.invention_library.metadata_for_id(@selected_invention_id) else null

    invention_name: -> if @selected_invention? then @managers.translation_manager.text(@selected_invention.name_key) else ''
    invention_description: -> if @selected_invention? then @managers.translation_manager.text(@selected_invention.description_key) else ''
    invention_level: -> @selected_invention?.properties?.level || ''
    invention_cost: ->
      cost = @selected_invention?.properties?.price || 0
      if cost > 0 then "$#{Utils.format_money(cost)}" else ''

    invention_ids_for_company: ->
      if @client_state.identity?.identity?.is_tycoon() && @client_state.player.company_id?
        company_metadata = @client_state.current_company_metadata()
        if company_metadata? then _.map(@client_state.core.invention_library.metadata_for_seal_id(company_metadata.seal_id), (invention) -> invention.id) else []
      else
        _.map(@client_state.core.invention_library.all_metadata(), (invention) -> invention.id)

    invention_requires: ->
      upstream = []
      for invention_id in (if @selected_invention? then @client_state.core.invention_library.upstream_ids_for(@selected_invention.id) else [])
        metadata = @client_state.core.invention_library.metadata_for_id(invention_id)
        if metadata? && @invention_ids_for_company.indexOf(metadata.id) >= 0
          upstream.push {
            id: metadata.id
            text: @managers.translation_manager.text(metadata.name_key)
          }
      _.sortBy(upstream, (invention) -> invention.text)

    invention_allows: ->
      downstream = []
      for invention_id in (if @selected_invention? then @client_state.core.invention_library.downstream_ids_for(@selected_invention.id) else [])
        metadata = @client_state.core.invention_library.metadata_for_id(invention_id)
        if metadata? && @invention_ids_for_company.indexOf(metadata.id) >= 0
          downstream.push {
            id: metadata.id
            text: @managers.translation_manager.text(metadata.name_key)
          }
      _.sortBy(downstream, (invention) -> invention.text)
    invention_allows_leftover: ->
      others = @invention_allows.length - 3
      if others <= 0 then '' else if others == 1 then '1 other' else "#{others} others"

    invention_properties: ->
      properties = []
      if @selected_invention?
        properties_by_type = {}
        properties_by_type[key] = value for key,value of @selected_invention.properties

        properties.push property_points('Prestige', properties_by_type.prestige) if properties_by_type.prestige?
        properties.push property_percent('Beauty', properties_by_type.beauty) if properties_by_type.beauty?
        properties.push property_percent('Efficiency', properties_by_type.efficiency) if properties_by_type.efficiency?
        properties.push property_percent('Environment', properties_by_type.environment) if properties_by_type.environment?
        properties.push property_points('Desirability', properties_by_type.desirability) if properties_by_type.desirability?
        properties.push property_points('Quality', properties_by_type.quality) if properties_by_type.quality?
        properties.push property_percent('Maintenance', properties_by_type.maintenance) if properties_by_type.maintenance?
        properties.push property_points('Nobility', properties_by_type.nobility) if properties_by_type.nobility?
        properties.push property_percent('Privacy', properties_by_type.privacy) if properties_by_type.privacy?
        properties.push property_percent('Security', properties_by_type.security) if properties_by_type.security?

      properties

    company_inventions: -> if @is_ready && @client_state.player.company_id? then @client_state.corporation.inventions_metadata_by_company_id[@client_state.player.company_id] else null
    company_pending_invention: -> if @selected_invention_id? && @company_inventions? then _.find(@company_inventions.pending_inventions, (pending) => pending.id == @selected_invention_id) else null

    invention_status: ->
      return 'NONE' unless @selected_invention? && @company_inventions?
      if @company_pending_invention?
        'PENDING'
      else if @is_invention_completed(@selected_invention_id)
        for allows in @invention_allows
          return 'COMPLETED_SUPPORT' if @is_invention_in_progress(allows.id) || @is_invention_completed(allows.id)
        'COMPLETED'
      else
        for requires in @invention_requires
          return 'AVAILABLE_BLOCKED' unless @is_invention_completed(requires.id)
        'AVAILABLE'

    actions_disabled: ->
      return true unless @is_ready && @company_inventions?
      @ajax_state.request_mutex['player.sell_invention']?[@client_state.player.company_id] || @ajax_state.request_mutex['player.queue_invention']?[@client_state.player.company_id]

  methods:
    is_invention_in_progress: (invention_id) -> @company_inventions? && _.find(@company_inventions.pending_inventions, (pending) => pending.id == invention_id)
    is_invention_completed: (invention_id) -> @company_inventions? && @company_inventions.completed_ids.indexOf(invention_id) >= 0

    select_invention: (invention_id) -> @client_state.interface.inventions_selected_invention_id = invention_id

    sell_invention: () ->
      return unless @selected_invention_id? && @company_inventions? && (@invention_status == 'PENDING' || @invention_status == 'COMPLETED')
      @managers.invention_manager.sell_invention(@client_state.player.company_id, @selected_invention_id).then =>
        @$forceUpdate()

    queue_invention: () ->
      return unless @selected_invention_id? && @company_inventions? && @invention_status == 'AVAILABLE'
      @managers.invention_manager.queue_invention(@client_state.player.company_id, @selected_invention_id).then =>
        @$forceUpdate()

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

#research-details-container
  grid-column-start: 3
  grid-column-end: 4
  grid-row-start: 2
  grid-row-end: 5
  margin: 0
  overflow: hidden
  z-index: 1150

.card
  overflow: hidden

  .card-header
    min-height: 3.4rem

  .card-content
    height: calc(100% - 3.4rem)
    padding: 0

.invention-details
  color: lighten($sp-primary, 10%)
  font-size: 1.15rem
  height: 100%
  padding: 1rem

  .invention-selected-details
    height: calc(100% - 6rem)

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
      margin-left: 6rem

    .invention-label
      position: absolute

    ul
      &.inventions
        float: left
        margin-left: 6rem

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
        min-height: 2rem
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

</style>
