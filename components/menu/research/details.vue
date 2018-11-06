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
      .actions-container{'v-if':'can_perform_actions'}
        .action-row.invention-status
          %span.invention-status-label Status:
          %span.invention-status-value.available Available for Research
        .action-row
          %a.button.is-fullwidth.is-starpeace Start Research

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
    invention_manager: Object
    translation_manager: Object
    options: Object
    game_state: Object
    menu_state: Object

  computed:
    can_perform_actions: -> @game_state?.initialized && @game_state.session_state.identity.is_tycoon()

    selected_invention_id: -> @game_state.inventions_selected_invention_id
    selected_invention: -> if @game_state?.initialized && @selected_invention_id?.length && @invention_manager? then @invention_manager.invention_info_by_id?[@selected_invention_id] else null

    invention_name: -> if @selected_invention? then @translation_manager.text(@selected_invention.invention.name_key) else ''
    invention_description: -> if @selected_invention? then @translation_manager.text(@selected_invention.invention.description_key) else ''
    invention_level: -> @selected_invention?.invention?.properties?.level || ''
    invention_cost: ->
      cost = @selected_invention?.invention?.properties?.price || 0
      if cost > 0 then "$#{Utils.format_money(cost)}" else ''

    invention_requires: ->
      upstream = []
      if @selected_invention?
        for invention_id,invention of @selected_invention.upstream
          upstream.push {
            id: invention.id
            text: @translation_manager.text(invention.name_key)
          }
      upstream

    invention_allows: ->
      downstream = []
      if @selected_invention?
        for invention_id,invention of @selected_invention.downstream
          downstream.push {
            id: invention.id
            text: @translation_manager.text(invention.name_key)
          }
      downstream
    invention_allows_leftover: ->
      others = @invention_allows.length - 3
      if others <= 0 then '' else if others == 1 then '1 other' else "#{others} others"

    invention_properties: ->
      properties = []
      if @selected_invention?
        properties_by_type = {}
        properties_by_type[key] = value for key,value of @selected_invention.invention.properties

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

  methods:
    select_invention: (invention_id) ->
      @game_state.inventions_selected_invention_id = invention_id

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

          &.in-progress
            font-style: italic

          &.done
            font-weight: bold
            color: $color-positive

</style>
