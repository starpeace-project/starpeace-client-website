import { DateTime } from 'luxon';

import MailEntity from '~/plugins/starpeace-client/mail/mail-entity.js'

export default class Mail {
  id: string;
  read: boolean;
  sent_at: DateTime;
  planet_sent_at: DateTime;
  from_entity: MailEntity;
  to_entities: Array<MailEntity>;
  subject: string;
  body: string;

  constructor (id: string, read: boolean, sent_at: DateTime, planet_sent_at: DateTime, from_entity: MailEntity, to_entities: Array<MailEntity>, subject: string, body: string) {
    this.id = id;
    this.read = read;
    this.sent_at = sent_at;
    this.planet_sent_at = planet_sent_at;
    this.from_entity = from_entity;
    this.to_entities = to_entities;
    this.subject = subject;
    this.body = body;
  }

  static from_json (json: any): Mail {
    return new Mail(
      json.id,
      json.read,
      DateTime.fromISO(json.sentAt),
      DateTime.fromISO(json.planetSentAt),
      MailEntity.from_json(json.from),
      (json.to ?? []).map(MailEntity.from_json),
      json.subject,
      json.body
    );
  }
}
