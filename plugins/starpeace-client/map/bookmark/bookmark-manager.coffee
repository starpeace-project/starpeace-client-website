
import Bookmark from '~/plugins/starpeace-client/map/bookmark/bookmark.coffee'
import BookmarkFolder from '~/plugins/starpeace-client/map/bookmark/bookmark-folder.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'
import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

export default class BookmarkManager
  constructor: (@api, @event_listener, @game_state) ->
    @corporation_items = []

    @town_items = []
    @town_items.push new BookmarkFolder('bookmark-poi', 'bookmark-towns', 'Towns', 0, {type:'TOWN'})
    @mausoleum_items = []
    @mausoleum_items.push new BookmarkFolder('bookmark-poi', 'bookmark-mausoleums', 'Mausoleums', 1)

    @vue_state_counter = 0

  initialize: () ->
    for town,index in _.sortBy(@game_state.session_state.planet_details.towns, (town) -> town.name)
      @town_items.push new Bookmark('bookmark-towns', "bookmark-town-#{town.id}", town.name, index, town.map_x, town.map_y, {type:'TOWN'})

    #@corporation_items.push new BookmarkFolder('bookmark-corporation', 'company-1', 'Dissidents Company', 0, {type:'CORPORATION', seal:'DIS'})
    #@corporation_items.push new BookmarkFolder('bookmark-corporation', 'company-2', 'Magna Corp Company', 1, {type:'CORPORATION', seal:'MAGNA'})
    #@corporation_items.push new BookmarkFolder('bookmark-corporation', 'company-3', 'Mariko Enterprises Company', 2, {type:'CORPORATION', seal:'MKO'})
    #@corporation_items.push new BookmarkFolder('bookmark-corporation', 'company-4', 'The Moab Company', 3, {type:'CORPORATION', seal:'MOAB'})
    #@corporation_items.push new BookmarkFolder('bookmark-corporation', 'company-5', 'Pure Gaba Initiative Company', 4, {type:'CORPORATION', seal:'PGI'})

  load_metadata: (corporation_id) ->
    new Promise (done, error) =>
      @game_state.session_state.start_bookmarks_metadata_request()
      @api.bookmarks_metadata(@game_state.session_state.session_token, corporation_id)
        .then (bookmark_metadata) =>
          items = []
          for item in bookmark_metadata.bookmarks
            if item.type == 'FOLDER'
              items.push new BookmarkFolder(item.parent_id, item.id, item.name, item.order, {draggable:true})
            else if item.type == 'LOCATION'
              items.push new Bookmark(item.parent_id, item.id, item.name, item.order, item.map_x, item.map_y, {draggable:true})

          @game_state.session_state.set_bookmarks_metadata(items)
          @game_state.session_state.finish_bookmarks_metadata_request()
          @event_listener.notify_bookmarks_metadata_listeners()
          done()

        .catch (err) =>
          # FIXME: TODO add error handling
          @game_state.session_state.finish_bookmarks_metadata_request()
          error()

  merge_bookmark_deltas: (deltas) ->
    return unless @game_state.session_state.corporation_id?.length && deltas?.length

    for delta in deltas
      if @game_state.session_state.bookmarks_by_id[delta.id]?
        @game_state.session_state.bookmarks_by_id[delta.id].parent_id = delta.parent_id
        @game_state.session_state.bookmarks_by_id[delta.id].order = delta.order

    @game_state.session_state.start_bookmarks_metadata_request()
    @api.update_bookmarks_metadata(@game_state.session_state.session_token, @game_state.session_state.corporation_id, deltas)
      .then (updated_metadata) =>
        @game_state.session_state.finish_bookmarks_metadata_request()
        @event_listener.notify_bookmarks_metadata_listeners()

      .catch (err) =>
        # FIXME: TODO add error handling
        @game_state.session_state.finish_bookmarks_metadata_request()
        console.log err
