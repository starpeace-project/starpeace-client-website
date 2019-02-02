
import Bookmark from '~/plugins/starpeace-client/bookmark/bookmark.coffee'
import BookmarkFolder from '~/plugins/starpeace-client/bookmark/bookmark-folder.coffee'

import IndustryType from '~/plugins/starpeace-client/industry/industry-type.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'
import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

export default class BookmarkManager
  constructor: (@api, @translation_manager, @ajax_state, @client_state) ->

  initialize: () ->
    @client_state.bookmarks.mausoleum_items.push BookmarkFolder.new_mausoleum_folder()

    @client_state.bookmarks.town_items.push BookmarkFolder.new_town_folder()
    for town,index in _.sortBy(@client_state.current_planet_details()?.towns_metadata || [], (town) -> town.name)
      @client_state.bookmarks.town_items.push Bookmark.new_town(index, town.id, town.name, town.map_y, town.map_x, town.building_id)

    for company_id in @client_state.corporation.company_ids
      @add_company_folder(company_id, false)
      @add_building_bookmark(building_id, false) for building_id in @client_state.corporation.building_ids_for_company(company_id)
    @client_state.bookmarks.sort_all_corporation_bookmarks(@translation_manager)

  add_company_folder: (company_id, do_sort=false) ->
    @client_state.bookmarks.set_company_folder(company_id, BookmarkFolder.new_corporation_folder(company_id, @client_state.name_for_company_id(company_id), @client_state.seal_for_company_id(company_id)))
    @client_state.bookmarks.sort_company_folders() if do_sort

  add_building_bookmark: (building_id, do_sort=false) ->
    metadata = @client_state.core.building_cache.building_metadata_for_id(building_id)
    definition = @client_state.core.building_library.metadata_by_id[metadata.key]
    industry_type = IndustryType.TYPES[definition.industry_type]
    return unless metadata? && definition? && industry_type?

    industry_root_id = "bookmark-corp-#{metadata.company_id}-#{industry_type.type}"
    unless @client_state.bookmarks.has_company_industry_type_folder(metadata.company_id, industry_type.type)
      @client_state.bookmarks.set_company_industry_type_folder(metadata.company_id, industry_type.type, BookmarkFolder.new_industry_folder("bookmark-corp-#{metadata.company_id}", industry_root_id, industry_type))
      @client_state.bookmarks.sort_company_industry_type_folders(@translation_manager, metadata.company_id) if do_sort

    unless @client_state.bookmarks.has_company_building_item(metadata.company_id, industry_type.type, building_id)
      @client_state.bookmarks.set_company_building_item(metadata.company_id, industry_type.type, building_id, Bookmark.new_corporate_building(industry_root_id, building_id, metadata.name, metadata.x, metadata.y))
      @client_state.bookmarks.sort_company_building_items(metadata.company_id, industry_type.type) if do_sort


  load_metadata: (corporation_id) ->
    new Promise (done, error) =>
      if !@client_state.has_session() || !corporation_id? || @ajax_state.is_locked('bookmark_metadata', corporation_id)
        done()
      else
        @ajax_state.lock('bookmark_metadata', corporation_id)
        @api.bookmarks_metadata(@client_state.session.session_token, corporation_id)
          .then (bookmark_metadata) =>
            items = []
            for item in bookmark_metadata.bookmarks
              if item.type == 'FOLDER'
                items.push BookmarkFolder.new_folder(item.parent_id, item.id, item.name, item.order)
              else if item.type == 'LOCATION'
                items.push Bookmark.new_bookmark(item.parent_id, item.id, item.name, item.order, item.map_x, item.map_y)
              else if item.type == 'BUILDING'
                items.push Bookmark.new_bookmark_building(item.parent_id, item.id, item.building_id, item.name, item.order, item.map_x, item.map_y)

            @client_state.bookmarks.set_bookmarks_metadata(items)

            @ajax_state.unlock('bookmark_metadata', corporation_id)
            done()

          .catch (err) =>
            @ajax_state.unlock('bookmark_metadata', corporation_id) # FIXME: TODO add error handling
            error()


  merge_bookmark_deltas: (deltas) ->
    new Promise (done, error) =>
      corporation_id = @client_state.player.corporation_id
      if !@client_state.has_session() || !corporation_id? || @ajax_state.is_locked('update_bookmark', corporation_id)
        done()
      else
        for delta in deltas
          if @client_state.bookmarks.bookmarks_by_id[delta.id]?
            @client_state.bookmarks.bookmarks_by_id[delta.id].parent_id = delta.parent_id
            @client_state.bookmarks.bookmarks_by_id[delta.id].order = delta.order

        @ajax_state.lock('update_bookmark', corporation_id)
        @api.update_bookmarks_metadata(@client_state.session.session_token, corporation_id, deltas)
          .then (updated_metadata) =>
            # FIXME: TODO: verify update matches deltas

            @ajax_state.unlock('update_bookmark', corporation_id)
            done()

          .catch (err) =>
            @ajax_state.unlock('update_bookmark', corporation_id) # FIXME: TODO add error handling
            error()

  new_bookmark_folder: () ->
    new Promise (done, error) =>
      corporation_id = @client_state.player.corporation_id
      if !@client_state.has_session() || !corporation_id? || @ajax_state.is_locked('new_bookmark_folder', corporation_id)
        done()
      else
        folder_name = "New Folder #{@client_state.bookmarks.folder_count() + 1}"

        @ajax_state.lock('new_bookmark_folder', corporation_id)
        @api.add_bookmark(@client_state.session.session_token, corporation_id, 'FOLDER', 'bookmarks', folder_name)
          .then (item) =>
            @client_state.bookmarks.add_bookmarks_metadata BookmarkFolder.new_folder(item.parent_id, item.id, item.name, item.order)

            @ajax_state.unlock('new_bookmark_folder', corporation_id)
            done()

          .catch (err) =>
            @ajax_state.unlock('new_bookmark_folder', corporation_id) # FIXME: TODO add error handling
            error()

  new_bookmark_item: () ->
    new Promise (done, error) =>
      corporation_id = @client_state.player.corporation_id
      building_id = @client_state.interface.selected_building_id
      building = if building_id?.length then @client_state.core.building_cache.building_metadata_for_id(building_id) else null

      if !@client_state.has_session() || !corporation_id? || @ajax_state.is_locked('new_bookmark_item', corporation_id) || (building_id?.length && !building?)
        done()
      else
        item_name = if building? then building.name else "My Bookmark #{@client_state.bookmarks.item_count() + 1}"

        center = @client_state.camera.center()
        center_iso = @client_state.camera.map_to_iso(center.x, center.y)

        @ajax_state.lock('new_bookmark_item', corporation_id)
        promise = if building? then @api.add_bookmark_building_item(@client_state.session.session_token, corporation_id, 'bookmarks', item_name, building.x, building.y, building_id) else @api.add_bookmark_location_item(@client_state.session.session_token, corporation_id, 'bookmarks', item_name, center_iso.i, center_iso.j)
        promise.then (item) =>
          if item.type == 'LOCATION'
            @client_state.bookmarks.add_bookmarks_metadata Bookmark.new_bookmark(item.parent_id, item.id, item.name, item.order, item.map_x, item.map_y)
          else if item.type == 'BUILDING'
            @client_state.bookmarks.add_bookmarks_metadata Bookmark.new_bookmark_building(item.parent_id, item.id, item.building_id, item.name, item.order, item.map_x, item.map_y)

          @ajax_state.unlock('new_bookmark_item', corporation_id)
          done()

        .catch (err) =>
          @ajax_state.unlock('new_bookmark_item', corporation_id) # FIXME: TODO add error handling
          error()
