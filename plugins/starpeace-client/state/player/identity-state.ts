import EventListener from '~/plugins/starpeace-client/state/event-listener';

import Tycoon from '~/plugins/starpeace-client/tycoon/tycoon';


export default class IdentityState {
  event_listener: EventListener;

  galaxy_id: string | undefined = undefined;
  galaxy_visa_type: string | undefined = undefined;
  galaxy_tycoon_id: string | undefined = undefined;
  galaxy_tycoon_name: string | undefined = undefined;


  constructor () {
    this.event_listener = new EventListener();
  }

  reset_state (): void {
    this.galaxy_id = undefined;
    this.galaxy_visa_type = undefined;
    this.galaxy_tycoon_id = undefined;
    this.galaxy_tycoon_name = undefined;
  }

  subscribe_visa_type_listener (listener_callback: Function): void {
    this.event_listener.subscribe('identity.visa_type', listener_callback);
  }
  notify_visa_type_listeners (): void {
    this.event_listener.notify_listeners('identity.visa_type');
  }

  set_visa (galaxy_id: string, visa_type: string, tycoon: Tycoon | undefined): void {
    this.galaxy_id = galaxy_id;
    this.galaxy_visa_type = visa_type;
    this.galaxy_tycoon_id = tycoon?.id;
    this.galaxy_tycoon_name = tycoon?.name;
    this.notify_visa_type_listeners();
  }

}
