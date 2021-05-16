<template lang='pug'>
.card.has-header.is-starpeace.sp-menu(oncontextmenu='return false')
  .card-header
    .card-header-title {{translate('ui.menu.rankings.header')}}
    .card-header-icon.card-close(v-on:click.stop.prevent="client_state.menu.toggle_menu('rankings')")
      font-awesome-icon(:icon="['fas', 'times']")

  .card-content.sp-menu-background
    aside.sp-scrollbar.container-ranking-type(v-if='!selected_ranking_type')
      ranking-type-node(
        v-for='node in ranking_nodes'
        :managers='managers'
        :node='node'
        :level='0'
        :key='node.id'
        @select='select_ranking_type'
      )

    template(v-else)
      .sp-section-breadcrumb
        nav.breadcrumb.sp-menu-breadcrumb
          ul
            li
              a(@click.stop.prevent='clear_selected_ranking_type')
                span.sp-breadcrumb-icon
                  font-awesome-icon(:icon="['fas', 'home']")
                span {{translate('ui.menu.rankings.header')}}

            li.is-active(v-for='label in selected_parent_labels')
              a
                span {{translate(label)}}

        .is-size-5.ranking-title-industry(v-if='selected_ranking_type.category_total || selected_ranking_type.industry_type_id')
          industry-type-icon(:industry_type='selected_ranking_type.industry_type_id' v-if='selected_ranking_type.industry_type_id')
          industry-category-icon(small=true :category='selected_ranking_type.industry_category_id' v-else-if='selected_ranking_type.industry_category_id')
          font-awesome-icon(:icon="['fas', 'medal']" v-else)
          span.title-label {{translate(label_for_type(selected_ranking_type))}}

      aside.sp-scrollbar.container-ranking-tycoons
        template(v-if='is_loading')
          .sp-menu-loading-container
            img.starpeace-logo

        template(v-else)
          ranking-option(
            v-for='ranking in sorted_rankings'
            :managers='managers'
            :client-state='client_state'
            :ajax-state='ajax_state'
            :ranking='ranking'
            :ranking-type='selected_ranking_type'
            :key="selected_ranking_type.id + '-' + ranking.rank"
            @toggle='select_tycoon'
          )

</template>

<script lang='coffee'>
import RankingOption from '~/components/menu/rankings/ranking-option.vue'
import RankingTypeNode from '~/components/menu/rankings/ranking-type-node.vue'
import IndustryCategoryIcon from '~/components/misc/industry-category-icon.vue'
import IndustryTypeIcon from '~/components/misc/industry-type-icon.vue'

import _ from 'lodash'
import Translation from '~/plugins/starpeace-client/language/translation.coffee'

export default
  components: {
    IndustryCategoryIcon
    IndustryTypeIcon
    RankingOption
    RankingTypeNode
  }

  props:
    managers: Object
    ajax_state: Object
    client_state: Object

  data: ->
    ranking_nodes: []
    rankings: null

  computed:
    ranking_types: -> _.values(@client_state?.core?.planet_library?.ranking_types_by_id)
    sorted_rankings: -> _.orderBy(@rankings, ['rank'], ['asc'])

    is_loading: ->
      return false unless @client_state.player.planet_id?.length && @selected_ranking_type_id?.length && @rankings
      @ajax_state.request_mutex['planet_rankings']?["#{@client_state.player.planet_id}:#{@selected_ranking_type_id}"] || false

    selected_ranking_type_id: -> @client_state?.interface?.selected_ranking_type_id
    selected_ranking_type: -> if @selected_ranking_type_id?.length then @client_state?.core?.planet_library?.ranking_type_for_id(@selected_ranking_type_id) else null

    selected_parent_labels: ->
      return [@label_for_type(@selected_ranking_type)] unless @selected_ranking_type.parent_id?.length
      parent_labels = []
      values = [@selected_ranking_type.parent_id]
      while values.length
        type = @client_state?.core?.planet_library?.ranking_type_for_id(values.shift())
        parent_labels.unshift(@label_for_type(type)) if type?
        values.push type?.parent_id if type?.parent_id?.length
      parent_labels

  mounted: ->
    @client_state.core.planet_cache.subscribe_rankings_listener => @refresh_rankings()

  watch:
    ranking_types: -> @refresh_nodes()
    selected_ranking_type_id: ->
      @client_state.interface.select_ranking_corporation_id(null)
      @refresh_rankings()


  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    refresh_nodes: () -> @ranking_nodes = _.map(_.values(@client_state?.core?.planet_library?.ranking_type_roots()), @type_to_node)
    refresh_rankings: () -> @rankings = if @selected_ranking_type_id?.length then (@client_state.core.planet_cache.rankings(@selected_ranking_type_id) || []) else []

    select_ranking_type: (ranking_type_id) ->
      @rankings = null
      @client_state.interface.toggle_ranking_corporation_id(null)
      @client_state.interface.select_ranking_type_id(ranking_type_id)
    clear_selected_ranking_type: () ->
      @client_state.interface.toggle_ranking_corporation_id(null)
      @client_state.interface.select_ranking_type_id(null)
    select_tycoon: (tycoon_id) ->
      @client_state.interface.toggle_ranking_corporation_id(tycoon_id)

    root_for_node: (type_id) ->
      values = [type_id]
      while values.length
        type = @client_state?.core?.planet_library?.ranking_type_for_id(values.shift())
        return type unless type?.parent_id?.length
        values.push type?.parent_id
      null

    type_to_node: (type) ->
      id: type.id
      label: @label_for_type(type)
      category_total: type.category_total
      industry_category_id: type.industry_category_id
      industry_type_id: type.industry_type_id
      expanded: false
      children: _.map(@client_state.core.planet_library.ranking_type_for_parent_id(type.id), @type_to_node)

    label_for_type: (type) ->
      return 'ui.menu.rankings.label.total' if type.category_total
      return type.label if type.label?
      return @client_state.core.planet_library.type_for_id(type.industry_type_id)?.label if type.industry_type_id?
      return @client_state.core.planet_library.category_for_id(type.industry_category_id)?.label if type.industry_category_id?
      type.id

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-menus'

.sp-menu
  grid-column: start-right / end-right
  grid-row: start-render / end-inspect

  > .card-content
    grid-template-columns: auto
    grid-template-rows: min-content auto

  .container-ranking-type
    grid-row: 2 / span 1
    overflow-y: scroll


.container-ranking-tycoons
  background-color: darken($sp-dark-bg, 10%)
  overflow-y: scroll

.ranking-title-industry
  align-items: center
  border-top: 1px solid darken($sp-primary, 15%)
  display: flex
  padding: .25rem .75rem

  .title-label
    margin-left: .4rem
    padding: .25rem 0

</style>
