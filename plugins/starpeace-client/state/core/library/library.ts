import EventListener from '~/plugins/starpeace-client/state/event-listener'

export default class Library {
  event_listener: EventListener = new EventListener();

  subscribe_listener (callback: Function): void {
    this.event_listener.subscribe('core.library.assets', callback);
  }
  notify_listeners (): void {
    this.event_listener.notify_listeners('core.library.assets');
  }

  reset_multiverse () {
    // nothing to do, may be overriden
  }
  reset_planet () {
    // nothing to do, may be overriden
  }
}
