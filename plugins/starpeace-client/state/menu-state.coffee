
import Logger from '~/plugins/starpeace-client/logger.coffee'

MULTI_MENUBARS = {
  'research': ['left', 'body', 'right']
}

MENUBAR_LEFT = {
  'systems': true
  'bookmarks': true
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
}

export default class MenuState
  constructor: () ->
    @toolbar_left = null
    @toolbar_body = null
    @toolbar_right = null

    @state_counter = 0

  is_toolbar_left_open: () -> @toolbar_left?.length
  is_toolbar_right_open: () -> @toolbar_right?.length

  is_any_menu_open: () ->
    @toolbar_left?.length || @toolbar_body?.length || @toolbar_right?.length || @show_menu_release_notes

  is_visible: (type) ->
    return @toolbar_left == type if MENUBAR_LEFT[type]
    return @toolbar_body == type if MENUBAR_BODY[type]
    return @toolbar_right == type if MENUBAR_RIGHT[type]
    false

  hide_all_menus: () ->
    @toolbar_left = null
    @toolbar_body = null
    @toolbar_right = null
    @state_counter += 1

  toggle_menu: (type) ->
    if type == 'hide_all'
      @hide_all_menus()
      return

    clear_menus = (positions) =>
      for position in positions
        @toolbar_left = null if position == 'left'
        @toolbar_body = null if position == 'body'
        @toolbar_right = null if position == 'right'
      @state_counter += 1

    if MENUBAR_LEFT[type]
      clear_menus(MULTI_MENUBARS[@toolbar_left]) if MULTI_MENUBARS[@toolbar_left]? && @toolbar_left != type
      @toolbar_left = if @toolbar_left == type then null else type
      @state_counter += 1

    if MENUBAR_BODY[type]
      clear_menus(MULTI_MENUBARS[@toolbar_body]) if MULTI_MENUBARS[@toolbar_body]? && @toolbar_body != type
      @toolbar_body = if @toolbar_body == type then null else type
      @state_counter += 1

    if MENUBAR_RIGHT[type]
      clear_menus(MULTI_MENUBARS[@toolbar_right]) if MULTI_MENUBARS[@toolbar_right]? && @toolbar_right != type
      @toolbar_right = if @toolbar_right == type then null else type
      @state_counter += 1

    unless MENUBAR_LEFT[type]? || MENUBAR_BODY[type]? || MENUBAR_RIGHT[type]?
      Logger.info "unknown menu type #{type}"
