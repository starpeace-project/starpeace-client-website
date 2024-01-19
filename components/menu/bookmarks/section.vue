<template lang='pug'>
.sp-section
  a(@click.stop.prevent='toggleSection')
    span(v-if='flattenedMenuItems.length > 0')
      font-awesome-icon(v-show='!section_expanded' :icon="['fas', 'plus-square']")
      font-awesome-icon(v-show='section_expanded' :icon="['fas', 'minus-square']")
    span.sp-folder-icon(v-else)
      font-awesome-icon(:icon="['fas', 'square']")
    span.sp-section-label {{$translate(labelKey)}}

  .sp-menu-list(v-if='flattenedMenuItems.length > 0' v-show='section_expanded' :style='draggingLevelStyle')
    template(v-if='draggable && false')
      draggable-list(v-model='flattenedMenuItems' @start='startDragItem' @change='dragItem' @end='endDragItem' @update='updateItem')
        template(#item='{ item }')
          .bookmark-item.draggable-item(:key='item.id' :data-id='item.id')
            template(v-if="item.type == 'SLOT'")
              div.slot-item(v-if="draggingItemId && ('slot-' + draggingItemId) != item.id")
            template(v-else-if="item.folder")
              menu-bookmarks-section-folder(:item="item" @toggle='toggleFolder')
            template(v-else)
              menu-bookmarks-section-item(:item='item' @select='selectBookmark')


    template(v-else)
      .bookmark-item(v-for="child in flattenedMenuItems" :key="child.id")
        template(v-if="child.type == 'SLOT'")
        template(v-else-if="child.folder")
          menu-bookmarks-section-folder(:item="child" @toggle='toggleFolder')
        template(v-else)
          menu-bookmarks-section-item(:item='child' @select='selectBookmark')

</template>

<script lang='ts'>
import _ from 'lodash';

import { type SortableStopEvent } from '@shopify/draggable';

import Bookmark from '~/plugins/starpeace-client/bookmark/bookmark';
import BookmarkMenuItem from '~/plugins/starpeace-client/bookmark/bookmark-menu-item';
import BookmarkMenuItems from '~/plugins/starpeace-client/bookmark/bookmark-menu-items';

declare interface SectionData {
  actionCounter: number;
  section_expanded: boolean;
  draggingItemId: string | undefined;
  draggingItemLevel: number;
}

declare interface MoveEvent {
  oldIndex: number;
  newIndex: number;
}

export default {
  props: {
    client_state: { type: Object, required: false },

    rootId: { type: String, required: true },
    labelKey: { type: String, required: true },
    bookmarkById: { type: Object, required: true },

    draggable: { type: Boolean, required: false, default: false }
  },

  mounted (): void {
    //if @rootId == 'bookmarks'
    //  @$root.$on('add_folder_action', () => @section_expanded = true unless @section_expanded)
    //  @$root.$on('add_bookmark_action', () => @section_expanded = true unless @section_expanded)

    this.client_state?.options?.subscribe_options_listener(() => this.actionCounter++);
  },

  data (): SectionData {
    return {
      actionCounter: 0,
      section_expanded: false,

      draggingItemId: undefined,
      draggingItemLevel: 0
    };
  },

  watch: {
    items_as_options (new_value, old_value) {
      if (this.draggable) {
        this.persist_bookmark_updates();
      }
    }
  },

  computed: {
    draggingLevelStyle (): string {
      return `--dragging-level: ${((this.draggingItemId ? this.draggingItemLevel : 0) + 1) * 0.75}rem;`;
    },

    menuItems (): BookmarkMenuItems {
      return BookmarkMenuItems.create(this.bookmarkById, this.rootId);
    },

    flattenedMenuItems: {
      get (): Array<BookmarkMenuItem> {
        return this.actionCounter < 0 ? [] : this.menuItems.flatten((lhs: BookmarkMenuItem, rhs: BookmarkMenuItem): number => {
          if (lhs.order !== undefined && rhs.order !== undefined) {
            return lhs.order - rhs.order;
          }
          const lhsLabel = lhs.itemNameKey ? this.$translate(lhs.itemNameKey) : (lhs.itemName ?? '');
          const rhsLabel = rhs.itemNameKey ? this.$translate(rhs.itemNameKey) : (rhs.itemName ?? '');
          return lhsLabel.localeCompare(rhsLabel);
        });
      },
      set (items: Array<BookmarkMenuItem>): void {
        // handled with events
      }
    }
  },

  methods: {
    toggleSection (): void {
      this.section_expanded = !this.section_expanded;
    },

    selectBookmark (itemId: string): void {
      const item = this.menuItems.byId[itemId];
      if (!item || item.folder || !this.client_state) return;
      if (item.mapX !== undefined && item.mapY !== undefined) {
        this.client_state.jump_to(item.mapX, item.mapY, item.buildingId);
        this.actionCounter++;
      }
    },
    toggleFolder (itemId: string): void {
      const item = this.menuItems.byId[itemId];
      const bookmark = this.bookmarkById[itemId];
      if (!item || !item.folder || !item.hasChildren || !bookmark || !this.client_state) return;

      bookmark.expanded = !bookmark.expanded;
      this.actionCounter++;
    },

    parentItemForIndex (beforeIndex: number, afterIndex: number): BookmarkMenuItem | undefined {
      let parentIndex: number = afterIndex - (afterIndex < beforeIndex ?  1 : 0);
      let skipNextFolderCount: number = 0;
      while (parentIndex >= 0) {
        if (parentIndex === beforeIndex || !this.flattenedMenuItems[parentIndex]) {
          // skip item
        }
        else if (this.flattenedMenuItems[parentIndex].type === 'SLOT') {
          skipNextFolderCount++;
        }
        else if (this.flattenedMenuItems[parentIndex].folder && (this.flattenedMenuItems[parentIndex].expanded || !this.flattenedMenuItems[parentIndex].hasChildren)) {
          if (skipNextFolderCount <= 0) {
            return this.flattenedMenuItems[parentIndex];
          }
          skipNextFolderCount--;
        }
        parentIndex--;
      }
      return undefined;
    },

    updateItem (event: any): void {
      const oldIndex: number = event.oldIndex;
      const newIndex: number = event.newIndex;
      if (newIndex < 0 || newIndex >= this.flattenedMenuItems.length || oldIndex >= this.flattenedMenuItems.length) {
        return;
      }

      const item: BookmarkMenuItem = this.flattenedMenuItems[oldIndex];
      const parent: BookmarkMenuItem | undefined = this.parentItemForIndex(oldIndex, newIndex);
      const newParentId: string = parent?.id ?? 'bookmarks';

      const updates = [];
      if (this.bookmarkById[item.id] && this.bookmarkById[item.id].parentId !== newParentId) {
        this.bookmarkById[item.id].parentId = newParentId;
        updates.push({
          id: item.id,
          parentId: newParentId
        });
      }

      const items = [];
      for (let index = 0; index < this.flattenedMenuItems.length; index++) {
        if (index == oldIndex) {
          // skip item
          continue;
        }
        if (this.flattenedMenuItems[index].type !== 'SLOT' && this.flattenedMenuItems[index].parentId === newParentId) {
          items.push(this.flattenedMenuItems[index]);
        }
        if (items.length == newIndex) {
          items.push(item);
        }
      }

      for (let index = 0; index < items.length; index++) {
        const bookmark: Bookmark | undefined = this.bookmarkById[items[index].id];
        if (bookmark && bookmark.order !== index) {
          bookmark.order = index;
          updates.push({
            id: bookmark.id,
            order: index
          });
        }
      }

      if (updates.length) {
        this.actionCounter++;
      }
    },
    startDragItem (event: any): void {
      const item = this.flattenedMenuItems[event.startIndex];
      if (item) {
        this.draggingItemId = item.id;
        this.draggingItemLevel = item.level;
      }
    },
    dragItem (event: any): void {
      const oldIndex: number = event.oldIndex;
      const newIndex: number = event.newIndex;
      const parent: BookmarkMenuItem | undefined = this.parentItemForIndex(oldIndex, newIndex);
      if (parent) {
        this.draggingItemLevel = parent.level + 1;
      }
      else {
        this.draggingItemLevel = 0;
      }
    },
    endDragItem (event: SortableStopEvent): void {
      this.draggingItemId = undefined;
      this.draggingItemLevel = 0;
    },

    persist_bookmark_updates () {
      // this.$debounce(1000, async () => {
      //   const pending_items = [];
      //   for (const [index, item] of Object.entries({})) { //this.items_as_options
      //     // item.order = index;
      //     pending_items.push(item);
      //   }
      //   const tree_pairs = options_to_tree_pairs(pending_items, this.rootId, 0);

      //   const deltas: Array<any> = [];
      //   const add_to_delta = (item: any) => {
      //     const bookmark_item = this.bookmarkById[item.id]
      //     if (bookmark_item.parentId !== item.parentId || bookmark_item.order !== item.order) {
      //       deltas.push(item);
      //     }
      //     for (const child of (item.children ?? [])) {
      //       add_to_delta(child);
      //     }
      //   };

      //   for (const item of tree_pairs) {
      //     add_to_delta(item);
      //   }

      //   if (deltas.length) {
      //     await this.$starpeaceClient.managers.bookmark_manager.merge_bookmark_deltas(deltas);
      //   }
      // });
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.draggable-item
  transition: all .25s
  transition: color 0
  transition: background-color 0
  transition: display 0

.slot-item
  width: 100%
  height: .25rem

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

    .sp-section-label
      margin-left: 1rem

  .is-folder-item
    background-color: darken($sp-primary-bg, 9%)
    border-bottom: 1px solid darken($sp-primary-bg, 11%)
    display: inline-block
    padding: .5rem .75rem
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
  padding: .5rem .75rem
  width: 100%

  &:hover
    background-color: darken($sp-primary-bg, 12.5%)
    border-bottom: 1px solid darken($sp-primary-bg, 15%)

  &:active
    color: #8bb3a7 !important
    font-weight: normal


:deep(.draggable-source--is-dragging)
  .is-menu-item
    padding-left: var(--dragging-level) !important

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
