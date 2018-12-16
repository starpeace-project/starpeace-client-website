
import moment from 'moment'
import Vue from 'vue'

import EventListener from '~/plugins/starpeace-client/state/event-listener.coffee'

import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class BookmarkState
  constructor: () ->
    @event_listener = new EventListener()
    @reset_state()

  reset_state: () ->
    @town_items = []
    @mausoleum_items = []

    @corporation_items = []

    @bookmarks_by_id = null


  has_data: () -> @bookmarks_by_id?

  subscribe_bookmarks_metadata_listener: (listener_callback) -> @event_listener.subscribe('player.bookmarks_metadata', listener_callback)
  notify_bookmarks_metadata_listeners: () -> @event_listener.notify_listeners('player.bookmarks_metadata')

  folder_count: () -> _.filter(_.values(@bookmarks_by_id || {}), (item) -> item.is_folder()).length
  item_count: () -> _.filter(_.values(@bookmarks_by_id || {}), (item) -> !item.is_folder()).length


  set_bookmarks_metadata: (bookmarks_items) ->
    @bookmarks_by_id = {}
    Vue.set(@bookmarks_by_id, item.id, item) for item in (bookmarks_items || [])
    @notify_bookmarks_metadata_listeners()

  add_bookmarks_metadata: (bookmark_item) ->
    Vue.set(@bookmarks_by_id, bookmark_item.id, bookmark_item)
