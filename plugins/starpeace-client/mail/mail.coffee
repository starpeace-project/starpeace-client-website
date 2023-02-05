import _ from 'lodash'
import { DateTime } from 'luxon';

import MailEntity from '~/plugins/starpeace-client/mail/mail-entity.coffee'

export default class Mail
  constructor: () ->

  @from_json: (json) ->
    mail = new Mail()
    mail.id = json.id
    mail.read = json.read
    mail.sent_at = DateTime.fromISO(json.sentAt)
    mail.planet_sent_at = DateTime.fromISO(json.planetSentAt)
    mail.from_entity = MailEntity.from_json(json.from)
    mail.to_entities = _.map(json.to, MailEntity.from_json)
    mail.subject = json.subject
    mail.body = json.body
    mail
