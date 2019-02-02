
import EventListener from '~/plugins/starpeace-client/state/event-listener.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'

MULTI_MENUBARS = {
  'research': ['left', 'body', 'right']
}

MENUBAR_LEFT = {
  'galaxy': true
  'bookmarks': true
  'politics': true
  'rankings': true
  'research': true
  'tycoon': true
}
MENUBAR_BODY = {
  'mail': true
  'chat': true
  'options': true
  'help': true
  'release_notes': true
  'research': true
}
MENUBAR_RIGHT = {
  'construction': true
  'research': true
  'town_search': true
  'tycoon_search': true
}

export default class MenuState
  constructor: () ->
    @event_listener = new EventListener()
    @reset_state()

  subscribe_menu_listener: (listener_callback) -> @event_listener.subscribe('menu.state', listener_callback)
  notify_menu_listeners: () -> @event_listener.notify_listeners('menu.state')

  reset_state: () ->
    @toolbar_left = null
    @toolbar_body = null
    @toolbar_right = null
    @notify_menu_listeners()

  is_toolbar_left_open: () -> @toolbar_left?.length
  is_toolbar_right_open: () -> @toolbar_right?.length

  is_any_menu_open: () ->
    @toolbar_left?.length || @toolbar_body?.length || @toolbar_right?.length

  is_visible: (type) ->
    return @toolbar_left == type if MENUBAR_LEFT[type]
    return @toolbar_body == type if MENUBAR_BODY[type]
    return @toolbar_right == type if MENUBAR_RIGHT[type]
    false

  hide_all_menus: () ->
    @toolbar_left = null
    @toolbar_body = null
    @toolbar_right = null
    @notify_menu_listeners()

  toggle_menu: (type) ->
    if type == 'hide_all'
      @hide_all_menus()
      return

    clear_menus = (positions) =>
      for position in positions
        @toolbar_left = null if position == 'left'
        @toolbar_body = null if position == 'body'
        @toolbar_right = null if position == 'right'

    if MENUBAR_LEFT[type]
      clear_menus(MULTI_MENUBARS[@toolbar_left]) if MULTI_MENUBARS[@toolbar_left]? && @toolbar_left != type
      @toolbar_left = if @toolbar_left == type then null else type

    if MENUBAR_BODY[type]
      clear_menus(MULTI_MENUBARS[@toolbar_body]) if MULTI_MENUBARS[@toolbar_body]? && @toolbar_body != type
      @toolbar_body = if @toolbar_body == type then null else type

    if MENUBAR_RIGHT[type]
      clear_menus(MULTI_MENUBARS[@toolbar_right]) if MULTI_MENUBARS[@toolbar_right]? && @toolbar_right != type
      @toolbar_right = if @toolbar_right == type then null else type

    @notify_menu_listeners()

    unless MENUBAR_LEFT[type]? || MENUBAR_BODY[type]? || MENUBAR_RIGHT[type]?
      Logger.info "unknown menu type #{type}"
