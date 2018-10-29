<template lang='haml'>
.sp-section
  %a.sp-level-0{'v-on:click.stop.prevent':"toggle_section"}
    %span{'v-show':"items.length && !section_expanded"}
      %font-awesome-icon{':icon':"['fas', 'plus-square']"}
    %span{'v-show':"items.length && section_expanded"}
      %font-awesome-icon{':icon':"['fas', 'minus-square']"}
    %span.sp-folder-icon{'v-show':"!items.length"}
      %font-awesome-icon{':icon':"['fas', 'square']"}
    %span.sp-section-label {{label_text}}
  .sp-menu-list{'v-if':'items.length', 'v-show':"section_expanded", ':class':'menu_container_dragging_class'}
    %template{'v-if':'draggable'}
      %draggable{'v-model':'items_as_options', '@start':'start_move_item', '@choose':'choose_item', ':move':'move_item'}
        %transition-group{name:'menu-section'}
          %div.draggable-item{'v-for':"child in items_as_options", ':key':"child.id", ':class':"'menu-level-'+child.level"}
            %template{'v-if':"child.type == 'slot'"}
              %div.slot-item
            %template{'v-else-if':"child.is_folder", 'v-bind:item':'child'}
              %a.is-folder-item{'v-on:click.stop.prevent':"toggle_item(child)"}
                %template{'v-if':"child.type == 'CORPORATION'"}
                  %company-seal-icon{'v-bind:seal_id':"child.seal"}
                %template{'v-else-if':"child.type == 'TOWN'"}
                  %city-icon
                %template{'v-else-if':"true"}
                  %span.sp-folder-icon{'v-show':"child.has_children && !child.expanded"}
                    %font-awesome-icon{':icon':"['fas', 'folder']"}
                  %span.sp-folder-icon{'v-show':"child.has_children && child.expanded"}
                    %font-awesome-icon{':icon':"['fas', 'folder-open']"}
                  %span.sp-folder-icon{'v-show':"!child.has_children"}
                    %font-awesome-icon{':icon':"['far', 'folder']"}
                %span.sp-folder-label {{child.item_name}}
            %template{'v-else-if':'true'}
              %a.is-menu-item
                %span.link-image
                  %template{'v-if':"child.type == 'TOWN'"}
                    %city-icon
                  %template{'v-else-if':"true"}
                    %font-awesome-icon{':icon':"['fas', 'map-marker-alt']"}
                %span.link-label {{child.item_name}}
    %template{'v-else-if':'true'}
      %div{'v-for':"child in items_as_options", ':key':"child.id"}
        %template{'v-if':"child.type == 'slot'"}
        %template{'v-else-if':"child.is_folder"}
          %div.sp-folder{'v-show':"!child.hidden"}
            %a.is-folder-item{'v-on:click.stop.prevent':"toggle_item(child)"}
              %template{'v-if':"child.type == 'CORPORATION'"}
                %company-seal-icon{'v-bind:seal_id':"child.seal"}
              %template{'v-else-if':"child.type == 'TOWN'"}
                %city-icon
              %template{'v-else-if':"true"}
                %span.sp-folder-icon{'v-show':"child.has_children && !child.expanded"}
                  %font-awesome-icon{':icon':"['fas', 'folder']"}
                %span.sp-folder-icon{'v-show':"child.has_children && child.expanded"}
                  %font-awesome-icon{':icon':"['fas', 'folder-open']"}
                %span.sp-folder-icon{'v-show':"!child.has_children"}
                  %font-awesome-icon{':icon':"['far', 'folder']"}
              %span.sp-folder-label {{child.item_name}}
        %template{'v-else-if':'true'}
          %a.is-menu-item
            %span.link-image
              %template{'v-if':"child.type == 'TOWN'"}
                %city-icon
              %template{'v-else-if':"true"}
                %font-awesome-icon{':icon':"['fas', 'map-marker-alt']"}
            %span.link-label {{child.item_name}}

</template>

<script lang='coffee'>
import draggable from 'vuedraggable'
import CityIcon from '~/components/misc/city-icon.vue'
import CompanySealIcon from '~/components/misc/company-seal-icon.vue'

menu_item_slot = (id, order, level) ->
  {
    id: id
    order: order
    fixed: true
    level: level
    is_folder: false
    has_children: false
    type: 'slot'
    item_name: 'slot'
  }

menu_item_from_bookmark = (existing_option, bookmark_item, tree_item, order, level) ->
  {
    id: bookmark_item.id
    order: order
    level: level
    is_folder: bookmark_item.is_folder()
    has_children: Object.keys(tree_item.child_ids || {}).length
    type: bookmark_item.type
    seal: if bookmark_item.type == 'CORPORATION' then bookmark_item.seal else null
    item_name: bookmark_item.name
    hidden: false
    expanded: if existing_option? then existing_option.expanded else false
    attributes: {}
  }

tree_to_options = (existing_options_by_id, items_by_id, items_as_tree) ->
  children = []

  add_flattened_child = (level, tree_item) =>
    bookmark_item = items_by_id[tree_item.id]
    existing_option = existing_options_by_id[tree_item.id]
    menu_item = menu_item_from_bookmark(existing_option, bookmark_item, tree_item, children.length, level)
    children.push menu_item

    if tree_item.child_ids?
      child_ids = Object.keys(tree_item.child_ids)
      if child_ids.length && menu_item.expanded
        for tree_child_id in _.sortBy(child_ids, (item_id) -> items_by_id[item_id].order)
          add_flattened_child(level + 1, tree_item.child_ids[tree_child_id])
        children.push menu_item_slot("slot-#{tree_item.id}", children.length, level + 1)
      else if !child_ids.length
        children.push menu_item_slot("slot-#{tree_item.id}", children.length, level + 1)

  for item_id in _.sortBy(Object.keys(items_as_tree), (item_id) -> items_by_id[item_id].order)
    add_flattened_child(0, items_as_tree[item_id])

  children

options_to_tree_pairs = (pending_items, parent_id, level) ->
  items = []
  item_level = level
  last_item = null

  while pending_items.length && item_level >= level
    item_level = level_for_item(pending_items[0])
    if pending_items[0].type == 'slot'
      pending_items.shift()
    else if item_level > level
      last_item.children = options_to_tree_pairs(pending_items, last_item.id, level + 1) if last_item?
    else if item_level == level
      item = pending_items.shift()
      last_item = {
        id: item.id
        parent_id: parent_id
        order: item.order
        level: item.level
      }
      items.push last_item

  _.forEach(_.sortBy(items, (item) -> item.order), (item, index) -> item.order = index)


level_for_item = (item) -> if item.attributes?.future_level? && item.attributes?.future_level != item.level then item.attributes?.future_level else item.level

export default
  components:
    'draggable': draggable
    'company-seal-icon': CompanySealIcon
    'city-icon': CityIcon

  name: 'menu-section'
  props:
    bookmark_manager: Object
    root_id: String
    label_text: String
    items: Array
    draggable: Boolean

  data: ->
    section_expanded: false
    items_as_options: tree_to_options({}, @items_by_id || {}, @items_as_tree || {})

    future_level_after_dragging: 0

  watch:
    items_as_tree: (new_value, old_value) ->
      @items_as_options = tree_to_options(@options_by_id, @items_by_id, new_value)

    items_as_options: (new_value, old_value) ->
      pending_items = []
      for item,index in new_value
        item.order = index
        pending_items.push item
      tree_pairs = options_to_tree_pairs(pending_items, @root_id, 0)

      deltas = []
      add_to_delta = (item) =>
        bookmark_item = @items_by_id[item.id]
        deltas.push item unless bookmark_item.parent_id == item.parent_id && bookmark_item.order == item.order
        add_to_delta(child) for child in (item.children || [])
      add_to_delta(item) for item in tree_pairs

      @bookmark_manager.merge_bookmark_deltas(deltas)

  computed:
    menu_container_dragging_class: -> "menu-dragging-level-#{@future_level_after_dragging}"

    items_by_id: ->
      by_id = {}
      by_id[item.id] = item for item in @items
      by_id

    items_as_tree: ->
      pending_items = []
      pending_items.push item for item in @items

      roots = {}
      by_id = {}
      while pending_items.length
        item = pending_items.shift()
        if item.parent_id == @root_id
          by_id[item.id] = roots[item.id] = { id: item.id }
          by_id[item.id].child_ids = {} if item.is_folder()
        else if by_id[item.parent_id]
          by_id[item.id] = by_id[item.parent_id].child_ids[item.id] = { id: item.id }
          by_id[item.id].child_ids = {} if item.is_folder()
        else
          pending_items.push item
      roots

    options_by_id: ->
      items_by_id = {}
      for item in @items_as_options
        items_by_id[item.id] = item if item?
      items_by_id

    index_levels: ->
      index_level = {0: 0}
      last_level = 0
      for item,index in @items_as_options
        item_level = level_for_item(item)
        if item.type == 'slot'
          if item.level == last_level
            index_level[index] = last_level
            last_level -= 1
          else
            index_level[index] = item.level
        else
          last_level += 1 if item_level > last_level
          index_level[index] = last_level
      index_level


  methods:
    toggle_section: () -> @section_expanded = !@section_expanded

    toggle_item: (item) ->
      item.expanded = !item.expanded
      @items_as_options = tree_to_options(@options_by_id, @items_by_id, @items_as_tree)

    start_move_item: (event) ->
      @future_level_after_dragging = @index_levels[event?.oldIndex] if @index_levels[event?.oldIndex]?

    choose_item: (event) ->
      @future_level_after_dragging = @index_levels[event?.oldIndex] if @index_levels[event?.oldIndex]?

    move_item: (event) ->
      relatedElement = event?.relatedContext?.element
      draggedElement = event?.draggedContext?.element

      future_index = event?.draggedContext.futureIndex
      future_index += 1 if event?.draggedContext.futureIndex > event?.draggedContext.index

      can_move = (!relatedElement? || !relatedElement.fixed) && !draggedElement.fixed && (!draggedElement.has_children || !draggedElement.expanded)
      if can_move
        @future_level_after_dragging = @index_levels[future_index]
        draggedElement.attributes.future_level = @index_levels[future_index]
      can_move

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

.draggable-item
  transition: all .25s
  transition: color 0
  transition: background-color 0
  transition: display 0

  &.menu-level-0
    a
      padding-left: .75rem

  &.menu-level-1
    a
      padding-left: 1.5rem

  &.menu-level-2
    a
      padding-left: 2.25rem

  &.menu-level-3
    a
      padding-left: 3rem

.menu-dragging-level-0
  .sortable-chosen
    &.draggable-item
      a
        padding-left: .75rem !important

.menu-dragging-level-1
  .sortable-chosen
    &.draggable-item
      a
        padding-left: 1.5rem !important

.menu-dragging-level-2
  .sortable-chosen
    &.draggable-item
      a
        padding-left: 2.25rem !important

.menu-dragging-level-3
  .sortable-chosen
    &.draggable-item
      a
        padding-left: 3rem !important


.menu-section-leave-active
  transition: none

.slot-item
  width: 100%
  height: 0

.sp-menu
  height: calc(100% - .5rem - 4rem - 3.5rem - 3.5rem)
  overflow-x: hidden
  overflow-y: scroll

  .sp-section
    border-bottom: 1px solid darken($sp-primary-bg, 7.5%)
    border-left: 0
    border-right: 0

    > a
      background-color: darken($sp-primary-bg, 3%)
      display: inline-block
      font-size: .75em
      letter-spacing: .1em
      padding: .75rem 1rem
      text-transform: uppercase
      width: 100%

      &:not(.disabled)
        &:hover
          background-color: $sp-primary-bg

        &.active
          color: lighten($sp-primary, 20%)

    &:first-child
      border-top: 1px solid darken($sp-primary-bg, 7.5%)

    .sp-section-label
      margin-left: 1rem

  .is-folder-item
    background-color: darken($sp-primary-bg, 9%)
    border-bottom: 1px solid darken($sp-primary-bg, 11%)
    display: inline-block
    padding: .75rem .75rem
    width: 100%

    &:not(.disabled)
      &:hover
        background-color: darken($sp-primary-bg, 6.5%)
        border-bottom: 1px solid darken($sp-primary-bg, 9%)

      &:active
        color: #8bb3a7
        font-weight: normal

      &.active
        background-color: darken($sp-primary-bg, 4%)
        border-bottom: 1px solid darken($sp-primary-bg, 6%)

    .sp-folder-icon
      display: inline-block
      min-width: 1.25rem
      padding-left: .1rem

    .sp-folder-label
      margin-left: .5rem

  .sortable-chosen
    .is-folder-item
      color: #fff !important
      background-color: darken($sp-primary-bg, 4%) !important
      border-bottom: 1px solid darken($sp-primary-bg, 6%) !important
      font-weight: bold !important

  a
    &.disabled
      cursor: not-allowed


.is-menu-item
  background-color: darken($sp-primary-bg, 15%)
  border-bottom: 1px solid darken($sp-primary-bg, 17.5%)
  display: inline-block
  padding: .75rem .75rem
  width: 100%

  &:hover
    background-color: darken($sp-primary-bg, 12.5%)
    border-bottom: 1px solid darken($sp-primary-bg, 15%)

  &:active
    color: #8bb3a7 !important
    font-weight: normal

.sortable-chosen
  .is-menu-item
    color: #fff !important
    background-color: darken($sp-primary-bg, 10%)
    border-bottom: 1px solid darken($sp-primary-bg, 12.5%)
    font-weight: bold !important

.link-image
  border: 0
  padding: .25rem
  max-width: 2rem

.link-label
  font-size: 1rem
  padding-left: .5rem

</style>
