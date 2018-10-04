
import Bookmark from '~/plugins/starpeace-client/map/bookmark/bookmark.coffee'
import BookmarkFolder from '~/plugins/starpeace-client/map/bookmark/bookmark-folder.coffee'

import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

export default class BookmarkManager
  constructor: (@game_state, @options) ->
    @towns = new BookmarkFolder('bookmark-towns', 'Towns', {type:'TOWN'})
    @mausoleums = new BookmarkFolder('bookmark-mausoleums', 'Mausoleums')
    @points_of_interest = new BookmarkFolder('bookmark-pois', 'Points of Interest')
    @points_of_interest.add_child(@towns)
    @points_of_interest.add_child(@mausoleums)

    @corporation = new BookmarkFolder('bookmark-coporation', 'Corporation')
    @bookmarks = new BookmarkFolder('bookmarks', 'Bookmarks')

    @vue_state_counter = 0

  load: () ->
    # TODO: load from API call
    @towns.add_child(new Bookmark('town-a', 'Town A', 256, 256, {type:'TOWN'}))

    @my_folder_1 = new BookmarkFolder('my-folder-1', 'My Folder 1')
    @my_folder_2 = new BookmarkFolder('my-folder-2', 'My Folder 2')
    @my_folder_3 = new BookmarkFolder('my-folder-3', 'My Folder 3')
    @bookmarks.add_child(@my_folder_1)
    @bookmarks.add_child(@my_folder_2)
    @bookmarks.add_child(new Bookmark('my-bookmark-1', 'My Bookmark 1', 256, 256))
    @bookmarks.add_child(new Bookmark('my-bookmark-2', 'My Bookmark 2', 256, 256))
    @my_folder_1.add_child(new Bookmark('my-bookmark-3', 'My Bookmark 3', 256, 256))
    @my_folder_2.add_child(@my_folder_3)
    @my_folder_2.add_child(new Bookmark('my-bookmark-4', 'My Bookmark 4', 256, 256))
    @my_folder_2.add_child(new Bookmark('my-bookmark-5', 'My Bookmark 5', 256, 256))
    @my_folder_3.add_child(new Bookmark('my-bookmark-6', 'My Bookmark 6', 256, 256))

    @company_1 = new BookmarkFolder('company-1', 'Dissidents Company', {type:'CORPORATION', seal:'DIS'})
    @company_2 = new BookmarkFolder('company-2', 'Magna Corp Company', {type:'CORPORATION', seal:'MAGNA'})
    @company_3 = new BookmarkFolder('company-3', 'Mariko Enterprises Company', {type:'CORPORATION', seal:'MKO'})
    @company_4 = new BookmarkFolder('company-4', 'The Moab Company', {type:'CORPORATION', seal:'MOAB'})
    @company_5 = new BookmarkFolder('company-5', 'Pure Gaba Initiative Company', {type:'CORPORATION', seal:'PGI'})
    @corporation.add_child(@company_1)
    @corporation.add_child(@company_2)
    @corporation.add_child(@company_3)
    @corporation.add_child(@company_4)
    @corporation.add_child(@company_5)

    @vue_state_counter += 1

  sections: () ->
    @towns.hidden = !@options.option('bookmarks.towns')
    @mausoleums.hidden = !@options.option('bookmarks.mausoleums')

    sections = []
    sections.push(@points_of_interest) if @options.option('bookmarks.points_of_interest')
    sections.push(@corporation) if @options.option('bookmarks.corporation')
    sections.push(@bookmarks)
    sections
