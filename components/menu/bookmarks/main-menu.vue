<template lang='pug'>
#bookmarks-container.card.has-header.is-starpeace.sp-menu(:oncontextmenu="'return ' + !$config.public.disableRightClick")
  .card-header
    .card-header-title {{translate('ui.menu.bookmarks.header')}}
    .card-header-icon.card-close(v-on:click.stop.prevent="client_state.menu.toggle_menu('bookmarks')")
      font-awesome-icon(:icon="['fas', 'times']")

  .card-content.is-paddingless.sp-menu-background.overall-container

    .field.filter-input-container
      .control.has-icons-left.is-expanded
        input.input(type="text", :placeholder="translate('misc.filter')")
        span.icon.is-left
          font-awesome-icon(:icon="['fas', 'search-location']")
    misc-filter-industry-categories(:managers='managers' :client_state='client_state')

    aside.sp-scrollbar
      menu-bookmarks-section(
        v-if='show_poi && (show_towns || show_mausoleums)'
        root_id='bookmark-poi'
        :client_state='client_state'
        :managers='managers'
        :label_text="translate('ui.menu.bookmarks.section.poi')"
        :items_by_id='poi_items_by_id'
      )
      menu-bookmarks-section(
        v-if='show_corporation && has_corporation'
        root_id='bookmark-corporation'
        :client_state='client_state'
        :managers='managers'
        :label_text="translate('ui.menu.bookmarks.section.companies')"
        :items_by_id='corporation_items_by_id'
      )
      menu-bookmarks-section(
        v-if='has_corporation'
        root_id='bookmarks'
        is_draggable=true
        :client_state='client_state'
        :managers='managers'
        :label_text="translate('ui.menu.bookmarks.section.bookmarks')"
        :items_by_id='bookmark_items_by_id'
      )

    .actions-container.level.is-mobile
      .level-item.action-column
        button.button.is-small.is-fullwidth.is-starpeace(disabled='disabled') {{translate('ui.menu.bookmarks.action.organize')}}
      .level-item.action-column
        button.button.is-small.is-fullwidth.is-starpeace(:disabled='actions_disabled' @click.stop.prevent='add_folder') {{translate('ui.menu.bookmarks.action.add-folder')}}
      .level-item.action-column
        button.button.is-small.is-fullwidth.is-starpeace(:disabled='actions_disabled' @click.stop.prevent='add_bookmark') {{translate('ui.menu.bookmarks.action.add-bookmark')}}

</template>

<script lang='coffee'>
import Bookmark from '~/plugins/starpeace-client/bookmark/bookmark.coffee'
import BookmarkFolder from '~/plugins/starpeace-client/bookmark/bookmark-folder.coffee'

export default
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
      return {} unless @is_ready
      items_by_id = {}
      if @show_towns && @client_state.bookmarks.town_items?.length
        items_by_id[item.id] = item for item in @client_state.bookmarks.town_items

      if @show_mausoleums && @client_state.bookmarks.mausoleum_items?.length
        items_by_id[item.id] = item for item in @client_state.bookmarks.mausoleum_items
      items_by_id

    corporation_items_by_id: ->
      return {} unless @is_ready
      by_id = {}
      for company_id,company_items of @client_state.bookmarks.company_folders_by_id
        by_id[company_items.root.id] = company_items.root if company_items.root?

        for industry_type,industry_items of company_items.by_industry_type
          by_id[industry_items.root.id] = industry_items.root if industry_items.root?

          for building_id,building_item of industry_items.items_by_id
            by_id[building_item.id] = building_item
      by_id

    bookmark_items_by_id: ->
      return {} unless @is_ready
      @client_state?.bookmarks.bookmarks_by_id || {}

    actions_disabled: ->
      return true unless @is_ready && @has_corporation

      @ajax_state.request_mutex.bookmark_metadata?[@client_state.player.corporation_id] ||
          @ajax_state.request_mutex.update_bookmark?[@client_state.player.corporation_id] ||
          @ajax_state.request_mutex.new_bookmark_folder?[@client_state.player.corporation_id] ||
          @ajax_state.request_mutex.new_bookmark_item?[@client_state.player.corporation_id]

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    add_folder: () ->
      @managers?.bookmark_manager?.new_bookmark_folder()
        .then =>
          #@$root.$emit('add_folder_action')
        .catch (err) =>
          console.error(err)

    add_bookmark: () ->
      @managers?.bookmark_manager?.new_bookmark_item()
        .then =>
          @$root.$emit('add_bookmark_action')
        .catch (err) =>
          console.error(err)

</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'
@import '~/assets/stylesheets/starpeace-menus'

.sp-menu
  grid-column: start-left / end-render
  grid-row: start-render / end-inspect
  position: relative

  > .card-content
    grid-template-columns: 25rem 30% auto

#bookmarks-container
  grid-column: start-left / end-left
  grid-row: start-render / end-render
  overflow: hidden
  z-index: 1100

  .overall-container
    display: grid
    grid-template-columns: auto
    grid-template-rows: 4rem 3.5rem auto 3.5rem
    position: relative

  aside
    overflow-y: scroll

.filter-input-container
  padding: .5rem 1rem

  input
    &:focus
      border-color: $sp-primary !important

.actions-container
  padding: .5rem

  .level-item
    &:not(:last-child)
      margin-right: .25rem

    a
      padding-left: 0.25em
      padding-right: 0.25em

</style>
