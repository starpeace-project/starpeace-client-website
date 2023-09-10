import Bookmark from '~/plugins/starpeace-client/bookmark/bookmark';
import BookmarkMenuItem from '~/plugins/starpeace-client/bookmark/bookmark-menu-item';

export default class BookmarkMenuItems {

  byId: Record<string, BookmarkMenuItem>;
  rootChildrenById: Record<string, BookmarkMenuItem>;

  constructor (byId: Record<string, BookmarkMenuItem>, rootChildrenById: Record<string, BookmarkMenuItem>) {
    this.byId = byId;
    this.rootChildrenById = rootChildrenById;
  }

  flatten (itemComparator: (lhs: BookmarkMenuItem, rhs: BookmarkMenuItem) => number): Array<BookmarkMenuItem> {
    return Object.values(this.rootChildrenById).sort(itemComparator).map(r => r.flatten(itemComparator)).flat();
  }


  static create (bookmarkById: Record<string, Bookmark>, rootId: string): BookmarkMenuItems {
    const byId: Record<string, BookmarkMenuItem> = {};
    for (const [bookmarkId, bookmark] of Object.entries(bookmarkById)) {
      byId[bookmarkId] = bookmark.toMenuItem();
    }

    const rootChildrenById: Record<string, BookmarkMenuItem> = {};
    for (const bookmark of Object.values(byId)) {
      if (bookmark.parentId === rootId) {
        rootChildrenById[bookmark.id] = bookmark;
      }
      else if (bookmark.parentId) {
        bookmark.parent = byId[bookmark.parentId];

        if (bookmark.parent) {
          bookmark.parent.childrenById[bookmark.id] = bookmark;
        }
      }
    }

    return new BookmarkMenuItems(byId, rootChildrenById);
  }
}
