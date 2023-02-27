import { markRaw } from 'vue';

import EventListener from '~/plugins/starpeace-client/state/event-listener.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

MENUBAR = {
  'research': ['left', 'body', 'right']

  'mail': ['left', 'body']
  'tycoon': ['left', 'body']

  'bookmarks': ['left']
  'galaxy': ['left']
  'politics': ['left']

  'company_form': ['body']
  'help': ['body']
  'options': ['body']
  'release_notes': ['body']

  'construction': ['body', 'right']

  'chat': ['right']
  'rankings': ['right']
  'town_search': ['right']
  'tycoon_search': ['right']
}


export default class MenuState
  constructor: () ->
    @event_listener = markRaw(new EventListener())
    @toolbars = {
      left: null
      body: null
      right: null
    }

  subscribe_menu_listener: (listener_callback) -> @event_listener.subscribe('menu.state', listener_callback)
  notify_menu_listeners: () -> @event_listener.notify_listeners('menu.state')

  reset_state: () ->
    @toolbars.left = null
    @toolbars.body = null
    @toolbars.right = null
    @notify_menu_listeners()

  is_toolbar_left_open: () -> @toolbars.left?.length
  is_toolbar_body_open: () -> @toolbars.body?.length
  is_toolbar_right_open: () -> @toolbars.right?.length

  is_visible: (type) -> @toolbars.left == type || @toolbars.body == type || @toolbars.right == type

  hide_menu: (type) -> @toggle_menu(@toolbars[type]) if @toolbars[type]?
  hide_all_menus: () ->
    @toolbars['left'] = null
    @toolbars['body'] = null
    @toolbars['right'] = null
    @notify_menu_listeners()

  toggle_menu: (type) ->
    if type == 'hide_all'
      @hide_all_menus()
      return

    to_disable = new Set()
    for position in (MENUBAR[type] || [])
      to_disable.add(@toolbars[position]) if @toolbars[position]?.length
      @toolbars[position] = type unless @toolbars[position] == type

    for disable_type in Array.from(to_disable)
      for position in (MENUBAR[disable_type] || [])
        @toolbars[position] = null if @toolbars[position] == disable_type

    @notify_menu_listeners()
