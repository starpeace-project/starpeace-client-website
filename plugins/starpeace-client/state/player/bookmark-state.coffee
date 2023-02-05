import _ from 'lodash';

import EventListener from '~/plugins/starpeace-client/state/event-listener.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class BookmarkState
  constructor: () ->
    @event_listener = new EventListener()
    @town_items = []
    @mausoleum_items = []
    @company_folders_by_id = {}
    @bookmarks_by_id = null

  reset_state: () ->
    @town_items = []
    @mausoleum_items = []
    @company_folders_by_id = {}
    @bookmarks_by_id = null


  has_data: () -> @bookmarks_by_id?

  subscribe_bookmarks_metadata_listener: (listener_callback) -> @event_listener.subscribe('player.bookmarks_metadata', listener_callback)
  notify_bookmarks_metadata_listeners: () -> @event_listener.notify_listeners('player.bookmarks_metadata')

  folder_count: () -> _.filter(_.values(@bookmarks_by_id || {}), (item) -> item.is_folder()).length
  item_count: () -> _.filter(_.values(@bookmarks_by_id || {}), (item) -> !item.is_folder()).length

  count_for_parent: (parent_id) -> _.filter(_.values(@bookmarks_by_id || {}), (item) -> item.parent_id == parent_id).length

  set_bookmarks_metadata: (bookmarks_items) ->
    @bookmarks_by_id = {}
    @bookmarks_by_id[item.id] = item for item in (bookmarks_items || [])
    @notify_bookmarks_metadata_listeners()

  add_bookmarks_metadata: (bookmark_item) ->
    @bookmarks_by_id[bookmark_item.id] = bookmark_item

  has_company_folder: (company_id) -> @company_folders_by_id[company_id]?.root?
  set_company_folder: (company_id, company_folder) ->
    unless @company_folders_by_id[company_id]?
      @company_folders_by_id[company_id] = {
        root: company_folder
        by_industry_type: {}
      }
    else
      @company_folders_by_id[company_id].root = company_folder

  has_company_industry_type_folder: (company_id, industry_type) -> @company_folders_by_id[company_id]?.by_industry_type?[industry_type]?.root?
  set_company_industry_type_folder: (company_id, industry_type, industry_folder) ->
    if @company_folders_by_id[company_id]?
      unless @company_folders_by_id[company_id].by_industry_type[industry_type]?
        @company_folders_by_id[company_id].by_industry_type[industry_type] = {
          root: industry_folder
          items_by_id: {}
        }
      else
        @company_folders_by_id[company_id].by_industry_type[industry_type].root = industry_folder

  has_company_building_item: (company_id, industry_type, building_id) -> @company_folders_by_id[company_id]?.by_industry_type?[industry_type]?.items_by_id?[building_id]?
  set_company_building_item: (company_id, industry_type, building_id, building_bookmark) ->
    if @company_folders_by_id[company_id]?.by_industry_type?[industry_type]?
      @company_folders_by_id[company_id].by_industry_type[industry_type].items_by_id[building_id] = building_bookmark

  sort_company_folders: () ->
    bookmark.order = index for bookmark,index in _.sortBy(_.map(@company_folders_by_id, (item) -> item.root), 'name')
  sort_company_industry_type_folders: (translation_manager, company_id) ->
    bookmark.order = index for bookmark,index in _.sortBy(_.map(@company_folders_by_id[company_id]?.by_industry_type || {}, (item) -> item.root), (item) -> if item.name_key?.length then translation_manager.text(item.name_key) else item.name)
  sort_company_building_items: (company_id, industry_type) ->
    bookmark.order = index for bookmark,index in _.sortBy(_.values(@company_folders_by_id[company_id]?.by_industry_type?[industry_type]?.items_by_id || {}), 'name')

  sort_all_corporation_bookmarks: (translation_manager) ->
    @sort_company_folders()
    for company_id,company_items of @company_folders_by_id
      @sort_company_industry_type_folders(translation_manager, company_id)
      for industry_type,industry_items of @company_folders_by_id[company_id]?.by_industry_type
        @sort_company_building_items(company_id, industry_type)
