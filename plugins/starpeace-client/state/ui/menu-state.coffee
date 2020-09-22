
import EventListener from '~/plugins/starpeace-client/state/event-listener.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'


MENUBAR_ALL = new Set([ 'company_form', 'research' ])
MENUBAR_LEFT = new Set([ 'bookmarks', 'galaxy', 'politics', 'rankings', 'tycoon' ])
MENUBAR_BODY = new Set([ 'chat', 'help', 'mail', 'options', 'release_notes' ])
MENUBAR_RIGHT = new Set([ 'construction', 'town_search', 'tycoon_search' ])

export default class MenuState
  constructor: () ->
    @event_listener = new EventListener()
    @reset_state()

  subscribe_menu_listener: (listener_callback) -> @event_listener.subscribe('menu.state', listener_callback)
  notify_menu_listeners: () -> @event_listener.notify_listeners('menu.state')

  reset_state: () ->
    @toolbar_all = null
    @toolbar_left = null
    @toolbar_body = null
    @toolbar_right = null
    @notify_menu_listeners()

  is_toolbar_left_open: () -> @toolbar_left?.length
  is_toolbar_right_open: () -> @toolbar_right?.length

  is_visible: (type) -> @toolbar_all == type || @toolbar_left == type || @toolbar_body == type || @toolbar_right == type

  hide_all_menus: () ->
    @toolbar_all = null
    @toolbar_left = null
    @toolbar_body = null
    @toolbar_right = null
    @notify_menu_listeners()

  toggle_menu: (type) ->
    if type == 'hide_all'
      @hide_all_menus()
      return

    if MENUBAR_ALL.has(type)
      @toolbar_all = if @toolbar_all == type then null else type
      @toolbar_left = null
      @toolbar_body = null
      @toolbar_right = null
    else if MENUBAR_LEFT.has(type)
      @toolbar_all = null
      @toolbar_left = if @toolbar_left == type then null else type
    else if MENUBAR_BODY.has(type)
      @toolbar_all = null
      @toolbar_body = if @toolbar_body == type then null else type
    else if MENUBAR_RIGHT.has(type)
      @toolbar_all = null
      @toolbar_right = if @toolbar_right == type then null else type
    else
      Logger.info "unknown menu type #{type}"

    @notify_menu_listeners()
