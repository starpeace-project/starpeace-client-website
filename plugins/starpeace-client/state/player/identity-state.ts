import EventListener from '~/plugins/starpeace-client/state/event-listener';

import CorporationIdentifier from '~/plugins/starpeace-client/corporation/corporation-identifier';

import Tycoon from '~/plugins/starpeace-client/tycoon/tycoon';


export default class IdentityState {
  event_listener: EventListener;

  galaxy_id: string | null = null;
  galaxy_visa_type: string | null = null;
  galaxy_tycoon_id: string | null = null;
  galaxy_tycoon_name: string | null = null;


  constructor () {
    this.event_listener = new EventListener();
  }

  reset_state (): void {
    this.galaxy_id = null
    this.galaxy_visa_type = null
    this.galaxy_tycoon_id = null
    this.galaxy_tycoon_name = null
  }

  subscribe_visa_type_listener (listener_callback: Function): void {
    this.event_listener.subscribe('identity.visa_type', listener_callback);
  }
  notify_visa_type_listeners (): void {
    this.event_listener.notify_listeners('identity.visa_type');
  }

  set_visa (galaxy_id: string, visa_type: string, tycoon: Tycoon): void {
    this.galaxy_id = galaxy_id;
    this.galaxy_visa_type = visa_type;
    this.galaxy_tycoon_id = tycoon.id;
    this.galaxy_tycoon_name = tycoon.name;
    this.notify_visa_type_listeners();
  }

}
