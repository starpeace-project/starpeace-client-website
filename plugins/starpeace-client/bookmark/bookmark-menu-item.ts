import _ from 'lodash';

export default class BookmarkMenuItem {
  parentId: string;
  id: string;

  folder: boolean;
  expanded: boolean;

  type: string;

  order: number | undefined;
  itemNameKey: string | undefined;
  itemName: string | undefined;
  sealId: string | undefined;
  industryTypeId: string | undefined;

  mapX: number | undefined;
  mapY: number | undefined;
  buildingId: string | undefined;

  parent: BookmarkMenuItem | undefined = undefined;
  childrenById: Record<string, BookmarkMenuItem> = {};

  constructor (parentId: string, id: string, folder: boolean, expanded: boolean, type: string, order: number | undefined, itemNameKey: string | undefined, itemName: string | undefined, sealId: string | undefined, industryTypeId: string | undefined,   mapX: number | undefined, mapY: number | undefined, buildingId: string | undefined) {
    this.parentId = parentId;
    this.id = id;
    this.folder = folder;
    this.expanded = expanded;
    this.type = type;
    this.order = order;
    this.itemNameKey = itemNameKey;
    this.itemName = itemName;
    this.sealId = sealId;
    this.industryTypeId = industryTypeId;
    this.mapX = mapX;
    this.mapY = mapY;
    this.buildingId = buildingId;
  }

  get fixed (): boolean {
    return this.type === 'SLOT' || this.folder && this.expanded && this.hasChildren;
  }

  get level (): number {
    return (this.parent?.level ?? -1) + 1;
  }

  get hasChildren (): boolean {
    return Object.keys(this.childrenById).length > 0;
  }

  flatten (itemComparator: (lhs: BookmarkMenuItem, rhs: BookmarkMenuItem) => number): Array<BookmarkMenuItem> {
    const items: Array<BookmarkMenuItem> = this.expanded ? Object.values(this.childrenById).sort(itemComparator).map(c => c.flatten(itemComparator)).flat() : [];
    items.unshift(this);

    const childrenLength: number = Object.keys(this.childrenById).length;
    if (this.folder && (this.expanded || !childrenLength)) {
      const slot = new BookmarkMenuItem(this.parentId, `slot-${this.id}`, false, false, 'SLOT', childrenLength, undefined, undefined, undefined, undefined, undefined, undefined, undefined);
      slot.parent = this.parent;
      items.push(slot);
    }

    return items;
  }
}
