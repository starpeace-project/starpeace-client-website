import _ from 'lodash';

import EventListener from '~/plugins/starpeace-client/state/event-listener'

import Bookmark from '~/plugins/starpeace-client/bookmark/bookmark';


class CompanyBookmarks {
  root: Bookmark;
  byIndustryTypeId: Record<string, IndustryBookmarks> = {};

  constructor (root: Bookmark) {
    this.root = root;
  }

  get industryBookmarks (): Array<IndustryBookmarks> {
    return Object.values(this.byIndustryTypeId);
  }
}

class IndustryBookmarks {
  root: Bookmark;
  byId: Record<string, Bookmark> = {};

  constructor (root: Bookmark) {
    this.root = root;
  }

  get bookmarks(): Array<Bookmark> {
    return Object.values(this.byId);
  }
}

export default class BookmarkState {
  eventListener: EventListener = new EventListener();

  townItems: Array<any> = [];
  mausoleumItems: Array<any> = [];

  companyFolderById: Record<string, CompanyBookmarks> = {};
  bookmarkById: Record<string, Bookmark> | null = null;

  reset () {
    this.townItems = [];
    this.mausoleumItems = [];
    this.companyFolderById = {};
    this.bookmarkById = null;
  }

  get companyFolders (): Array<CompanyBookmarks> {
    return Object.values(this.companyFolderById);
  }

  get hasData (): boolean {
    return this.bookmarkById !== null;
  }

  get folderCount () {
    return Object.values(this.bookmarkById ?? {}).filter((item) => item.folder).length;
  }
  get itemCount () {
    return Object.values(this.bookmarkById ?? {}).filter((item) => !item.folder).length;
  }

  subscribeBookmarksMetadataListener (listener_callback: Function): void {
    this.eventListener.subscribe('player.bookmarks_metadata', listener_callback);
  }
  notifyBookmarksMetadataListeners (): void {
    this.eventListener.notify_listeners('player.bookmarks_metadata');
  }

  countForParent (parentId: string): number {
    return Object.values(this.bookmarkById ?? {}).filter((item) => item.parentId == parentId).length;
  }

  setBookmarksMetadata (bookmarks: Array<Bookmark>) {
    this.bookmarkById = {};
    for (const item of (bookmarks ?? [])) {
      this.bookmarkById[item.id] = item;
    }
    this.notifyBookmarksMetadataListeners();
  }

  addBookmarksMetadata (bookmark: Bookmark): void {
    this.bookmarkById ??= {};
    this.bookmarkById[bookmark.id] = bookmark;
  }

  hasCompanyFolder (companyId: string): boolean {
    return this.companyFolderById[companyId]?.root !== undefined;
  }
  setCompanyFolder (companyId: string, companyFolder: Bookmark): void {
    this.companyFolderById[companyId] ??= new CompanyBookmarks(companyFolder);
    this.companyFolderById[companyId].root = companyFolder;
  }

  hasCompanyIndustryTypeFolder (companyId: string, industryTypeId: string): boolean {
    return this.companyFolderById[companyId]?.byIndustryTypeId?.[industryTypeId]?.root !== undefined;
  }
  setCompanyIndustryTypeFolder (companyId: string, industryTypeId: string, industryFolder: Bookmark): void {
    if (this.companyFolderById[companyId]) {
      this.companyFolderById[companyId].byIndustryTypeId[industryTypeId] ??= new IndustryBookmarks(industryFolder);
      this.companyFolderById[companyId].byIndustryTypeId[industryTypeId].root = industryFolder;
    }
  }

  hasCompanyBuildingItem (companyId: string, industryTypeId: string, buildingId: string): boolean {
    return this.companyFolderById[companyId]?.byIndustryTypeId?.[industryTypeId]?.byId?.[buildingId] !== undefined;
  }
  setCompanyBuildingItem (companyId: string, industryTypeId: string, buildingId: string, bookmark: Bookmark) {
    if (this.companyFolderById[companyId]?.byIndustryTypeId?.[industryTypeId]?.byId !== undefined) {
      this.companyFolderById[companyId].byIndustryTypeId[industryTypeId].byId[buildingId] = bookmark;
    }
  }

}
