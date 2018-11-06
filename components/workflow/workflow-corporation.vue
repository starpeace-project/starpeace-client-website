<template lang='haml'>
.card.is-starpeace.sp-scrollbar.corporations-container{'v-if':"existing_corporations.length"}
  .card-header
    .card-header-title
      Corporations
      %template{'v-if':'system_name.length'}
        %span.title-spacer \/
        %span.system-name {{system_name}}
  .card-content
    .content
      .card.corporation{'v-for':'corporation in existing_corporations'}
        .card-content
          .level.is-mobile.corporation-row
            .level-left
              .level-item
                %img.corporation-logo.starpeace-logo.logo-primary-color{'v-bind:src':"", 'v-on:load':"$event.target.classList.remove('logo-loading')"}

            .level-item.corporation-item.info
              .content
                .corporation-name {{corporation.name}}
                .corporation-location
                  %span {{name_for_system_id(corporation.system_id)}}
                  %span.detail-spacer \/
                  %span {{name_for_planet_id(corporation.planet_id)}}
                .corporation-details
                  %span {{corporation.company_count}} {{corporation.company_count == 1 ? 'company' : 'companies'}}
                  %span.detail-spacer |
                  %span {{corporation.building_count}} {{corporation.building_count == 1 ? 'building' : 'buildings'}}

            .level-item.corporation-item.cash
              .content
                .corporation-cash
                  %money-text{'v-bind:value':'corporation.cash'}
                .corporation-cashflow
                  %money-text{'v-bind:value':'corporation.cashflow'}
                  %span.unit \/h

            .level-right
              .level-item
                %a.button.is-primary.is-medium.workflow-action{'v-bind:class':'corporation_action_css_class(corporation)', 'v-on:click.stop.prevent':'select_corporation(corporation)', 'v-bind:disabled':'system_or_planet_disabled(corporation.system_id, corporation.planet_id)'} Select

</template>

<script lang='coffee'>
import MoneyText from '~/components/misc/money-text.vue'

export default
  components:
    'money-text': MoneyText

  props:
    client: Object
    game_state: Object
    status: String
    system_name: String

  computed:
    existing_corporations: ->
      sort_by = (corps) => _.sortBy(corps, (corp) => @name_for_system_id(corp.system_id) + @name_for_planet_id(corp.system_id) + corp.name)
      if @game_state? && @game_state.session_state.state_counter? && @game_state.session_state.tycoon_metadata?
        corporations = @game_state.session_state.tycoon_metadata.corporations
        if @game_state.session_state.system_id?
          sort_by(_.filter(corporations, (corp) => corp.system_id == @game_state.session_state.system_id))
        else
          sort_by(corporations)
      else
        []

  methods:
    select_corporation: (corporation) -> @client.select_corporation(corporation)

    corporation_action_css_class: (corporation) -> if @system_or_planet_disabled(corporation.system_id, corporation.planet_id) then 'is-outlined' else ''
    system_animation_url: (system) -> ''

    name_for_system_id: (system_id) -> @game_state?.name_for_system_id(system_id) || ''
    name_for_planet_id: (planet_id) -> @game_state?.name_for_planet_id(planet_id) || ''

    system_or_planet_disabled: (system_id, planet_id) -> !@game_state?.enabled_for_system_id(system_id) || !@game_state?.enabled_for_planet_id(planet_id)
</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

.workflow-action
  &.button
    min-width: 7rem

.card
  &.sp-scrollbar
    overflow-y: auto

.corporations-container
  margin-bottom: 1rem

  .card-header-title
    font-weight: 500  !important

    .title-spacer
      margin: 0 .75rem

    .system-name
      font-weight: 1000

  > .card-content
    width: 50rem

.card
  &.corporation
    background-color: opacify(lighten($sp-primary-bg, 1%), .3)
    border: 1px solid rgba(110, 161, 146, .2)

    &:not(:first-child)
      margin-top: .25rem

    > .card-content
      padding: 1rem

    .corporation-row
      min-height: 5rem

      .corporation-logo
        background-size: 5rem
        width: 5rem
        height: 5rem

      .corporation-item
        color: #fff

        &.info
          margin-left: 1rem
          justify-content: left

        &.cash
          margin-right: 2rem
          justify-content: right
          text-align: right

          .content
            width: 100%

        .corporation-name
          font-size: 1.5rem
          font-weight: 1000

        .corporation-location
          margin-bottom: .1rem

        .detail-spacer
          color: $sp-primary
          opacity: .7
          margin: 0 .5rem

        .corporation-cash
          font-size: 1.4rem
          font-weight: bold

        .corporation-cashflow
          font-size: 1.2rem

        .corporation-cash,
        .corporation-cashflow
          .positive
            color: #fff

        .unit
          color: $sp-primary

</style>
