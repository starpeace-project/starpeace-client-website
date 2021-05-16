<template lang='pug'>
.card.has-header.is-starpeace.sp-menu(v-show='visible' oncontextmenu='return false')
  .card-header
    .card-header-title {{translate('ui.menu.politics.header')}}
    .card-header-icon.card-close(v-on:click.stop.prevent="client_state.menu.toggle_menu('politics')")
      font-awesome-icon(:icon="['fas', 'times']")

  .card-content.sp-menu-background.overall-container

    template(v-if='has_selection')
      .has-politics-selected
        .sp-section-breadcrumb
          nav.breadcrumb.sp-menu-breadcrumb
            ul
              li
                a(@click.stop.prevent='clear_selected_politics')
                  span.sp-breadcrumb-icon
                    font-awesome-icon(:icon="['fas', 'home']")
                  span {{translate('ui.menu.politics.header')}}

              li.is-active
                a
                  span {{translate(selected_type == 'MAYOR' ? 'ui.menu.politics.title.mayor' : 'ui.menu.politics.title.president')}} {{selected_name}}

        aside.sp-scrollbar.sp-scroll-container.politics-details
          template(v-if='loading')
            img.loading-image.starpeace-logo.logo-loading

          template(v-else)
            .tabs.is-centered.is-toggle.is-small.is-fullwidth.sp-tabs.politics-mode-toggle
              ul
                li(:class="{'is-active':mode=='CURRENT'}" @click.stop.prevent="mode='CURRENT'")
                  a {{translate('ui.menu.politics.toggle.current')}}
                li(:class="{'is-active':mode=='NEXT'}" @click.stop.prevent="mode='NEXT'")
                  a {{translate('ui.menu.politics.toggle.next')}}

            template(v-if="mode == 'CURRENT'")
              div
                span.sp-kv-key {{translate(selected_type == 'MAYOR' ? 'ui.menu.politics.details.mayor.label' : 'ui.menu.politics.details.president.label')}}:
                span.sp-kv-value
                  template(v-if='current_politician') {{current_politician.name}}
                  template(v-else) {{translate('ui.misc.none')}}

              template(v-if='current_politician')
                div
                  span.sp-kv-key {{translate('misc.corporation.prestige')}}:
                  span.sp-kv-value {{current_politician.prestige}}
                div
                  span.sp-kv-key {{translate('ui.menu.politics.details.overall_rating.label')}}:
                  span.sp-kv-value {{format_percent(current_overall_rating)}}
                div
                  span.sp-kv-key {{translate('ui.menu.politics.details.terms.label')}}:
                  span.sp-kv-value {{current_politician.terms}}

              div
                span.sp-kv-key {{translate('ui.menu.politics.details.remaining.label')}}:
                span.sp-kv-value {{current_remaining_label}}

              table
                thead
                  tr
                    th
                    th.has-text-right.sp-kv-key {{translate('ui.menu.politics.details.delta.label')}}
                    th.has-text-right.sp-kv-key {{translate('ui.menu.politics.details.rating.label')}}
                tbody
                  tr(v-for='rating in current_service_ratings')
                    td.sp-kv-key {{label_for_type(rating.type)}}
                    td.has-text-right.sp-kv-value {{rating.delta}}
                    td.has-text-right.sp-kv-value {{format_percent(rating.rating)}}

            template(v-else-if="mode == 'NEXT'")
              div
                span.sp-kv-key {{translate('ui.menu.politics.details.term_start.label')}}:
                span.sp-kv-value {{term_start}}
              div
                span.sp-kv-key {{translate('ui.menu.politics.details.term_length.label')}}:
                span.sp-kv-value {{term_length}}

              table.candidates-table
                thead
                  tr
                    th.sp-kv-key {{translate('ui.menu.politics.details.candidate.label')}}
                    th.has-text-right.sp-kv-key {{translate('misc.corporation.prestige')}}
                    th.has-text-right.sp-kv-key {{translate('ui.menu.politics.details.votes.label')}}
                    th
                tbody
                  tr(v-if='!term_candidates.length')
                    td(colspan=4) {{translate('ui.misc.none')}}

                  tr(v-for='candidate in term_candidates')
                    td.sp-kv-value {{candidate.name}}
                    td.has-text-right.sp-kv-value {{candidate.prestige}}
                    td.has-text-right.sp-kv-value {{candidate.votes}}
                    td.has-text-right
                      template(v-if='tycoon_id == candidate.id')
                        a.button.is-small.is-starpeace(disabled) {{translate('ui.menu.politics.action.withdraw.label')}}
                      template(v-else)
                        a.button.is-small.is-starpeace(disabled) {{translate('ui.menu.politics.action.vote.label')}}


              .launch-campaign
                a.button.is-fullwidth.is-starpeace(disabled) {{translate('ui.menu.politics.action.launch_campaign.label')}}

                span.information {{translate('ui.menu.politics.info.launch_campaign.label')}}

    template(v-else)
      aside.sp-scrollbar.sp-scroll-container.politics-options
        .list-item(v-for='option in menu_options' :key='option.id')
          a(@click.stop.prevent="select_politics(option.type, option.id)")
            span.item-icon
              font-awesome-icon(:icon="['fas', 'landmark']")
            span.item-label {{translate(option.type == 'MAYOR' ? 'ui.menu.politics.title.mayor' : 'ui.menu.politics.title.president')}} {{option.name}}

</template>

<script lang='coffee'>
import moment from 'moment'

import ServiceType from '~/plugins/starpeace-client/planet/details/service-type.coffee'

export default
  props:
    client_state: Object
    managers: Object
    visible: Boolean

  data: ->
    mode: 'CURRENT'
    details_promise: null
    details: null

  computed:
    is_ready: -> @client_state?.workflow_status == 'ready'
    tycoon_id: -> if @is_ready then @client_state?.player?.tycoon_id else null

    loading: -> @details_promise? || !@details?
    has_selection: -> @selected_type?.length && @selected_id?.length
    selected_id: -> @client_state?.interface?.selected_politics_id
    selected_type: -> @client_state?.interface?.selected_politics_type

    planet_id: -> if @is_ready then @client_state.player.planet_id else null
    planet_name: -> if @is_ready then @client_state.current_planet_metadata()?.name else null
    selected_name: -> if @is_ready && @has_selection then if @selected_type == 'MAYOR' then @client_state.planet.town_for_id(@selected_id)?.name else @planet_name

    menu_options: ->
      return [] unless @is_ready
      [{
        type: 'PRESIDENT'
        name: @planet_name
        id: @client_state.player.planet_id
      }].concat(_.map(_.orderBy(@client_state.planet.towns, ['name'], ['asc']), (t) => {
        type: 'MAYOR'
        name: t.name
        id: t.id
      }))

    current_politician: -> @details?.current_term?.politician

    current_remaining_label: ->
      return @translate('ui.misc.none') unless @details?.current_term?.end? && @client_state?.planet?.current_time?
      months = Math.ceil(@client_state?.planet?.current_time.diff(@details?.current_term?.end, 'months', true))
      return @translate('ui.misc.none') unless months <= 0
      @format_months(-months + 1)

    current_overall_rating: -> @details?.current_term?.overall_rating || 0
    current_service_ratings: -> @details?.current_term?.service_ratings || []

    term_start: -> @details?.next_term?.start?.format('MMM D, YYYY')
    term_length: -> @format_months(@details?.next_term?.length)
    term_candidates: -> @details?.next_term?.candidates || []

  watch:
    selected_id: ->
      @mode = 'CURRENT'
      @refresh_details()
    visible: -> @refresh_details()

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    label_for_type: (service_type) -> @translate(ServiceType.label_for_type(service_type))
    format_percent: (value) -> if _.isNumber(value) then "#{Math.round(value * 100)}%" else ''
    format_months: (months) ->
      years = Math.floor(months / 12)
      leftover_months = months % 12
      labels = []
      labels.push("#{years} #{if years > 1 then @translate('misc.unit.year.plural') else @translate('misc.unit.year.singular')}") if years > 0
      labels.push("#{leftover_months} #{if leftover_months > 1 then @translate('misc.unit.month.plural') else @translate('misc.unit.month.singular')}") if leftover_months > 0
      labels.join(', ')


    clear_selected_politics: -> @client_state?.interface?.unselect_politics()
    select_politics: (type, id) -> @client_state?.interface?.select_politics(type, id)

    refresh_details: ->
      @details = null
      return unless @has_selection && @visible

      try
        if @selected_type == 'PRESIDENT'
          @details_promise = @managers.planets_manager.load_planet_details(@planet_id)
          @details = await @details_promise
          @details_promise = null
        else if @selected_type == 'MAYOR'
          @details_promise = @managers.planets_manager.load_town_details(@planet_id, @selected_id)
          @details = await @details_promise
          @details_promise = null
      catch err
        @client_state.add_error_message('Failure loading politics details from server', err)
        @details_promise = null

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-menus'
@import '~assets/stylesheets/starpeace-variables'

.sp-menu
  grid-column: 1 / span 1
  grid-row: 2 / span 1

  > .card-content
    grid-template-columns: auto
    grid-template-rows: 100%

.sp-scroll-container
  overflow-y: auto

.loading-image
  background-size: 10rem
  height: 10rem
  left: calc(50% - 5rem)
  margin: 1rem 0
  position: absolute
  top: calc(25% - 5rem)
  width: 10rem

.has-politics-selected
  display: grid
  grid-template-columns: auto
  grid-template-rows: min-content auto

.politics-mode-toggle
  margin-bottom: 1rem

  a
    letter-spacing: .1rem
    text-transform: uppercase

.politics-details
  padding: .5rem
  position: relative

  table
    margin-top: 1rem
    width: 100%

    &.candidates-table
      tbody
        td
          height: 2.5rem

    th
      border-bottom: 1px solid $sp-dark-bg
      vertical-align: middle

    td
      border-bottom: 1px solid $sp-dark-bg
      vertical-align: middle

    .button
      text-transform: uppercase
      letter-spacing: .05rem

.launch-campaign
  margin-top: 2rem

  .button
    letter-spacing: .1rem
    margin-bottom: .5rem
    text-transform: uppercase

.list-item
  margin-top: 1px

  a
    display: block
    background-color: darken($sp-primary-bg, 12.5%)
    font-weight: normal
    padding: .5rem .25rem

    &.is-active,
    &:active
      background-color: $sp-primary-bg

    &.no-actions
      touch-action: none

  .item-icon
    display: inline-block
    padding: 0 .25rem 0 .25rem
    width: 1.5rem

  .item-label
    padding: 0 .5rem 0 .25rem


</style>
