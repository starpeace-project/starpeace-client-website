import _ from 'lodash';

import Bookmark from '~/plugins/starpeace-client/bookmark/bookmark';

export default class BookmarkManager {
  api: any;
  translationManager: any;

  ajaxState: any;
  clientState: any;

  constructor (api: any, translationManager: any, ajaxState: any, clientState: any) {
    this.api = api;
    this.translationManager = translationManager;
    this.ajaxState = ajaxState;
    this.clientState = clientState;
  }

  initialize (): void {
    this.clientState.bookmarks.mausoleumItems.push(Bookmark.createMausoleumFolder());
    this.clientState.bookmarks.townItems.push(Bookmark.createTownFolder());

    for (const town of this.clientState.planet.towns) {
      this.clientState.bookmarks.townItems.push(Bookmark.createTownBookmark(town));
    }

    for (const companyId of (this.clientState.corporation.company_ids ?? [])) {
      this.addCompanyFolder(companyId);
      for (const buildingId of this.clientState.corporation.building_ids_for_company(companyId)) {
        this.addBuildingBookmark(buildingId);
      }
    }
  }

  addBookmarkFolder (corporationId: string, parentId: string, folderName: string): Promise<any> {
    return this.api.create_corporation_bookmark(corporationId, 'FOLDER', parentId, this.clientState.bookmarks.countForParent(parentId), folderName);
  }
  addBookmarkLocationItem (corporationId: string, parentId: string, folderName: string, mapX: number, mapY: number): Promise<any> {
    return this.api.create_corporation_bookmark(corporationId, 'LOCATION', parentId, this.clientState.bookmarks.countForParent(parentId), folderName, { mapX: mapY, mapY: mapY })
  }
  addBookmarkBuildingItem (corporationId: string, parentId: string, folderName: string, mapX: number, mapY: number, buildingId: string): Promise<any> {
    return this.api.create_corporation_bookmark(corporationId, 'BUILDING', parentId, this.clientState.bookmarks.countForParent(parentId), folderName, { mapX: mapX, mapY: mapY, buildingId: buildingId })
  }

  addCompanyFolder (companyId: string): void {
    this.clientState.bookmarks.setCompanyFolder(companyId, Bookmark.createCompanyFolder(companyId, this.clientState.name_for_company_id(companyId), this.clientState.seal_for_company_id(companyId)));
  }

  addBuildingBookmark (buildingId: string): void {
    const building = this.clientState.core.building_cache.building_for_id(buildingId);
    const definition = this.clientState.core.building_library.metadata_by_id[building?.definition_id]
    const industry_type = this.clientState.core.planet_library.type_for_id(definition?.industryTypeId)
    if (!building || !definition || !industry_type) {
      return;
    }

    const industryRootId = `bookmark-corp-${building.company_id}-${industry_type.id}`;
    if (!this.clientState.bookmarks.hasCompanyIndustryTypeFolder(building.company_id, industry_type.id)) {
      this.clientState.bookmarks.setCompanyIndustryTypeFolder(building.company_id, industry_type.id, Bookmark.createIndustryFolder(`bookmark-corp-${building.company_id}`, industryRootId, industry_type));
    }

    if (!this.clientState.bookmarks.hasCompanyBuildingItem(building.company_id, industry_type.id, buildingId)) {
      this.clientState.bookmarks.setCompanyBuildingItem(building.company_id, industry_type.id, buildingId, Bookmark.createCorporateBuildingBookmark(industryRootId, buildingId, building.name, building.map_x, building.map_y));
    }
  }

  async loadByCorporation (corporationId: string): Promise<void> {
    if (!this.clientState.has_session() || !corporationId) {
      throw Error();
    }

    await this.ajaxState.locked('bookmark_metadata', corporationId, async () => {
      const bookmarksJson: any = await this.api.bookmarks_for_corporation(corporationId);
      const items = [];
      for (const item of bookmarksJson ?? []) {
        if (item.type === 'FOLDER') {
          items.push(Bookmark.createFolder(item.parentId, item.id, item.name, item.order));
        }
        else if (item.type === 'LOCATION') {
          items.push(Bookmark.createLocationBookmark(item.parentId, item.id, item.name, item.order, item.mapX, item.mapY));
        }
        else if (item.type === 'BUILDING') {
          items.push(Bookmark.createBuildingBookmark(item.parentId, item.id, item.buildingId, item.name, item.order, item.mapX, item.mapY));
        }
      }
      this.clientState.bookmarks.setBookmarksMetadata(items);
      return items;
    });
  }

  async mergeBookmarkDeltas (deltas: Array<any>): Promise<any> {
    const corporationId = this.clientState.player.corporation_id;
    if (!this.clientState.has_session() || !corporationId) {
      throw Error();
    }

    const safe_deltas = [];
    for (const delta of deltas) {
      const safe_delta: any = {};
      safe_delta.id = delta.id;
      if (delta.type) {
        safe_delta.type = delta.type;
      }
      if (delta.parent_id) {
        safe_delta.parentId = delta.parent_id;
      }
      if (delta.name) {
        safe_delta.name = delta.name;
      }
      if (delta.order !== undefined) {
        safe_delta.order = delta.order;
      }
      if (delta.building_id) {
        safe_delta.buildingId = delta.building_id;
      }
      if (delta.map_x !== undefined) {
        safe_delta.mapX = delta.map_x;
      }
      if (delta.map_y !== undefined) {
        safe_delta.mapY = delta.map_y;
      }
      safe_deltas.push(safe_delta);

      if (this.clientState.bookmarks.bookmarkById[delta.id]) {
        this.clientState.bookmarks.bookmarkById[delta.id].parentId = delta.parent_id;
        this.clientState.bookmarks.bookmarkById[delta.id].order = delta.order;
      }
    }

    const updated_metadata = await this.api.update_corporation_bookmarks(corporationId, safe_deltas);
    // FIXME: TODO: verify update matches deltas
    return updated_metadata;
  }

  async createFolder (): Promise<void> {
    const corporationId = this.clientState.player.corporation_id;

    if (!this.clientState.has_session() || !corporationId) {
      throw Error();
    }
    await this.ajaxState.locked('new_bookmark_folder', corporationId, async () => {
      const folderName = `New Folder ${this.clientState.bookmarks.folderCount + 1}`;
      const item = await this.addBookmarkFolder(corporationId, 'bookmarks', folderName);
      this.clientState.bookmarks.addBookmarksMetadata(Bookmark.createFolder(item.parentId, item.id, item.name, item.order));
      return item;
    });
  }

  async createBookmark (): Promise<void> {
    const corporationId = this.clientState.player.corporation_id;
    const buildingId = this.clientState.interface.selected_building_id;
    const building = buildingId?.length ? this.clientState.core.building_cache.building_for_id(buildingId) : null;
    if (!this.clientState.has_session() || !corporationId || (buildingId?.length && !building)) {
      throw Error();
    }

    await this.ajaxState.locked('new_bookmark_item', corporationId, async () => {
      const item_name = building ? building.name : `My Bookmark ${this.clientState.bookmarks.itemCount + 1}`;
      const center = this.clientState.camera.center();
      const center_iso = this.clientState.camera.map_to_iso(center.x, center.y);

      const item = await (building ? this.addBookmarkBuildingItem(corporationId, 'bookmarks', item_name, building.map_x, building.map_y, buildingId) : this.addBookmarkLocationItem(corporationId, 'bookmarks', item_name, center_iso.i, center_iso.j));
      if (item.type === 'LOCATION') {
        this.clientState.bookmarks.addBookmarksMetadata(Bookmark.createLocationBookmark(item.parentId, item.id, item.name, item.order, item.mapX, item.mapY));
      }
      else if (item.type === 'BUILDING') {
        this.clientState.bookmarks.addBookmarksMetadata(Bookmark.createBuildingBookmark(item.parentId, item.id, item.buildingId, item.name, item.order, item.mapX, item.mapY));
      }
      return item;
    })
  }
}
