import { markRaw } from 'vue';

import EventListener from '~/plugins/starpeace-client/state/event-listener.js'

const MENUBAR: Record<string, Array<string>> = {
  'research': ['left', 'body', 'right'],

  'mail': ['left', 'body'],
  'tycoon': ['left', 'body'],

  'bookmarks': ['left'],
  'galaxy': ['left'],
  'politics': ['left'],

  'company_form': ['body'],
  'help': ['body'],
  'options': ['body'],
  'release_notes': ['body'],

  'construction': ['body', 'right'],

  'chat': ['right'],
  'rankings': ['right'],
  'town_search': ['right'],
  'tycoon_search': ['right']
};

export default class MenuState {
  event_listener: EventListener;
  toolbars: Record<string, string | null>;

  constructor () {
    this.event_listener = markRaw(new EventListener());
    this.toolbars = {
      left: null,
      body: null,
      right: null
    };
  }

  subscribe_menu_listener (callback: () => void) {
    this.event_listener.subscribe('menu.state', callback);
  }
  notify_menu_listeners (): void {
    this.event_listener.notify_listeners('menu.state');
  }

  reset_state (): void {
    this.toolbars.left = null;
    this.toolbars.body = null;
    this.toolbars.right = null;
    this.notify_menu_listeners();
  }

  is_toolbar_left_open (): boolean {
    return !!this.toolbars.left;
  }
  is_toolbar_body_open (): boolean {
    return !!this.toolbars.body;
  }
  is_toolbar_right_open (): boolean {
    return !!this.toolbars.right;
  }

  is_visible (type: string): boolean {
    return this.toolbars.left === type || this.toolbars.body === type || this.toolbars.right === type;
  }

  hide_menu (type: string): void {
    if (!!this.toolbars[type]) {
      this.toggle_menu(this.toolbars[type] as string);
    }
  }
  hide_all_menus (): void {
    this.toolbars.left = null;
    this.toolbars.body = null;
    this.toolbars.right = null;
    this.notify_menu_listeners();
  }

  toggle_menu (type: string): void {
    if (type === 'hide_all') {
      this.hide_all_menus();
      return;
    }

    const toDisable = new Set<string>();
    for (const position of (MENUBAR[type] ?? [])) {
      if (!!this.toolbars[position]) {
        toDisable.add(this.toolbars[position] as string);
      }
      if (this.toolbars[position] !== type) {
        this.toolbars[position] = type;
      }
    }

    for (const disableType of Array.from(toDisable)) {
      for (const position of (MENUBAR[disableType] ?? [])) {
        if (this.toolbars[position] === disableType) {
          this.toolbars[position] = null;
        }
      }
    }

    this.notify_menu_listeners();
  }
}
