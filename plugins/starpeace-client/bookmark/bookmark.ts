import BookmarkMenuItem from '~/plugins/starpeace-client/bookmark/bookmark-menu-item';

export default class Bookmark {
  parentId: string;
  id: string;

  folder: boolean;
  type: string;

  order: number | undefined;
  nameKey: string | undefined;
  name: string | undefined;
  sealId: string | undefined;
  industryTypeId: string | undefined;

  mapX: number | undefined;
  mapY: number | undefined;
  buildingId: string | undefined;

  expanded: boolean;

  constructor (parentId: string, id: string, folder: boolean, options: any = {}) {
    this.parentId = parentId;
    this.id = id;

    this.folder = folder;
    this.type = options?.type ?? 'GENERIC';

    this.order = options?.order;
    this.nameKey = options?.nameKey;
    this.name = options?.name;
    this.sealId = options?.sealId;
    this.industryTypeId = options?.industryTypeId;

    this.mapX = options?.mapX;
    this.mapY = options?.mapY;
    this.buildingId = options?.buildingId;

    this.expanded = false;
  }

  toMenuItem (): BookmarkMenuItem {
    return new BookmarkMenuItem(this.parentId, this.id, this.folder, this.expanded, this.type, this.order, this.nameKey, this.name, this.sealId, this.industryTypeId, this.mapX, this.mapY, this.buildingId);
  }

  static createTownFolder (): Bookmark {
    return new Bookmark('bookmark-poi', 'bookmark-towns', true, { type: 'TOWN', order: 0, nameKey: 'ui.menu.bookmarks.section.towns' });
  }
  static createMausoleumFolder (): Bookmark {
    return new Bookmark('bookmark-poi', 'bookmark-mausoleums', true, { type: 'MAUSOLEUM', order: 1, nameKey: 'ui.menu.bookmarks.section.mausoleums' });
  }
  static createCompanyFolder (companyId: string, companyName: string, sealId: string): Bookmark {
    return new Bookmark('bookmark-corporation', `bookmark-corp-${companyId}`, true, { type: 'CORPORATION', name: companyName, sealId: sealId });
  }
  static createIndustryFolder (rootId: string, id: string, industryType: any): Bookmark {
    return new Bookmark(rootId, id, true, { type: 'INDUSTRY', nameKey: industryType.label, industryTypeId: industryType.id });
  }

  static createFolder (rootId: string, id: string, name: string, order: number): Bookmark {
    return new Bookmark(rootId, id, true, { order, name });
  }


  static createTownBookmark (town: any): Bookmark {
    return new Bookmark('bookmark-towns', `bookmark-town-${town.id}`, false, { type: 'TOWN', name: town.name, buildingId: town.building_id, mapX: town.map_x, mapY: town.map_y });
  }
  static createCorporateBuildingBookmark (rootId: string, buildingId: string, buildingName: string, mapX: number, mapY: number): Bookmark {
    return new Bookmark(rootId, `bookmark-building-${buildingId}`, false, { type: 'BUILDING', name: buildingName, buildingId, mapX, mapY });
  }

  static createLocationBookmark (rootId: string, id: string, name: string, order: number, mapX: number, mapY: number): Bookmark {
    return new Bookmark(rootId, id, false, { order, name, mapX, mapY });
  }
  static createBuildingBookmark (rootId: string, id: string, buildingId: string, name: string, order: number, mapX: number, mapY: number): Bookmark {
    return new Bookmark(rootId, id, false, { type: 'BUILDING', order, name, buildingId, mapX, mapY });
  }
}
