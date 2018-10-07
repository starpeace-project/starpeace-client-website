
import Logger from '~/plugins/starpeace-client/logger.coffee'

MENUBAR_LEFT = {
  'planetary': true
  'bookmarks': true
  'tycoon': true
}
MENUBAR_BODY = {
  'mail': true
  'chat': true
  'options': true
  'help': true
  'release_notes': true
}
MENUBAR_RIGHT = {
  'construction': true
}

export default class MenuState
  constructor: () ->
    @toolbar_left = null
    @toolbar_body = null
    @toolbar_right = null

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

  toggle_menu: (type) ->
    if type == 'hide_all'
      @hide_all_menus()
    else if MENUBAR_LEFT[type]
      @toolbar_left = if @toolbar_left == type then null else type
    else if MENUBAR_BODY[type]
      @toolbar_body = if @toolbar_body == type then null else type
    else if MENUBAR_RIGHT[type]
      @toolbar_right = if @toolbar_right == type then null else type
    else
      Logger.info "unknown menu type #{type}"
