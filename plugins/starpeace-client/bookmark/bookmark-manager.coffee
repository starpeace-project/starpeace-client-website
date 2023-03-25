import _ from 'lodash';

import Bookmark from '~/plugins/starpeace-client/bookmark/bookmark.coffee'
import BookmarkFolder from '~/plugins/starpeace-client/bookmark/bookmark-folder.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'
import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

export default class BookmarkManager
  constructor: (@api, @translation_manager, @ajax_state, @client_state) ->

  initialize: () ->
    @client_state.bookmarks.mausoleum_items.push BookmarkFolder.new_mausoleum_folder()

    @client_state.bookmarks.town_items.push BookmarkFolder.new_town_folder()
    for town,index in _.sortBy(@client_state.planet.towns || [], (town) -> town.name)
      @client_state.bookmarks.town_items.push Bookmark.new_town(index, town.id, town.name, town.map_x, town.map_y, town.building_id)

    for company_id in (@client_state.corporation.company_ids || [])
      @add_company_folder(company_id, false)
      @add_building_bookmark(building_id, false) for building_id in @client_state.corporation.building_ids_for_company(company_id)
    @client_state.bookmarks.sort_all_corporation_bookmarks(@translation_manager)

  add_bookmark_folder: (corporation_id, parent_id, folder_name) ->
    @api.create_corporation_bookmark(corporation_id, 'FOLDER', parent_id, @client_state.bookmarks.count_for_parent(parent_id), folder_name)
  add_bookmark_location_item: (corporation_id, parent_id, folder_name, map_x, map_y) ->
    @api.create_corporation_bookmark(corporation_id, 'LOCATION', parent_id, @client_state.bookmarks.count_for_parent(parent_id), folder_name, { mapX: map_x, mapY: map_y })
  add_bookmark_building_item: (corporation_id, parent_id, folder_name, map_x, map_y, building_id) ->
    @api.create_corporation_bookmark(corporation_id, 'BUILDING', parent_id, @client_state.bookmarks.count_for_parent(parent_id), folder_name, { mapX: map_x, mapY: map_y, buildingId: building_id })

  add_company_folder: (company_id, do_sort=false) ->
    @client_state.bookmarks.set_company_folder(company_id, BookmarkFolder.new_corporation_folder(company_id, @client_state.name_for_company_id(company_id), @client_state.seal_for_company_id(company_id)))
    @client_state.bookmarks.sort_company_folders() if do_sort

  add_building_bookmark: (building_id, do_sort=false) ->
    building = @client_state.core.building_cache.building_for_id(building_id)
    definition = @client_state.core.building_library.metadata_by_id[building?.definition_id]
    industry_type = @client_state.core.planet_library.type_for_id(definition?.industry_type_id)
    return unless building? && definition? && industry_type?

    industry_root_id = "bookmark-corp-#{building.company_id}-#{industry_type.id}"
    unless @client_state.bookmarks.has_company_industry_type_folder(building.company_id, industry_type.id)
      @client_state.bookmarks.set_company_industry_type_folder(building.company_id, industry_type.id, BookmarkFolder.new_industry_folder("bookmark-corp-#{building.company_id}", industry_root_id, industry_type))
      @client_state.bookmarks.sort_company_industry_type_folders(@translation_manager, building.company_id) if do_sort

    unless @client_state.bookmarks.has_company_building_item(building.company_id, industry_type.id, building_id)
      @client_state.bookmarks.set_company_building_item(building.company_id, industry_type.id, building_id, Bookmark.new_corporate_building(industry_root_id, building_id, building.name, building.map_x, building.map_y))
      @client_state.bookmarks.sort_company_building_items(building.company_id, industry_type.id) if do_sort


  load_by_corporation: (corporation_id) ->
    throw Error() if !@client_state.has_session() || !corporation_id?
    await @ajax_state.locked('bookmark_metadata', corporation_id, =>
      bookmarks_json = await @api.bookmarks_for_corporation(corporation_id)
      items = []
      for item in (bookmarks_json || [])
        if item.type == 'FOLDER'
          items.push BookmarkFolder.new_folder(item.parentId, item.id, item.name, item.order)
        else if item.type == 'LOCATION'
          items.push Bookmark.new_bookmark(item.parentId, item.id, item.name, item.order, item.mapX, item.mapY)
        else if item.type == 'BUILDING'
          items.push Bookmark.new_bookmark_building(item.parentId, item.id, item.buildingId, item.name, item.order, item.mapX, item.mapY)
      @client_state.bookmarks.set_bookmarks_metadata(items)
      items
    )


  merge_bookmark_deltas: (deltas) ->
    corporation_id = @client_state.player.corporation_id
    throw Error() if !@client_state.has_session() || !corporation_id?

    safe_deltas = []
    for delta in deltas
      safe_delta = {}
      safe_delta.id = delta.id
      safe_delta.type = delta.type if delta.type?
      safe_delta.parentId = delta.parent_id if delta.parent_id?
      safe_delta.name = delta.name if delta.name?
      safe_delta.order = delta.order if delta.order?
      safe_delta.buildingId = delta.building_id if delta.building_id?
      safe_delta.mapX = delta.map_x if delta.map_x?
      safe_delta.mapY = delta.map_y if delta.map_y?
      safe_deltas.push safe_delta

      if @client_state.bookmarks.bookmarks_by_id[delta.id]?
        @client_state.bookmarks.bookmarks_by_id[delta.id].parent_id = delta.parent_id
        @client_state.bookmarks.bookmarks_by_id[delta.id].order = delta.order

    updated_metadata = await @api.update_corporation_bookmarks(corporation_id, safe_deltas)
    # FIXME: TODO: verify update matches deltas
    updated_metadata

  new_bookmark_folder: () ->
    corporation_id = @client_state.player.corporation_id
    throw Error() if !@client_state.has_session() || !corporation_id?
    await @ajax_state.locked('new_bookmark_folder', corporation_id, =>
      folder_name = "New Folder #{@client_state.bookmarks.folder_count() + 1}"
      item = await @add_bookmark_folder(corporation_id, 'bookmarks', folder_name)
      @client_state.bookmarks.add_bookmarks_metadata BookmarkFolder.new_folder(item.parentId, item.id, item.name, item.order)
      item
    )

  new_bookmark_item: () ->
    corporation_id = @client_state.player.corporation_id
    building_id = @client_state.interface.selected_building_id
    building = if building_id?.length then @client_state.core.building_cache.building_for_id(building_id) else null
    throw Error() if !@client_state.has_session() || !corporation_id? || (building_id?.length && !building?)
    await @ajax_state.locked('new_bookmark_item', corporation_id, =>
      item_name = if building? then building.name else "My Bookmark #{@client_state.bookmarks.item_count() + 1}"
      center = @client_state.camera.center()
      center_iso = @client_state.camera.map_to_iso(center.x, center.y)

      item = await (if building? then @add_bookmark_building_item(corporation_id, 'bookmarks', item_name, building.map_x, building.map_y, building_id) else @add_bookmark_location_item(corporation_id, 'bookmarks', item_name, center_iso.i, center_iso.j))
      if item.type == 'LOCATION'
        @client_state.bookmarks.add_bookmarks_metadata Bookmark.new_bookmark(item.parentId, item.id, item.name, item.order, item.mapX, item.mapY)
      else if item.type == 'BUILDING'
        @client_state.bookmarks.add_bookmarks_metadata Bookmark.new_bookmark_building(item.parentId, item.id, item.buildingId, item.name, item.order, item.mapX, item.mapY)
      item
    )
