<template lang='haml'>
#research-tree-container.card.is-starpeace.has-header
  .card-header
    .card-header-title
    .card-header-icon.card-close{'v-on:click.stop.prevent':"client_state.menu.toggle_menu('research')"}
      %font-awesome-icon{':icon':"['fas', 'times']"}
  .card-content.sp-menu-background.overall-container
    .tree-list-container.sp-scrollbar
      .status-title Available
      %ul
        %template{'v-if':"research_available.length"}
          %li{'v-for':"research in research_available"}
            %a{'v-on:click.stop.prevent':"select_invention(research.id)"} {{research.text}}
        %template{'v-else-if':"true"}
          %li None
      .status-title In Progress
      %ul
        %template{'v-if':"research_in_progress.length"}
          %li
        %template{'v-else-if':"true"}
          %li None
      .status-title Completed
      %ul
        %template{'v-if':"research_completed.length"}
          %li
        %template{'v-else-if':"true"}
          %li None
    .tree-container
      %chart.inverse-card{':options':'tree_options', ':initOptions':'tree_init_options', ':auto-resize':'true', 'v-on:click':"click_item", 'v-on:mouseover':'focus_item', 'v-on:mouseout':'unfocus_item'}

</template>

<script lang='coffee'>

ITEM_PENDING = {
  color: '#558879'
  borderColor: '#083B2C'
  opacity: .3
  hover: {
    color: '#6FA293'
    borderColor: '#3C6F60'
    opacity: 1
  }
  hover_related: {
    color: '#6FA293'
    borderColor: '#3C6F60'
    opacity: .5
  }
  selected: {
    color: '#6FA293'
    borderColor: '#56897A'
    opacity: 1
  }
  selected_related: {
    color: '#6FA293'
    borderColor: '#3C6F60'
    opacity: .6
  }
}

EDGE = {
  opacity: .1
  width: 2
  selected_related: {
    opacity: .4
    width: 4
  }
}

update_tree_state = (invention_library, tree_data, tree_links, selected_invention_id, hover_invention_id) ->
  selected_invention = if selected_invention_id?.length then invention_library.metadata_for_id(selected_invention_id) else null
  hover_invention = if hover_invention_id?.length then invention_library.metadata_for_id(hover_invention_id) else null

  selected_downstream_ids = if selected_invention? then invention_library.downstream_ids_for(selected_invention_id) else []
  selected_upstream_ids = if selected_invention? then invention_library.upstream_ids_for(selected_invention_id) else []
  hover_downstream_ids = if hover_invention? then invention_library.downstream_ids_for(hover_invention_id) else []
  hover_upstream_ids = if hover_invention? then invention_library.upstream_ids_for(hover_invention_id) else []

  for data in tree_data
    data.fixed = true
    if data.name == hover_invention?.id
      data.itemStyle.borderColor = ITEM_PENDING.hover.borderColor
      data.itemStyle.color = ITEM_PENDING.hover.color
      data.itemStyle.opacity = ITEM_PENDING.hover.opacity
    else if data.name == selected_invention?.id
      data.itemStyle.borderColor = ITEM_PENDING.selected.borderColor
      data.itemStyle.color = ITEM_PENDING.selected.color
      data.itemStyle.opacity = ITEM_PENDING.selected.opacity
    else if hover_upstream_ids.indexOf(data.name) >= 0 || hover_downstream_ids.indexOf(data.name) >= 0
      data.itemStyle.borderColor = ITEM_PENDING.hover_related.borderColor
      data.itemStyle.color = ITEM_PENDING.hover_related.color
      data.itemStyle.opacity = ITEM_PENDING.hover_related.opacity
    else if selected_upstream_ids.indexOf(data.name) >= 0 || selected_downstream_ids.indexOf(data.name) >= 0
      data.itemStyle.borderColor = ITEM_PENDING.selected_related.borderColor
      data.itemStyle.color = ITEM_PENDING.selected_related.color
      data.itemStyle.opacity = ITEM_PENDING.selected_related.opacity
    else
      data.itemStyle.borderColor = ITEM_PENDING.borderColor
      data.itemStyle.color = ITEM_PENDING.color
      data.itemStyle.opacity = if hover_invention? then .1 else ITEM_PENDING.opacity

  is_selected_related = (link) =>
    link.source == selected_invention.id || link.target == selected_invention.id ||
        (selected_upstream_ids.indexOf(link.source) >= 0 && selected_upstream_ids.indexOf(link.target) >= 0) ||
        (selected_downstream_ids.indexOf(link.source) >= 0 && selected_downstream_ids.indexOf(link.target) >= 0)
  is_hover_related = (link) =>
    link.source == hover_invention.id || link.target == hover_invention.id ||
        (hover_upstream_ids.indexOf(link.source) >= 0 && hover_upstream_ids.indexOf(link.target) >= 0) ||
        (hover_downstream_ids.indexOf(link.source) >= 0 && hover_downstream_ids.indexOf(link.target) >= 0)

  for link in tree_links
    if selected_invention? && is_selected_related(link) || hover_invention? && is_hover_related(link)
      link.lineStyle.opacity = EDGE.selected_related.opacity
      link.lineStyle.width = EDGE.selected_related.width
    else
      link.lineStyle.opacity = if hover_invention? then .05 else EDGE.opacity
      link.lineStyle.width = EDGE.width

export default
  props:
    managers: Object
    client_state: Object
    options: Object

  data: ->
    inventions_for_company: @client_state.inventions_for_company()

    layout_locked: false

    tree_init_options:
      height: 'auto'
      width: 'auto'

    tree_options:
      tooltip:
        show: false
      animation: false
      series: [{
        type: 'graph'
        layout: 'force'
        roam: true
        focusNodeAdjacency: false
        force:
          edgeLength: 250
          layoutAnimation: false
          repulsion: 1000
        label:
          normal:
            show: true
            formatter: '{c}'
        symbol: 'rect'
        symbolSize: (value, params) ->
          [value.length * 7 + 10, 50]
        edgeSymbol: ['none', 'arrow']
        edgeSymbolSize: [0, 15]
        edgeLabel:
          show: false
        itemStyle:
          borderColor: ITEM_PENDING.borderColor
          borderWidth: 1
          color: ITEM_PENDING.color
          opacity: ITEM_PENDING.opacity
        lineStyle:
          normal:
            opacity: EDGE.opacity
            width: EDGE.width
            curveness: 0.1
        emphasis:
          itemStyle:
            borderColor: ITEM_PENDING.hover.borderColor
            borderWidth: 1
            color: ITEM_PENDING.hover.color
            opacity: ITEM_PENDING.hover.opacity

        data: []
        links: []
      }]


  watch:
    is_visible: (new_value, old_value) ->
      if !@is_visible && @layout_locked
        data.fixed = false for data in @tree_options.series[0].data
        @layout_locked = false
      else if @is_visible
        @inventions_for_company = @client_state.inventions_for_company()

    invention_data: (new_value, old_value) ->
      data = []
      links = []

      for invention in new_value
        data.push {
          name: invention.id
          value: @managers.translation_manager.text(invention.name_key)
          itemStyle:
            color: ITEM_PENDING.color
            borderColor: ITEM_PENDING.borderColor
            opacity: ITEM_PENDING.opacity
          emphasis:
            itemStyle:
              opacity: 1
        }
        if invention.depends_on?.length
          for depends_on_id in invention.depends_on
            links.push {
              source: depends_on_id
              target: invention.id
              lineStyle:
                opacity: EDGE.opacity
            }

      @tree_options.series[0].data = data
      @tree_options.series[0].links = links

    selected_invention_id: (new_value, old_value) ->
      invention_within_selection = _.find(@invention_data, (invention) -> invention.id == new_value)
      unless invention_within_selection?
        invention_metadata = @client_state.core.invention_library.metadata_for_id(new_value)
        @interface_state.inventions_selected_category = invention_metadata.category
        @interface_state.inventions_selected_industry_type = invention_metadata.industry_type

      update_tree_state(@client_state.core.invention_library, @tree_options.series[0].data, @tree_options.series[0].links, @selected_invention_id, @hover_invention_id)
      @layout_locked = true
    hover_invention_id: (new_value, old_value) ->
      update_tree_state(@client_state.core.invention_library, @tree_options.series[0].data, @tree_options.series[0].links, @selected_invention_id, @hover_invention_id)
      @layout_locked = true

    selected_category:  (new_value, old_value) ->
      setTimeout(=>
        update_tree_state(@client_state.core.invention_library, @tree_options.series[0].data, @tree_options.series[0].links, @selected_invention_id, @hover_invention_id)  if @is_visible
      , 50)
    selected_industry_type:  (new_value, old_value) ->
      setTimeout(=>
        update_tree_state(@client_state.core.invention_library, @tree_options.series[0].data, @tree_options.series[0].links, @selected_invention_id, @hover_invention_id)  if @is_visible
      , 50)

  computed:
    is_visible: -> @client_state?.workflow_status == 'ready' && @client_state?.menu?.is_visible('research')

    interface_state: -> @client_state?.interface

    selected_category: -> @interface_state?.inventions_selected_category
    selected_industry_type: -> @interface_state?.inventions_selected_industry_type
    selected_invention_id: -> @interface_state?.inventions_selected_invention_id
    hover_invention_id: -> @interface_state?.inventions_hover_invention_id

    invention_data: ->
      inventions = {}
      to_search = []
      for invention in @inventions_for_company
        industry_type = invention.industry_type || 'GENERAL'
        if invention.category == @selected_category && industry_type == @selected_industry_type
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

    research_available: ->
      available = []
      for invention in @invention_data
        if invention.id?
          available.push { id: invention.id, text: @managers.translation_manager.text(invention.name_key) }
      _.sortBy(available, (invention) -> invention.text)
    research_in_progress: ->
      in_progres = []
      in_progres
    research_completed: ->
      completed = []
      completed


  methods:
    click_item: (item) ->
      return unless item.dataType == "node"
      @interface_state.inventions_selected_invention_id = item.data.name

    focus_item: (item) ->
      return unless item.dataType == 'node'
      @interface_state.inventions_hover_invention_id = item.data.name

    unfocus_item: (item) ->
      return unless item.dataType == 'node'
      @interface_state.inventions_hover_invention_id = '' if @interface_state.inventions_hover_invention_id == item.data.name

    select_invention: (invention_id) ->
      @interface_state.inventions_selected_invention_id = invention_id
</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

#research-tree-container
  grid-column-start: 2
  grid-column-end: 3
  grid-row-start: 2
  grid-row-end: 5
  margin: 0
  overflow: hidden
  z-index: 1150

.card
  overflow: hidden

  .card-header
    min-height: 3.4rem

  .card-header-title
    font-size: 1.15rem
    letter-spacing: .2rem
    padding-top: .6rem

  .card-content
    height: calc(100% - 3.2rem)
    padding: 0

    &.overall-container
      position: relative

    .columns
      height: 100%
      margin: 0
      padding: 0

    .tree-list-container
      height: calc(100% - 2rem)
      left: 0
      margin: 1rem 0
      overflow-y: scroll
      padding: 0 .5rem
      position: absolute
      top: 0
      width: 20rem

      .status-title
        border-bottom: 1px solid $sp-primary
        color: $sp-light
        font-size: .9rem
        font-weight: bold
        margin-bottom: .25rem
        padding-bottom: .25rem

        &:not(:first-child)
          margin-top: 1.5rem

    .tree-container
      height: 100%
      padding: 1rem
      padding-left: 0
      margin-left: 20rem
      width: calc(100% - 20rem)

    .echarts
      background-color: #000
      height: 100% !important
      margin: 0
      padding: 0
      width: 100% !important

.filter-items
  height: 2.6rem
  margin-bottom: .9rem
  position: relative
  text-align: center

  .filter-toggle
    border: 1px solid lighten($sp-primary-bg, 5%)
    display: inline-block
    padding: .4rem

    &:not(:first-child)
      margin-left: .5rem

    img
      filter: invert(75%) sepia(8%) saturate(1308%) hue-rotate(111deg) brightness(93%) contrast(83%)
      height: 1.6rem
      width: 1.6rem

      path
        fill: $sp-primary !important

    &:hover
      background-color: lighten($sp-primary-bg, 2.5%)

    &:active
      background-color: lighten($sp-primary-bg, 7.5%)

      img
        filter: invert(100%)

.filter-input-container
  height: 3.5rem
  margin-bottom: .5rem
  padding: .5rem 1rem

  input
    &:focus
      border-color: $sp-primary !important

.sp-menu
  height: calc(100% - .5rem - 4rem - 3.5rem - 3.5rem)
  overflow-x: hidden
  overflow-y: scroll


</style>
