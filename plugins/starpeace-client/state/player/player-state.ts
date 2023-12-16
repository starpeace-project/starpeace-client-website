import { DateTime } from 'luxon';
import { markRaw } from 'vue';

import EventListener from '~/plugins/starpeace-client/state/event-listener'

import Logger from '~/plugins/starpeace-client/logger'

export default class PlayerState {
  event_listener: EventListener;

  planet_id: string | null = null;
  planet_visa_type: string | null = null;
  planet_visa_id: string | null = null;

  tycoon_id: string | null = null;
  corporation_id: string | null = null;
  company_id: string | undefined = undefined;

  last_mail_at: DateTime | null = null;
  mail_by_id: Record<string, string> | null = null;
  selected_mail_id: string | null = null;

  mail_compose_mode: boolean = false;
  mail_compose_to: string = '';
  mail_compose_subject: string = '';
  mail_compose_body: string = '';

  constructor () {
    this.event_listener = markRaw(new EventListener());
  }

  reset_state (): void {
    this.planet_id = null;
    this.planet_visa_type = null;
    this.planet_visa_id = null;

    this.tycoon_id = null;
    this.corporation_id = null;
    this.company_id = undefined;

    this.last_mail_at = null;
    this.mail_by_id = null;
    this.selected_mail_id = null;

    this.mail_compose_mode = false;
    this.mail_compose_to = '';
    this.mail_compose_subject = '';
    this.mail_compose_body = '';
  }

  has_data (): boolean {
    return !!this.mail_by_id;
  }

  subscribe_planet_visa_type_listener (callback: () => void) {
    this.event_listener.subscribe('player.visa_type', callback);
  }
  notify_planet_visa_type_listeners () {
    this.event_listener.notify_listeners('player.visa_type');
  }

  subscribe_planet_visa_id_listener (callback: () => void) {
    this.event_listener.subscribe('player.planet_visa_id', callback);
  }
  notify_planet_visa_id_listeners () {
    this.event_listener.notify_listeners('player.planet_visa_id');
  }

  subscribe_corporation_id_listener (callback: () => void) {
    this.event_listener.subscribe('player.corporation_id', callback);
  }
  notify_corporation_id_listeners () {
    this.event_listener.notify_listeners('player.corporation_id');
  }

  subscribeCompanyIdListener (callback: () => void) {
    this.event_listener.subscribe('player.company_id', callback);
  }
  notifyCompanyIdListeners () {
    this.event_listener.notify_listeners('player.company_id');
  }

  subscribe_mail_listener (callback: () => void): void {
    this.event_listener.subscribe('player.mail', callback);
  }
  notify_mail_listeners () {
    this.event_listener.notify_listeners('player.mail');
  }

  set_planet_visa_type (planetId: string | null, visaType: string | null) {
    this.planet_id = planetId;
    this.planet_visa_type = visaType;
    this.corporation_id = null;
    Logger.debug(`proceeding with planet <${planetId}> and visa <${visaType}>`);
    this.notify_planet_visa_type_listeners();
  }

  set_planet_corporation_id (corporationId: string | null): void {
    this.corporation_id = corporationId;
    Logger.debug(`proceeding with corporation <${corporationId}>`);
    this.notify_corporation_id_listeners();
  }

  set_planet_visa_id (visaId: string | null): void {
    this.planet_visa_id = visaId;
    this.notify_planet_visa_id_listeners();
  }

  set_company_id (companyId: string | undefined) {
    if (this.company_id !== companyId) {
      this.company_id = companyId;
      this.notifyCompanyIdListeners();
    }
  }


  set_mail (mails: Array<any> | any): void {
    if (!this.mail_by_id) {
      this.mail_by_id = {};
    }
    if (Array.isArray(mails)) {
      for (const mail of mails) {
        this.mail_by_id[mail.id] = mail;
      }
    }
    else {
      this.mail_by_id[mails.id] = mails;
    }
    this.notify_mail_listeners();
  }

  remove_mail (mailId: string): void {
    if (this.selected_mail_id === mailId) {
      this.selected_mail_id = null;
    }
    if (!!this.mail_by_id?.[mailId]) {
      delete this.mail_by_id[mailId];
    }
    this.notify_mail_listeners();
  }

  start_compose (_toCorporations: Array<any> = []): void {
    this.mail_compose_mode = true;
  }
  end_compose (): void {
    this.mail_compose_mode = false;
    this.mail_compose_to = '';
    this.mail_compose_subject = '';
    this.mail_compose_body = '';
  }
}
