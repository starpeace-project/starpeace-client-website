
import Bookmark from '~/plugins/starpeace-client/bookmark/bookmark.coffee'
import BookmarkFolder from '~/plugins/starpeace-client/bookmark/bookmark-folder.coffee'

import IndustryType from '~/plugins/starpeace-client/industry/industry-type.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'
import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

export default class BookmarkManager
  constructor: (@api, @translation_manager, @ajax_state, @client_state) ->

  initialize: () ->
    @client_state.bookmarks.mausoleum_items.push new BookmarkFolder('bookmark-poi', 'bookmark-mausoleums', 'Mausoleums', 1)

    @client_state.bookmarks.town_items.push new BookmarkFolder('bookmark-poi', 'bookmark-towns', 'Towns', 0, {type:'TOWN'})
    for town,index in _.sortBy(@client_state.current_planet_details()?.towns_metadata || [], (town) -> town.name)
      @client_state.bookmarks.town_items.push new Bookmark('bookmark-towns', "bookmark-town-#{town.id}", town.name, index, 1000 - town.map_y, 1000 - town.map_x, {type:'TOWN', corporation_id:'IFEL', building_id:town.building_id})

    sorted_company_ids = _.sortBy(@client_state.corporation.company_ids, (id) => @client_state.name_for_company_id(id))
    for company_id,index in sorted_company_ids
      company_root_id = "bookmark-corp-#{company_id}"
      @client_state.bookmarks.corporation_items.push new BookmarkFolder('bookmark-corporation', company_root_id, @client_state.name_for_company_id(company_id), index, {type:'CORPORATION', seal_id:@client_state.seal_for_company_id(company_id)})

      industry_items = {}
      for building_id in @client_state.corporation.building_ids_for_company(company_id)
        metadata = @client_state.core.building_cache.building_metadata_for_id(building_id)
        definition = @client_state.core.building_library.metadata_by_id[metadata.key]
        industry_type = IndustryType.TYPES[definition.industry_type]
        continue unless metadata? && definition? && industry_type?

        industry_items[industry_type.type] = { type: industry_type.type, type_name:@translation_manager.text(industry_type.text_key), items:[] } unless industry_items[industry_type.type]?
        industry_items[industry_type.type].items.push metadata

      for buildings_for_industry,items_index in _.sortBy(_.values(industry_items), (items) -> items.type_name)
        industry_root_id = "bookmark-corp-#{company_id}-#{buildings_for_industry.type}"
        @client_state.bookmarks.corporation_items.push new BookmarkFolder(company_root_id, industry_root_id, buildings_for_industry.type_name, items_index, {type:'INDUSTRY', industry_type:buildings_for_industry.type})

        for building,building_index in _.sortBy(buildings_for_industry.items, (items) -> items.name)
          @client_state.bookmarks.corporation_items.push new Bookmark(industry_root_id, "bookmark-building-#{building.id}", building.name, building_index, building.x, building.y, {type:'BUILDING', corporation_id:building.corporation_id, building_id:building.id})


  load_metadata: (corporation_id) ->
    new Promise (done, error) =>
      if !@client_state.session.session_token? || !corporation_id? || @ajax_state.is_locked('bookmark_metadata', corporation_id)
        done()
      else
        @ajax_state.lock('bookmark_metadata', corporation_id)
        @api.bookmarks_metadata(@client_state.session.session_token, corporation_id)
          .then (bookmark_metadata) =>
            items = []
            for item in bookmark_metadata.bookmarks
              if item.type == 'FOLDER'
                items.push new BookmarkFolder(item.parent_id, item.id, item.name, item.order, {draggable:true})
              else if item.type == 'LOCATION'
                items.push new Bookmark(item.parent_id, item.id, item.name, item.order, item.map_x, item.map_y, {draggable:true})
              else if item.type == 'BUILDING'
                items.push new Bookmark(item.parent_id, item.id, item.name, item.order, item.map_x, item.map_y, {building_id:item.building_id, raggable:true})

            @client_state.bookmarks.set_bookmarks_metadata(items)

            @ajax_state.unlock('bookmark_metadata', corporation_id)
            done()

          .catch (err) =>
            @ajax_state.unlock('bookmark_metadata', corporation_id) # FIXME: TODO add error handling
            error()


  merge_bookmark_deltas: (deltas) ->
    new Promise (done, error) =>
      corporation_id = @client_state.player.corporation_id
      if !@client_state.session.session_token? || !corporation_id? || @ajax_state.is_locked('update_bookmark', corporation_id)
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
      if !@client_state.session.session_token? || !corporation_id? || @ajax_state.is_locked('new_bookmark_folder', corporation_id)
        done()
      else
        folder_name = "New Folder #{@client_state.bookmarks.folder_count() + 1}"

        @ajax_state.lock('new_bookmark_folder', corporation_id)
        @api.add_bookmark(@client_state.session.session_token, corporation_id, 'FOLDER', 'bookmarks', folder_name)
          .then (item) =>
            @client_state.bookmarks.add_bookmarks_metadata new BookmarkFolder(item.parent_id, item.id, item.name, item.order, {draggable:true})

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

      if !@client_state.session.session_token? || !corporation_id? || @ajax_state.is_locked('new_bookmark_item', corporation_id) || (building_id?.length && !building?)
        done()
      else
        item_name = if building? then building.name else "My Bookmark #{@client_state.bookmarks.item_count() + 1}"

        center = @client_state.camera.center()
        center_iso = @client_state.camera.map_to_iso(center.x, center.y)

        @ajax_state.lock('new_bookmark_item', corporation_id)
        promise = if building? then @api.add_bookmark_building_item(@client_state.session.session_token, corporation_id, 'bookmarks', item_name, building.x, building.y, building_id) else @api.add_bookmark_location_item(@client_state.session.session_token, corporation_id, 'bookmarks', item_name, center_iso.i, center_iso.j)
        promise.then (item) =>
          if item.type == 'LOCATION'
            @client_state.bookmarks.add_bookmarks_metadata new Bookmark(item.parent_id, item.id, item.name, item.order, item.map_x, item.map_y, {draggable:true})
          else if item.type == 'BUILDING'
            @client_state.bookmarks.add_bookmarks_metadata new Bookmark(item.parent_id, item.id, item.name, item.order, item.map_x, item.map_y, {type:'BUILDING', building_id:item.building_id, draggable:true})

          @ajax_state.unlock('new_bookmark_item', corporation_id)
          done()

        .catch (err) =>
          @ajax_state.unlock('new_bookmark_item', corporation_id) # FIXME: TODO add error handling
          error()
