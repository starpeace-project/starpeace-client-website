<template lang='pug'>
#bookmarks-container.card.has-header.is-starpeace.sp-menu(:oncontextmenu="'return ' + !$config.public.disableRightClick")
  .card-header
    .card-header-title {{$translate('ui.menu.bookmarks.header')}}
    .card-header-icon.card-close(@click.stop.prevent="client_state.menu.toggle_menu('bookmarks')")
      font-awesome-icon(:icon="['fas', 'times']")

  .card-content.p-0.sp-menu-background.overall-container

    .field.filter-input-container
      .control.has-icons-left.is-expanded
        input.input(type="text", :placeholder="$translate('misc.filter')")
        span.icon.is-left
          font-awesome-icon(:icon="['fas', 'search-location']")
    misc-filter-industry-categories(:client_state='client_state')

    aside.sp-scrollbar
      menu-bookmarks-section(
        v-if='show_poi && (show_towns || show_mausoleums)'
        root-id='bookmark-poi'
        label-key='ui.menu.bookmarks.section.poi'
        :client_state='client_state'
        :bookmark-by-id='poi_items_by_id'
      )
      menu-bookmarks-section(
        v-if='show_corporation && hasCorporation'
        root-id='bookmark-corporation'
        label-key='ui.menu.bookmarks.section.companies'
        :client_state='client_state'
        :bookmark-by-id='corporation_items_by_id'
      )
      menu-bookmarks-section(
        v-if='hasCorporation'
        root-id='bookmarks'
        label-key='ui.menu.bookmarks.section.bookmarks'
        draggable
        :client_state='client_state'
        :bookmark-by-id='bookmark_items_by_id'
      )

    .actions-container.level.is-mobile
      .level-item.action-column
        button.button.is-small.is-fullwidth.is-starpeace(disabled='disabled') {{$translate('ui.menu.bookmarks.action.organize')}}
      .level-item.action-column
        button.button.is-small.is-fullwidth.is-starpeace(:disabled='actions_disabled' @click.stop.prevent='add_folder') {{$translate('ui.menu.bookmarks.action.add-folder')}}
      .level-item.action-column
        button.button.is-small.is-fullwidth.is-starpeace(:disabled='actions_disabled' @click.stop.prevent='add_bookmark') {{$translate('ui.menu.bookmarks.action.add-bookmark')}}

</template>

<script lang='ts'>
import AjaxState from '~/plugins/starpeace-client/state/ajax-state.js';
import ClientState from '~/plugins/starpeace-client/state/client-state';
import BookmarkState from '~/plugins/starpeace-client/state/player/bookmark-state.js';

import Bookmark from '~/plugins/starpeace-client/bookmark/bookmark.js';

export default {
  props: {
    ajax_state: { type: AjaxState, require: true },
    client_state: { type: ClientState, require: true }
  },

  data () {
    return {
      menu_visible: this.client_state?.menu?.is_visible('bookmarks'),

      filter_input_value: '',

      show_towns: this.client_state.options.option('bookmarks.towns'),
      show_mausoleums: this.client_state.options.option('bookmarks.mausoleums'),
      show_poi: this.client_state.options.option('bookmarks.points_of_interest'),
      show_corporation: this.client_state.options.option('bookmarks.corporation')
    };
  },

  mounted () {
    this.client_state.options?.subscribe_options_listener(() => {
      this.show_towns = this.client_state.options.option('bookmarks.towns');
      this.show_mausoleums = this.client_state.options.option('bookmarks.mausoleums');
      this.show_poi = this.client_state.options.option('bookmarks.points_of_interest');
      this.show_corporation = this.client_state.options.option('bookmarks.corporation');
    });

    this.client_state?.menu?.subscribe_menu_listener(() => {
      this.menu_visible = this.client_state.menu?.is_visible('bookmarks');
    });
  },

  computed: {
    is_ready (): boolean {
      return this.client_state.workflow_status === 'ready';
    },
    hasCorporation (): boolean {
      return this.is_ready && this.client_state.is_tycoon() && this.client_state.player.corporation_id?.length;
    },

    bookmarkState (): BookmarkState {
      return this.client_state.bookmarks;
    },

    poi_items_by_id (): Record<string, Bookmark> {
      if (!this.is_ready || !this.menu_visible) return {};
      const byId: Record<string, any> = {};
      if (this.show_towns && this.bookmarkState.townItems?.length) {
        for (const item of this.bookmarkState.townItems) {
          byId[item.id] = item;
        }
      }

      if (this.show_mausoleums && this.bookmarkState.mausoleumItems?.length) {
        for (const item of this.bookmarkState.mausoleumItems) {
          byId[item.id] = item;
        }
      }
      return byId;
    },

    corporation_items_by_id (): Record<string, any> {
      if (!this.is_ready || !this.menu_visible) return {};
      const by_id: Record<string, any> = {};
      for (const companyFolders of this.bookmarkState.companyFolders) {
        by_id[companyFolders.root.id] = companyFolders.root;

        for (const industryBookmarks of companyFolders.industryBookmarks) {
          by_id[industryBookmarks.root.id] = industryBookmarks.root;

          for (const buildingBookmark of industryBookmarks.bookmarks) {
            by_id[buildingBookmark.id] = buildingBookmark;
          }
        }
      }
      return by_id;
    },

    bookmark_items_by_id () {
      return this.is_ready && this.menu_visible ? this.client_state?.bookmarks.bookmarkById ?? {} : {};
    },

    actions_disabled () {
      if (!this.is_ready || !this.menu_visible || !this.hasCorporation) {
        return true;
      }
      return this.ajax_state.requestMutexByTypeKey.bookmark_metadata?.[this.client_state.player.corporation_id] ||
          this.ajax_state.requestMutexByTypeKey.update_bookmark?.[this.client_state.player.corporation_id] ||
          this.ajax_state.requestMutexByTypeKey.new_bookmark_folder?.[this.client_state.player.corporation_id] ||
          this.ajax_state.requestMutexByTypeKey.new_bookmark_item?.[this.client_state.player.corporation_id];
    }
  },

  methods: {
    async add_folder (): Promise<void> {
      try {
        await this.$starpeaceClient.managers?.bookmark_manager?.createFolder();
        this.$root?.$emit('add_folder_action');
      }
      catch (err) {
        console.error(err);
      }
    },

    async add_bookmark (): Promise<void> {
      try {
        await this.$starpeaceClient.managers?.bookmark_manager?.createBookmark();
        this.$root?.$emit('add_bookmark_action');
      }
      catch (err) {
        console.error(err);
      }
    }
  }
}

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
