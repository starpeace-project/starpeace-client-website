<template lang='pug'>
#bookmarks-container.card.is-starpeace.has-header
  .card-header
    .card-header-title {{translate('ui.menu.bookmarks.header')}}
    .card-header-icon.card-close(v-on:click.stop.prevent="client_state.menu.toggle_menu('bookmarks')")
      font-awesome-icon(:icon="['fas', 'times']")
  .card-content.sp-menu-background.overall-container
    .field.filter-input-container
      .control.has-icons-left.is-expanded
        input.input(type="text", :placeholder="translate('misc.filter')")
        span.icon.is-left
          font-awesome-icon(:icon="['fas', 'search-location']")
    .filter-items
      a.filter-toggle.tooltip.is-tooltip-top(:class="filter_class('services')", v-on:click.stop.prevent="toggle_filter('services')", :data-tooltip="translate('ui.menu.bookmarks.filter.services')")
        img(src='~/assets/images/icons/services/headquarters.svg')
      a.filter-toggle.tooltip.is-tooltip-top(:class="filter_class('industries')", v-on:click.stop.prevent="toggle_filter('industries')", :data-tooltip="translate('ui.menu.bookmarks.filter.industries')")
        img(src='~/assets/images/icons/industries/factory.svg')
      a.filter-toggle.tooltip.is-tooltip-top(:class="filter_class('logistics')", v-on:click.stop.prevent="toggle_filter('logistics')", :data-tooltip="translate('ui.menu.bookmarks.filter.logistics')")
        img(src='~/assets/images/icons/logistics/warehouse.svg')
      a.filter-toggle.tooltip.is-tooltip-top(:class="filter_class('commerce')", v-on:click.stop.prevent="toggle_filter('commerce')", :data-tooltip="translate('ui.menu.bookmarks.filter.commerce')")
        img(src='~/assets/images/icons/commerce/shop.svg')
      a.filter-toggle.tooltip.is-tooltip-top(:class="filter_class('civics')", v-on:click.stop.prevent="toggle_filter('civics')", :data-tooltip="translate('ui.menu.bookmarks.filter.civics')")
        img(src='~/assets/images/icons/civics/fountain.svg')
      a.filter-toggle.tooltip.is-tooltip-top(:class="filter_class('residentials')", v-on:click.stop.prevent="toggle_filter('residentials')", :data-tooltip="translate('ui.menu.bookmarks.filter.residentials')")
        img(src='~/assets/images/icons/residentials/lower.svg')
      a.filter-toggle.tooltip.is-tooltip-top(:class="filter_class('offices')", v-on:click.stop.prevent="toggle_filter('offices')", :data-tooltip="translate('ui.menu.bookmarks.filter.offices')")
        img(src='~/assets/images/icons/offices/office-block.svg')

    aside.sp-menu.sp-scrollbar
      menu-section(v-if='show_poi && (show_towns || show_mausoleums)', :client_state='client_state', :managers='managers', root_id='bookmark-poi', :label_text="translate('ui.menu.bookmarks.section.poi')", :items_by_id='poi_items_by_id')
      menu-section(v-if='show_corporation && has_corporation', :client_state='client_state', :managers='managers', root_id='bookmark-corporation', :label_text="translate('ui.menu.bookmarks.section.corporation')", :items_by_id='corporation_items_by_id')
      menu-section(v-if='has_corporation', :client_state='client_state', :managers='managers', root_id='bookmarks', :label_text="translate('ui.menu.bookmarks.section.bookmarks')", :items_by_id='bookmark_items_by_id', is_draggable=true)

    .actions-container.level.is-mobile
      .level-item.action-column
        a.button.is-small.is-fullwidth.is-starpeace(disabled='disabled') {{translate('ui.menu.bookmarks.action.organize')}}
      .level-item.action-column
        a.button.is-small.is-fullwidth.is-starpeace(:disabled='actions_disabled', v-on:click.stop.prevent='add_folder') {{translate('ui.menu.bookmarks.action.add-folder')}}
      .level-item.action-column
        a.button.is-small.is-fullwidth.is-starpeace(:disabled='actions_disabled', v-on:click.stop.prevent='add_bookmark') {{translate('ui.menu.bookmarks.action.add-bookmark')}}

</template>

<script lang='coffee'>
import Bookmark from '~/plugins/starpeace-client/bookmark/bookmark.coffee'
import BookmarkFolder from '~/plugins/starpeace-client/bookmark/bookmark-folder.coffee'

import MenuSection from '~/components/menu/bookmarks/menu-section.vue'

export default
  components:
    'menu-section': MenuSection

  props:
    managers: Object
    ajax_state: Object
    client_state: Object

  data: ->
    menu_visible: @client_state?.menu?.is_visible('bookmarks')

    filter_input_value: ''

    show_towns: @client_state.options.option('bookmarks.towns')
    show_mausoleums: @client_state.options.option('bookmarks.mausoleums')
    show_poi: @client_state.options.option('bookmarks.points_of_interest')
    show_corporation: @client_state.options.option('bookmarks.corporation')

  mounted: ->
    @client_state.options?.subscribe_options_listener =>
      @show_towns = @client_state.options.option('bookmarks.towns')
      @show_mausoleums = @client_state.options.option('bookmarks.mausoleums')
      @show_poi = @client_state.options.option('bookmarks.points_of_interest')
      @show_corporation = @client_state.options.option('bookmarks.corporation')

    @client_state?.menu?.subscribe_menu_listener =>
      @menu_visible = @client_state?.menu?.is_visible('bookmarks')

  computed:
    is_ready: -> @client_state.workflow_status == 'ready'
    has_corporation: -> if @is_ready then @client_state.is_tycoon() && @client_state.player.corporation_id?.length else false

    poi_items_by_id: ->
      items_by_id = {}
      if @is_ready
        if @show_towns && @client_state.bookmarks.town_items?.length
          items_by_id[item.id] = item for item in @client_state.bookmarks.town_items

        if @show_mausoleums && @client_state.bookmarks.mausoleum_items?.length
          items_by_id[item.id] = item for item in @client_state.bookmarks.mausoleum_items
      items_by_id

    corporation_items_by_id: ->
      by_id = {}
      if @is_ready
        for company_id,company_items of @client_state.bookmarks.company_folders_by_id
          by_id[company_items.root.id] = company_items.root if company_items.root?

          for industry_type,industry_items of company_items.by_industry_type
            by_id[industry_items.root.id] = industry_items.root if industry_items.root?

            for building_id,building_item of industry_items.items_by_id
              by_id[building_item.id] = building_item
      by_id

    bookmark_items_by_id: -> if @is_ready then @client_state?.bookmarks.bookmarks_by_id else {}

    actions_disabled: ->
      return true unless @is_ready && @has_corporation

      @ajax_state.request_mutex.bookmark_metadata?[@client_state.player.corporation_id] ||
          @ajax_state.request_mutex.update_bookmark?[@client_state.player.corporation_id] ||
          @ajax_state.request_mutex.new_bookmark_folder?[@client_state.player.corporation_id] ||
          @ajax_state.request_mutex.new_bookmark_item?[@client_state.player.corporation_id]

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    filter_class: (type) ->
      ""
    toggle_filter: (type) ->
      console.log "toggle #{type}"

    add_folder: () ->
      @managers?.bookmark_manager?.new_bookmark_folder().then =>
        @$root.$emit('add_folder_action')

    add_bookmark: () ->
      @managers?.bookmark_manager?.new_bookmark_item().then =>
        @$root.$emit('add_bookmark_action')


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

  .card-header-title
    font-size: 1.15rem

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
  width: 100%
  position: absolute

.actions-container
  position: absolute
  bottom: .5rem
  height: 3rem
  padding: .5rem
  width: 100%

  .level-item
    &:not(:last-child)
      margin-right: .25rem

    a
      padding-left: 0.25em
      padding-right: 0.25em

</style>
