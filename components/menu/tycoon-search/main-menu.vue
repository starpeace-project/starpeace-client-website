<template lang='pug'>
.card.has-header.is-starpeace.sp-menu(oncontextmenu='return false')
  .card-header
    .card-header-title {{translate('ui.menu.tycoon_search.header')}}
    .card-header-icon.card-close(@click.stop.prevent="client_state.menu.toggle_menu('tycoon_search')")
      font-awesome-icon(:icon="['fas', 'times']")

  .card-content.sp-menu-background
    template(v-if='has_query')
      .sp-section-breadcrumb
        nav.breadcrumb.sp-menu-breadcrumb
          ul
            li
              a(@click.stop.prevent='clear_query')
                span.sp-breadcrumb-icon
                  font-awesome-icon(:icon="['fas', 'home']")
                span {{translate('ui.menu.tycoon_search.breadcrumb')}}

            li.is-active
              a
                span {{query}}

      aside.sp-scrollbar.container-results
        .sp-menu-loading-container(v-if='querying || !results')
          img.starpeace-logo

        template(v-else-if='results.length')
          toggle-list-item(
            v-for='result in results'
            :key='result.corporationId'
            :client-state='client_state'
            :label="mode=='TYCOONS' ? result.tycoonName : mode=='CORPORATIONS' ? result.corporationName : ''"
            :details-id='result.corporationId'
            :details-callback='load_corporation'
            v-slot:default='slotProps'
          )
            menu-panel-corporation(
              :hide-tycoon="mode=='TYCOONS'"
              :hide-corporation="mode=='CORPORATIONS'"
              :managers='managers'
              :client-state='client_state'
              :tycoon='result'
              :corporation='slotProps.details'
            )

        template(v-else)
          span.empty-results {{translate('ui.menu.tycoon_search.results.none')}}

    template(v-else)
      .query-fields
        .tabs.is-centered.is-toggle.is-small.is-fullwidth.sp-tabs.query-mode-toggle
          ul
            li(:class="{'is-active':mode=='CORPORATIONS'}" @click.stop.prevent="swap_mode('CORPORATIONS')")
              a {{translate('ui.menu.tycoon_search.toggle.corporations')}}
            li(:class="{'is-active':mode=='TYCOONS'}" @click.stop.prevent="swap_mode('TYCOONS')")
              a {{translate('ui.menu.tycoon_search.toggle.tycoons')}}

        form.field.has-addons.query-input(@submit.stop.prevent='query_search')
          p.control.has-icons-left.is-expanded
            input.input(type='text' v-model='query')
            span.icon.is-left
              font-awesome-icon(:icon="['fas', 'search']")
          p.control
            a.button.is-starpeace(@click.stop.prevent='query_search' :disabled='!can_query') {{translate('ui.menu.tycoon_search.action.search')}}

        .query-index.is-size-4
          a(v-for='n in 26' @click.stop.prevent='query_prefix(n)') {{String.fromCharCode(65 + n - 1)}}

</template>

<script lang='coffee'>
import ToggleListItem from '~/components/menu/shared/toggle-list-menu/item.vue'
import MenuPanelCorporation from '~/components/menu/shared/menu-panel/corporation.vue'

export default
  components: {
    ToggleListItem
    MenuPanelCorporation
  }

  props:
    managers: Object
    ajax_state: Object
    client_state: Object

  data: ->
    mode: 'TYCOONS'
    query: ''

    querying: false
    results: null

  computed:
    is_ready: -> @client_state?.workflow_status == 'ready'

    can_query: -> !@querying && @query.length >= 3
    has_query: -> @querying || @results != null

  watch:
    is_ready: () ->
      unless @is_ready
        @mode = 'TYCOONS'
        @query = ''
        @results = null

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    swap_mode: (mode) ->
      @mode = mode
      @query = ''

    clear_query: () ->
      @query = ''
      @results = null

    query_prefix: (num) ->
      @query = String.fromCharCode(65 + num - 1)
      @do_query(@query, true)

    query_search: () ->
      return unless @can_query
      @do_query(@query, false)

    do_query: (query, queryPrefix) ->
      try
        @querying = true

        if @mode == 'TYCOONS'
          results = await @managers.planets_manager.search_tycoons(@client_state.player.planet_id, query, queryPrefix)
          @results = results if query == @query
        else
          results = await @managers.planets_manager.search_corporations(@client_state.player.planet_id, query, queryPrefix)
          @results = results if query == @query

        @querying = false
      catch err
        @client_state.add_error_message('Failure loading results from server', err)
        @querying = false

    load_corporation: (corporation_id) -> @managers.corporation_manager.load_by_corporation(corporation_id)

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-menus'

.sp-menu
  grid-column: start-right / end-right
  grid-row: start-render / end-inspect

  > .card-content
    grid-template-columns: auto
    grid-template-rows: min-content auto

.container-results
  grid-row: 2 / span 1
  overflow-y: scroll

.query-fields
  margin: .5rem

  .query-mode-toggle
    margin-bottom: .5rem

    a
      letter-spacing: .1rem
      text-transform: uppercase

  .query-input
    margin-bottom: 1.5rem

    .button
      letter-spacing: .1rem
      text-transform: uppercase

  .query-index
    display: inline-flex
    flex-wrap: wrap
    margin: .5rem

    a
      margin: 0 .25rem

.empty-results
  margin: 1rem

</style>
