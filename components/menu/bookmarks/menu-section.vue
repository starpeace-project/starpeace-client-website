<template lang='pug'>
.sp-section
  a(v-on:click.stop.prevent="toggle_section")
    span(v-show="has_items && !section_expanded")
      font-awesome-icon(:icon="['fas', 'plus-square']")
    span(v-show="has_items && section_expanded")
      font-awesome-icon(:icon="['fas', 'minus-square']")
    span.sp-folder-icon(v-show="!has_items")
      font-awesome-icon(:icon="['fas', 'square']")
    span.sp-section-label {{label_text}}
  .sp-menu-list(v-if='has_items', v-show="section_expanded")
    template(v-if='is_draggable')
      draggable(v-model='items_as_options', @start='start_move_item', @choose='choose_item', :move='move_item')
        transition-group(name='menu-section')
          .draggable-item.bookmark-item(v-for="child in items_as_options", :key="child.id")
            template(v-if="child.type == 'slot'")
              div.slot-item
            template(v-else-if="child.is_folder")
              section-folder(:item="child", :dragging_level="dragging_item_id == child.id ? dragging_item_level : -1", v-on:toggled='refresh_tree')
            template(v-else-if='true')
              section-item(:item='child', :dragging_level="dragging_item_id == child.id ? dragging_item_level : -1", v-on:selected='item_selected')
    template(v-else-if='true')
      .bookmark-item(v-for="child in items_as_options", :key="child.id")
        template(v-if="child.type == 'slot'")
        template(v-else-if="child.is_folder")
          section-folder(:item="child", v-on:toggled='refresh_tree')
        template(v-else-if='true')
          section-item(:item='child', v-on:selected='item_selected')

</template>

<script lang='coffee'>
import draggable from 'vuedraggable'

import SectionFolder from '~/components/menu/bookmarks/section-folder.vue'
import SectionItem from '~/components/menu/bookmarks/section-item.vue'

import CityIcon from '~/components/misc/city-icon.vue'
import CompanySealIcon from '~/components/misc/company-seal-icon.vue'
import IndustryTypeIcon from '~/components/misc/industry-type-icon.vue'

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

menu_item_from_bookmark = (managers, existing_option, bookmark_item, tree_item, order, level) ->
  {
    id: bookmark_item.id
    order: order
    level: level
    is_folder: bookmark_item.is_folder()
    has_children: Object.keys(tree_item.child_ids || {}).length
    type: bookmark_item.type
    seal_id: if bookmark_item.type == 'CORPORATION' then bookmark_item.seal_id else null
    industry_type: if bookmark_item.type == 'INDUSTRY' then bookmark_item.industry_type else null
    item_name: if bookmark_item.name_key? then managers.translation_manager.text(bookmark_item.name_key) else bookmark_item.name
    expanded: if existing_option? then existing_option.expanded else false
    attributes: {}
  }

name_for_item = (managers, item) -> if item.name_key?.length then managers.translation_manager.text(item.name_key) || item.name_key else item.name

tree_to_options = (managers, is_draggable, existing_options_by_id, items_by_id, items_as_tree) ->
  children = []
  add_flattened_child = (level, tree_item) =>
    bookmark_item = items_by_id[tree_item.id]
    existing_option = existing_options_by_id[tree_item.id]
    menu_item = menu_item_from_bookmark(managers, existing_option, bookmark_item, tree_item, children.length, level)
    children.push menu_item

    if tree_item.child_ids?
      child_ids = Object.keys(tree_item.child_ids)
      if child_ids.length && menu_item.expanded
        for tree_child_id in _.sortBy(child_ids, (item_id) -> if is_draggable then items_by_id[item_id].order else name_for_item(managers, items_by_id[item_id]))
          add_flattened_child(level + 1, tree_item.child_ids[tree_child_id])

      unless !is_draggable || child_ids.length && !menu_item.expanded
        children.push menu_item_slot("slot-#{tree_item.id}", children.length, level + 1)

  for item_id in _.sortBy(Object.keys(items_as_tree), (item_id) -> if is_draggable then items_by_id[item_id].order else name_for_item(managers, items_by_id[item_id]))
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

    'section-folder': SectionFolder
    'section-item': SectionItem

    'company-seal-icon': CompanySealIcon
    'city-icon': CityIcon
    'industry-type-icon': IndustryTypeIcon

  name: 'menu-section'
  props:
    managers: Object
    client_state: Object

    root_id: String
    label_text: String
    items_by_id: Object

    is_draggable: Boolean

  mounted: ->
    if @root_id == 'bookmarks'
      @$root.$on('add_folder_action', () => @section_expanded = true unless @section_expanded)
      @$root.$on('add_bookmark_action', () => @section_expanded = true unless @section_expanded)

    @client_state?.options?.subscribe_options_listener => @refresh_tree()

  data: ->
    items_as_tree = @items_to_tree(@items_by_id)
    {
      section_expanded: false
      items_as_tree: items_as_tree
      items_as_options: tree_to_options(@managers, @is_draggable, {}, @items_by_id, items_as_tree)

      dragging_item_id: null
      dragging_item_level: 0
    }

  watch:
    items_hash: (new_value, old_value) ->
      @items_as_tree = @items_to_tree(@items_by_id)
      @refresh_tree()

    items_as_options: (new_value, old_value) ->
      if @is_draggable
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

        await @managers.bookmark_manager.merge_bookmark_deltas(deltas) if deltas.length

  computed:
    bookmark_metadata: -> @managers.bookmark_manager

    has_items: -> Object.keys(@items_by_id).length
    items_hash: ->
      hash = ''
      hash = "#{hash}#{item.id}#{item.parent_id}#{item.order}" for item in _.values(@items_by_id)
      hash

    options_by_id: ->
      by_id = {}
      for item in @items_as_options
        by_id[item.id] = item if item?
      by_id

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

    refresh_tree: () ->
      @items_as_options = tree_to_options(@managers, @is_draggable, @options_by_id, @items_by_id, @items_as_tree)


    item_selected: (item_id) ->
      return unless @items_by_id[item_id]?
      item = @items_by_id[item_id]
      @client_state.interface.select_building_id(item.building_id) if (item.type == 'TOWN' || item.type == 'BUILDING') && item.building_id?
      @client_state.camera.recenter_at(item.map_x, item.map_y) if item.type == 'TOWN' || item.type == 'LOCATION' || item.type == 'BUILDING'


    start_move_item: (event) ->
      if @items_as_options[event?.oldIndex]? && @index_levels[event?.oldIndex]?
        @dragging_item_id = @items_as_options[event?.oldIndex].id
        @dragging_item_level = @index_levels[event?.oldIndex]

    choose_item: (event) ->
      if @items_as_options[event?.oldIndex]? && @index_levels[event?.oldIndex]?
        @dragging_item_id = @items_as_options[event?.oldIndex].id
        @dragging_item_level = @index_levels[event?.oldIndex]

    move_item: (event) ->
      relatedElement = event?.relatedContext?.element
      draggedElement = event?.draggedContext?.element

      future_index = event?.draggedContext.futureIndex
      future_index += 1 if event?.draggedContext.futureIndex > event?.draggedContext.index

      can_move = (!relatedElement? || !relatedElement.fixed) && !draggedElement.fixed && (!draggedElement.has_children || !draggedElement.expanded)
      if can_move
        @dragging_item_level = @index_levels[future_index]
        draggedElement.attributes.future_level = @index_levels[future_index]
      can_move


    items_to_tree: (items_by_id) ->
      pending_items = []
      pending_items.push item for item in _.values(items_by_id)

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

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

.draggable-item
  transition: all .25s
  transition: color 0
  transition: background-color 0
  transition: display 0

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

    &.disabled,
    &.is-empty-folder
      cursor: not-allowed

    .sp-folder-icon
      display: inline-block
      min-width: 1.25rem
      text-align: center

    .sp-folder-label
      margin-left: .5rem

    .company-icon-wrapper
      height: 1.2rem
      width: 1.2rem

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
  display: inline-block
  min-width: 1.25rem
  text-align: center

.link-label
  font-size: 1rem
  padding-left: .5rem

</style>
