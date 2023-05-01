<template lang='pug'>
.research-container
  .tree-list-container.sp-scrollbar
    .status-title.sp-kv-key {{translate('ui.menu.research.status.available')}}
    ul
      template(v-if="company_research.available.length")
        li(v-for="research in company_research.available")
          a(@click.stop.prevent="select_invention_id(research.id)") {{translate(research.name)}}
      template(v-else)
        li {{translate('ui.menu.research.none.label')}}

    .status-title.sp-kv-key {{translate('ui.menu.research.status.in_progress')}}
    ul
      template(v-if="company_research.in_progress.length")
        li(v-for="research in company_research.in_progress")
          a(@click.stop.prevent="select_invention_id(research.id)") {{translate(research.name)}}
      template(v-else)
        li {{translate('ui.menu.research.none.label')}}

    .status-title.sp-kv-key {{translate('ui.menu.research.status.completed')}}
    ul
      template(v-if="company_research.completed.length")
        li(v-for="research in company_research.completed")
          a(@click.stop.prevent="select_invention_id(research.id)") {{translate(research.name)}}
      template(v-else)
        li {{translate('ui.menu.research.none.label')}}

  .tree-container
    vue2viz-network.inverse-card(ref='tree_network' :options='tree_options' :nodes='tree_nodes' :edges='tree_edges' @select-node="select_tree_node" @deselect-node='deselect_tree_node')

</template>

<script lang='coffee'>
import _ from 'lodash'

NODE_CONFIG = {
  available:
    borderColor: '#083B2C'
    color: 'rgba(85,136,121,0.5)'
    hover:
      borderColor: '#3C6F60'
      color: 'rgba(85,136,121,1)'
    selected:
      borderColor: '#56897A'
      color: 'rgba(85,136,121,1)'
  pending:
    borderColor: '#12083B'
    color: 'rgba(94,84,135,0.5)'
    hover:
      borderColor: '#12083B'
      color: 'rgba(94,84,135,1)'
    selected:
      borderColor: '#12083B'
      color: 'rgba(94,84,135,1)'
  completed:
    borderColor: '#313B08'
    color: 'rgba(125,135,84,0.8)'
    hover:
      borderColor: '#313B08'
      color: 'rgba(125,135,84,1)'
    selected:
      borderColor: '#313B08'
      color: 'rgba(125,135,84,1)'
}

EDGE_CONFIG = {
  width: 4
  borderColor: 'rgba(8,59,44,0.4)'
  hover:
    borderColor: 'rgba(8,59,44,0.7)'
  selected:
    borderColor: 'rgba(8,59,44,1)'
}


export default
  props:
    managers: Object
    client_state: Object

  data: ->
    inventions_for_company: @client_state.inventions_for_company()

    layout_locked: false

    tree_nodes: []
    tree_edges: []
    tree_options:
      interaction:
        dragNodes: false
        hover: true

      layout:
        randomSeed: 0

      physics:
        solver: 'repulsion'

      nodes:
        font:
          color: '#DDDDDD'
        margin: 10
        shape: 'box'

  mounted: ->
    @client_state.corporation.subscribe_company_inventions_listener => @refresh_tree()
    @client_state.options.subscribe_options_listener => @refresh_invention_data()

  watch:
    is_visible: (new_value, old_value) ->
      if @is_visible
        @inventions_for_company = @client_state.inventions_for_company()
        @$refs.tree_network.fit()

    'client_state.player.company_id': (new_value, old_value) ->
      @inventions_for_company = @client_state.inventions_for_company() if @is_visible

    invention_data: (new_value, old_value) -> @refresh_invention_data()

    selected_invention_id: (new_value, old_value) ->
      invention_within_selection = _.find(@invention_data, (invention) -> invention.id == new_value)
      if !invention_within_selection? && new_value?
        invention_metadata = @client_state.core.invention_library.metadata_for_id(new_value)
        if invention_metadata?
          @interface_state.inventions_selected_category_id = invention_metadata.industry_category_id
          @interface_state.inventions_selected_industry_type_id = invention_metadata.industry_type_id

      setTimeout(=>
        @$refs.tree_network.selectNodes([@selected_invention_id]) if @selected_invention_id?
      , 100)


  computed:
    is_ready: -> @client_state?.workflow_status == 'ready'
    is_visible: -> @is_ready && @client_state?.menu?.is_visible('research')

    interface_state: -> @client_state?.interface

    selected_category_id: -> @interface_state?.inventions_selected_category_id
    selected_industry_type_id: -> @interface_state?.inventions_selected_industry_type_id
    selected_invention_id: -> @interface_state?.inventions_selected_invention_id

    invention_data: ->
      inventions = {}
      to_search = []
      for invention in @inventions_for_company
        if invention.industry_category_id == @selected_category_id && (invention.industry_type_id || 'GENERAL') == @selected_industry_type_id
          inventions[invention.id] = invention
          to_search.push invention.id

      while to_search.length
        invention_id = to_search.pop()
        invention_metadata = @client_state.core.invention_library.metadata_for_id(invention_id)

        for depends_id in (invention_metadata?.depends_on || [])
          unless inventions[depends_id]?
            inventions[depends_id] = @client_state.core.invention_library.metadata_for_id(depends_id)
            to_search.push depends_id

      _.values(inventions)

    company_inventions: -> if @is_ready && @client_state.player.company_id? then @client_state.corporation.inventions_metadata_by_company_id[@client_state.player.company_id] else null

    company_research: ->
      research = {
        available: []
        in_progress: null
        pending: []
        completed: []
      }

      for invention in @invention_data
        if @company_inventions?.completedIds?.has(invention.id)
          research.completed.push({ id: invention.id, name: invention.name })
        else if @company_inventions?.isQueued(invention.id)
          research.pending.push({ id: invention.id, name: invention.name })
        else
          research.available.push({ id: invention.id, name: invention.name })

      {
        available: _.sortBy(research.available, (invention) -> invention.text)
        in_progress: (if research.in_progress then [research.in_progress] else []).concat(research.pending)
        completed: _.sortBy(research.completed, (invention) -> invention.text)
      }


  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    refresh_tree: () ->
      if @is_visible
        @inventions_for_company = @client_state.inventions_for_company()
        node.color = @color_for_node(node.id) for node in @tree_nodes
        @$refs.tree_network.fit()

    refresh_invention_data: () ->
      data = []
      links = []

      for invention in @invention_data
        data.push {
          id: invention.id
          label: @translate(invention.name)
          color: @color_for_node(invention.id)
        }

        if invention.depends_on?.length
          for depends_on_id,index in invention.depends_on
            links.push {
              id: "#{depends_on_id}-#{invention.id}"
              from: depends_on_id
              to: invention.id
              arrows:
                to:
                  enabled: true
                  scaleFactor: .5
              color:
                color: EDGE_CONFIG.borderColor
                hover: EDGE_CONFIG.hover.borderColor
                highlight: EDGE_CONFIG.selected.borderColor
              width: EDGE_CONFIG.width
            }

      @tree_nodes = data
      @tree_edges = links

      if @is_visible
        setTimeout(=>
          @$refs.tree_network.fit()
          @$refs.tree_network.selectNodes([@selected_invention_id]) if @selected_invention_id?
        , 100)

    color_for_node: (invention_id) ->
      item_styling = NODE_CONFIG.available
      item_styling = NODE_CONFIG.pending if @company_inventions?.isQueued(invention_id)
      item_styling = NODE_CONFIG.completed if @company_inventions?.completedIds?.has(invention_id)

      {
        background: item_styling.color
        border: item_styling.borderColor
        hover:
          background: item_styling.hover.color
          border: item_styling.hover.borderColor
        highlight:
          background: item_styling.selected.color
          border: item_styling.selected.borderColor
      }

    select_tree_node: (item) -> @select_invention_id(if item.nodes?.length then item.nodes[0] else null)
    deselect_tree_node: (item) -> @select_invention_id(null)

    select_invention_id: (invention_id) ->
      @interface_state.inventions_selected_invention_id = invention_id
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.research-container
  position: relative
  grid-column: 2 / 3
  grid-row: 1 / 2

  .tree-list-container
    height: 100%
    left: 0
    overflow-y: scroll
    padding: 1rem .5rem 0
    position: absolute
    top: 0
    width: 20rem

    .status-title
      border-bottom: 1px solid $sp-primary
      margin-bottom: .25rem
      padding-bottom: .25rem

      &:not(:first-child)
        margin-top: 1.5rem

  .tree-container
    height: 100%
    padding: 0
    margin-left: 20rem
    width: calc(100% - 20rem)

    .inverse-card
      background-color: #000
      border: 0 !important
      height: 100% !important
      margin: 0
      padding: 0
      width: 100% !important

</style>
