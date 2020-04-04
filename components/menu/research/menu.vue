<template lang='pug'>
#research-menu-container.card.is-starpeace.has-header
  .card-header
    .card-header-title {{translate('ui.menu.research.header')}}
  .card-content.sp-menu-background.overall-container
    .field.filter-input-container
      .control.has-icons-left.is-expanded
        input.input(type="text", :placeholder="translate('misc.filter')")
        span.icon.is-left
          font-awesome-icon(:icon="['fas', 'search-location']")

    aside.sp-menu.sp-scrollbar
      p.sp-section(v-for='item in sections')
        a(v-on:click.stop.prevent="item.expanded = !item.expanded")
          span(v-show="item.children.length && !item.expanded")
            font-awesome-icon(:icon="['fas', 'plus-square']")
          span(v-show="item.children.length && item.expanded")
            font-awesome-icon(:icon="['fas', 'minus-square']")
          span.sp-folder-icon(v-show="!item.children.length")
            font-awesome-icon(:icon="['fas', 'square']")
          span.sp-section-label {{item.name}}

        ul.sp-section-items(v-show="item.children.length && item.expanded")
          li(v-for="child in item.children")
            a.is-menu-item(v-on:click.stop.prevent="select_inventions(item.industry_category_id, child.industry_type_id)", :class="section_item_class(item, child)")
              industry-type-icon(:industry_type="child.industry_type_id", :class="['sp-section-item-image', 'sp-indusry-icon']", :default_research='true')
              span.sp-section-item-label {{child.name}}

</template>

<script lang='coffee'>
import IndustryTypeIcon from '~/components/misc/industry-type-icon.vue'

export default
  components:
    'industry-type-icon': IndustryTypeIcon

  props:
    managers: Object
    client_state: Object

  data: ->
    menu_visible: @client_state?.menu?.is_visible('research')

    filter_input_value: ''

    sections: []

  mounted: ->
    @client_state?.menu?.subscribe_menu_listener =>
      @menu_visible = @client_state?.menu?.is_visible('research')

    @client_state?.options?.subscribe_options_listener => @refresh_sections()

  watch:
    is_visible: (new_value, old_value) ->
      @refresh_sections() if new_value
    selected_category_id: (new_value, old_value) ->
      @refresh_sections()
    company_id: (new_value, old_value) ->
      @refresh_sections()

  computed:
    is_visible: -> @client_state.workflow_status == 'ready' && @menu_visible

    selected_category_id: -> @client_state.interface.inventions_selected_category_id
    selected_industry_type_id: -> @client_state.interface.inventions_selected_industry_type_id

    company_id: -> @client_state.player.company_id

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    filter_class: (type) -> ""
    section_item_class: (item, child) -> { 'is-active': @selected_category_id == item.industry_category_id && @selected_industry_type_id == child.industry_type_id }

    refresh_sections: () ->
      sections_by_category = {}
      for invention in @inventions_for_company()
        unless sections_by_category[invention.industry_category_id]?

          category = @client_state.core.planet_library.category_for_id(invention.industry_category_id)
          sections_by_category[invention.industry_category_id] = {
            name: if category? then @translate(category.label) else invention.industry_category_id
            industry_category_id: invention.industry_category_id
            expanded: invention.industry_category_id == @selected_category_id
            children_by_type: {}
          }
        type_id = invention.industry_type_id || 'GENERAL'
        unless sections_by_category[invention.industry_category_id].children_by_type[type_id]?
          industry_type = @client_state.core.planet_library.type_for_id(type_id)
          sections_by_category[invention.industry_category_id].children_by_type[type_id] = {
            name: if industry_type? then @translate(industry_type.label) else type_id
            industry_type_id: invention.industry_type_id
          }

      sections = []
      for category_id in @client_state.core.planet_library.categories_for_inventions()
        if sections_by_category[category_id]?
          section = sections_by_category[category_id]
          section.children = _.sortBy(_.values(section.children_by_type), (child) -> child.name)
          sections.push section

      @sections = sections

    inventions_for_company: -> @client_state.inventions_for_company()

    select_inventions: (industry_category_id, industry_type_id) ->
      @client_state.interface.inventions_selected_category_id = industry_category_id
      @client_state.interface.inventions_selected_industry_type_id = industry_type_id

</script>

<style lang='sass' scoped>
$sp-primary: #6ea192
$sp-primary-bg: #395950

#research-menu-container
  grid-column-start: 1
  grid-column-end: 2
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
    padding-top: .65rem

  .card-content
    height: calc(100% - 3.6rem)
    padding: 0

    &.overall-container
      padding-top: .5rem
      position: relative

.filter-input-container
  height: 3.5rem
  margin-bottom: .5rem
  padding: .5rem 1rem

  input
    &:focus
      border-color: $sp-primary !important

.sp-menu
  height: calc(100% - .5rem - 4rem)
  overflow-x: hidden
  overflow-y: scroll
  position: absolute
  width: 100%

  .sp-section
    border-bottom: 1px solid darken($sp-primary-bg, 7.5%)
    border-left: 0
    border-right: 0

    > a
      background-color: darken($sp-primary-bg, 3%)
      display: inline-block
      font-size: .8em
      letter-spacing: .1em
      padding: .75rem 1rem
      text-transform: uppercase
      width: 100%

      &:not(.disabled)
        &:hover,
        &.is-hover
          background-color: $sp-primary-bg

        &:active,
        &.is-active
          color: lighten($sp-primary, 20%)

    &:first-child
      border-top: 1px solid darken($sp-primary-bg, 7.5%)

    .sp-section-label
      margin-left: 1rem

    .sp-section-items
      a
        &.is-menu-item
          background-color: darken($sp-primary-bg, 15%)
          border-bottom: 1px solid darken($sp-primary-bg, 17.5%)
          display: inline-block
          padding-bottom: .75rem
          padding-top: .75rem
          position: relative
          width: 100%

          &:hover,
          &.is-hover
            background-color: darken($sp-primary-bg, 12.5%)
            border-bottom: 1px solid darken($sp-primary-bg, 15%)

          &:active,
          &.is-active
            background-color: darken($sp-primary-bg, 10%)
            border-bottom: 1px solid darken($sp-primary-bg, 12.5%)

      .sp-section-item-image
        border: 0
        padding: 0
        position: absolute
        left: .5rem
        top: calc(50% - .6rem)

      .sp-section-item-label
        font-size: 1.15rem
        margin-left: 2.3rem
        text-transform: capitalize

</style>
