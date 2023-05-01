import { markRaw } from 'vue';

import EventListener from '~/plugins/starpeace-client/state/event-listener'

export default class Cache {
  event_listener: EventListener;

  constructor () {
    this.event_listener = markRaw(new EventListener());
  }

  static FIVE_MINUTES = 300000;
  static ONE_MINUTE = 60000;

  reset_multiverse () {
    // nothing to do, may be overriden
  }
  reset_planet () {
    // nothing to do, may be overriden
  }
}
