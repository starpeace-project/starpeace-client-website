<template lang='haml'>
#bookmarks-container.card.has-header
  .card-header
    .card-header-title
      Map Locations
    .card-header-icon.card-close{'v-on:click.stop.prevent':"menu_state.toggle_menu('bookmarks')"}
      %font-awesome-icon{':icon':"['fas', 'times']"}
  .card-content.sp-menu-background.overall-container
    .field.filter-input-container
      .control.has-icons-left.is-expanded
        %input.input{type:"text", placeholder:"Filter"}
        %span.icon.is-left
          %font-awesome-icon{':icon':"['fas', 'search-location']"}
    .filter-items
      %a.filter-toggle.tooltip.is-tooltip-top{'v-bind:class':"filter_class('services')", 'v-on:click.stop.prevent':"toggle_filter('services')", 'data-tooltip':'Services'}
        %img{src:'~/assets/images/icons/services/headquarters.svg'}
      %a.filter-toggle.tooltip.is-tooltip-top{'v-bind:class':"filter_class('industries')", 'v-on:click.stop.prevent':"toggle_filter('industries')", 'data-tooltip':'Industries'}
        %img{src:'~/assets/images/icons/industries/factory.svg'}
      %a.filter-toggle.tooltip.is-tooltip-top{'v-bind:class':"filter_class('logistics')", 'v-on:click.stop.prevent':"toggle_filter('logistics')", 'data-tooltip':'Logistics'}
        %img{src:'~/assets/images/icons/logistics/warehouse.svg'}
      %a.filter-toggle.tooltip.is-tooltip-top{'v-bind:class':"filter_class('commerce')", 'v-on:click.stop.prevent':"toggle_filter('commerce')", 'data-tooltip':'Commerce'}
        %img{src:'~/assets/images/icons/commerce/shop.svg'}
      %a.filter-toggle.tooltip.is-tooltip-top{'v-bind:class':"filter_class('civics')", 'v-on:click.stop.prevent':"toggle_filter('civics')", 'data-tooltip':'Civics'}
        %img{src:'~/assets/images/icons/civics/fountain.svg'}
      %a.filter-toggle.tooltip.is-tooltip-top{'v-bind:class':"filter_class('residentials')", 'v-on:click.stop.prevent':"toggle_filter('residentials')", 'data-tooltip':'Residentials'}
        %img{src:'~/assets/images/icons/residentials/lower.svg'}
      %a.filter-toggle.tooltip.is-tooltip-top{'v-bind:class':"filter_class('offices')", 'v-on:click.stop.prevent':"toggle_filter('offices')", 'data-tooltip':'Offices'}
        %img{src:'~/assets/images/icons/offices/office-block.svg'}
    %aside.sp-menu.sp-scrollbar
      %bookmark-item{'v-for':'item in sections', 'v-bind:item':'item', 'v-bind:key':'item.id'}
    .actions-container
      .action-column
        %a.button.is-fullwidth.is-starpeace{disabled:'disabled'} Organize
      .action-column
        %a.button.is-fullwidth.is-starpeace Add Bookmark
</template>

<script lang='coffee'>
import BookmarkItem from '~/components/menu/bookmarks/bookmark-item.vue'

export default
  components:
    'bookmark-item': BookmarkItem

  props:
    bookmark_manager: Object
    options: Object
    game_state: Object
    menu_state: Object

  watch:
    state_counter: (new_value, old_value) ->
      @sections = @bookmark_manager?.sections(@options) || []

  data: ->
    filter_input_value: ''

    sections: []

  computed:
    state_counter: -> @options.vue_state_counter + @bookmark_manager.vue_state_counter

  methods:
    filter_class: (type) ->
      ""
    toggle_filter: (type) ->
      console.log "toggle #{type}"

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

#bookmarks-container
  grid-column-start: 1
  grid-column-end: 2
  grid-row-start: 2
  grid-row-end: 4
  margin: 0
  overflow: hidden
  z-index: 1100

.card
  overflow: hidden

  .card-content
    height: calc(100% - 3.2rem)
    padding: 0

    &.overall-container
      padding-top: .5rem
      position: relative

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

.actions-container
  position: absolute
  bottom: .5rem
  height: 3rem
  padding: .5rem
  width: 100%

  .action-column
    display: inline-block
    width: calc(50% - .25rem)

    &:not(:first-child)
      margin-left: .5rem

</style>
