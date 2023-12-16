import { DateTime } from 'luxon';

import Mail from '~/plugins/starpeace-client/mail/mail.js'

import type ApiClient from '~/plugins/starpeace-client/api/api-client.js';
import type AjaxState from '~/plugins/starpeace-client/state/ajax-state.js';
import type ClientState from '~/plugins/starpeace-client/state/client-state.js';

export default class MailManager {
  api: ApiClient;
  ajaxState: AjaxState;
  clientState: ClientState;

  constructor (api: ApiClient, ajaxState: AjaxState, clientState: ClientState) {
    this.api = api;
    this.ajaxState = ajaxState;
    this.clientState = clientState;
  }

  async load_by_corporation (corporationId: string): Promise<Array<Mail>> {
    if (!this.clientState.has_session() || !corporationId) {
      throw Error();
    }
    return await this.ajaxState.locked('mail_metadata', corporationId, async () => {
      const mails = (await this.api.mail_for_corporation(corporationId)).map(Mail.from_json);
      this.clientState.player.set_mail(mails);
      this.clientState.player.last_mail_at = DateTime.now();
      return mails;
    });
  }

  async mark_read (corporationId: string, mailId: string): Promise<void> {
    if (!this.clientState.has_session() || !corporationId || !mailId) {
      throw Error();
    }
    await this.ajaxState.locked('mail_mark_read', mailId, async () => {
      if (!!this.clientState.player.mail_by_id[mailId]) {
        this.clientState.player.mail_by_id[mailId].read = true;
      }
      await this.api.mark_mail_read(corporationId, mailId);
    });
  }

  async delete (corporationId: string, mailId: string): Promise<void> {
    if (!this.clientState.has_session() || !corporationId || !mailId) {
      throw Error();
    }
    await this.ajaxState.locked('mail_delete', mailId, async () => {
      await this.api.delete_mail(corporationId, mailId)
      this.clientState.player.remove_mail(mailId);
    });
  }

  async send_mail (corporationId: string, to: string, subject: string, body: string): Promise<void> {
    if (!this.clientState.has_session() || !corporationId || !to || !subject || !body) {
      throw Error();
    }
    await this.ajaxState.locked('mail_send', corporationId, async () => {
      await this.api.send_mail(corporationId, to, subject, body);
    });
  }
}
