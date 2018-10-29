
import Bookmark from '~/plugins/starpeace-client/map/bookmark/bookmark.coffee'
import BookmarkFolder from '~/plugins/starpeace-client/map/bookmark/bookmark-folder.coffee'

import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

export default class BookmarkManager
  constructor: (@game_state, @options) ->
    @points_of_interest_items = []
    @corporation_items = []
    @bookmark_items = []

    @towns = new BookmarkFolder('bookmark-poi', 'bookmark-towns', 'Towns', 0, {type:'TOWN'})
    @mausoleums = new BookmarkFolder('bookmark-poi', 'bookmark-mausoleums', 'Mausoleums', 1)
    @points_of_interest_items.push @towns
    @points_of_interest_items.push @mausoleums

    @vue_state_counter = 0

  load: () ->
    # TODO: load from API call
    @points_of_interest_items.push new Bookmark('bookmark-towns', 'town-a', 'Town A', 0, 256, 256, {type:'TOWN'})

    @bookmark_items.push new BookmarkFolder('bookmarks', 'my-folder-1', 'My Folder 1', 0, {draggable:true})
    @bookmark_items.push new Bookmark('my-folder-1', 'my-bookmark-3', 'My Bookmark 3', 0, 256, 256, {draggable:true})

    @bookmark_items.push new BookmarkFolder('bookmarks', 'my-folder-2', 'My Folder 2', 1, {draggable:true})
    @bookmark_items.push new BookmarkFolder('my-folder-2', 'my-folder-3', 'My Folder 3', 0, {draggable:true})
    @bookmark_items.push new Bookmark('my-folder-3', 'my-bookmark-6', 'My Bookmark 6', 0, 256, 256, {draggable:true})
    @bookmark_items.push new Bookmark('my-folder-2', 'my-bookmark-4', 'My Bookmark 4', 1, 256, 256, {draggable:true})
    @bookmark_items.push new Bookmark('my-folder-2', 'my-bookmark-5', 'My Bookmark 5', 2, 256, 256, {draggable:true})

    @bookmark_items.push new Bookmark('bookmarks', 'my-bookmark-1', 'My Bookmark 1', 2, 2, 256, 256, {draggable:true})
    @bookmark_items.push new Bookmark('bookmarks', 'my-bookmark-2', 'My Bookmark 2', 3, 3, 256, 256, {draggable:true})

    @corporation_items.push new BookmarkFolder('bookmark-corporation', 'company-1', 'Dissidents Company', 0, {type:'CORPORATION', seal:'DIS'})
    @corporation_items.push new BookmarkFolder('bookmark-corporation', 'company-2', 'Magna Corp Company', 1, {type:'CORPORATION', seal:'MAGNA'})
    @corporation_items.push new BookmarkFolder('bookmark-corporation', 'company-3', 'Mariko Enterprises Company', 2, {type:'CORPORATION', seal:'MKO'})
    @corporation_items.push new BookmarkFolder('bookmark-corporation', 'company-4', 'The Moab Company', 3, {type:'CORPORATION', seal:'MOAB'})
    @corporation_items.push new BookmarkFolder('bookmark-corporation', 'company-5', 'Pure Gaba Initiative Company', 4, {type:'CORPORATION', seal:'PGI'})

    @vue_state_counter += 1

  sections: () ->
    @towns.hidden = !@options.option('bookmarks.towns')
    @mausoleums.hidden = !@options.option('bookmarks.mausoleums')

    sections = []
    sections.push(@points_of_interest) if @options.option('bookmarks.points_of_interest')
    sections.push(@corporation) if @options.option('bookmarks.corporation')
    sections.push(@bookmarks)
    sections

  merge_bookmark_deltas: (deltas) ->
    by_id = {}
    by_id[item.id] = item for item in @bookmark_items

    for delta in deltas
      if by_id[delta.id]?
        by_id[delta.id].parent_id = delta.parent_id
        by_id[delta.id].order = delta.order

    # TODO: persist bookmarks to server
