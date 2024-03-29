import _ from 'lodash'
import { DateTime } from 'luxon';

import Utils from '~/plugins/starpeace-client/utils/utils'

export default class SandboxMail
  constructor: (@sandbox) ->

  add_mail: (corporation, id, mail) ->
    mail.id = id
    if @sandbox.sandbox_data.corporation.cashflowByCorporationId[corporation.id]?
      @sandbox.sandbox_data.corporation.cashflowByCorporationId[corporation.id].lastMailAt = DateTime.fromISO(mail.sentAt)
    @sandbox.sandbox_data.corporation.mailByCorporationId[corporation.id] = {} unless @sandbox.sandbox_data.corporation.mailByCorporationId[corporation.id]?
    @sandbox.sandbox_data.corporation.mailByCorporationId[corporation.id][id] = mail


  get: (corporation_id) ->
    _.cloneDeep(_.orderBy(_.values(@sandbox.sandbox_data.corporation.mailByCorporationId[corporation_id]), 'sentAt'))

  create: (corporation_id, parameters) ->
    throw new Error(400) unless _.trim(parameters.to).length
    throw new Error(400) unless _.trim(parameters.subject).length
    throw new Error(400) unless _.trim(parameters.body).length

    sender_corp = @sandbox.sandbox_data.corporation.corporationById[corporation_id]
    throw new Error(404) unless sender_corp?

    other_corps = _.filter(_.values(@sandbox.sandbox_data.corporation.corporationById), (c) -> c.planetId == sender_corp.planetId)

    to_corps = []
    undeliverable = []
    for name in _.trim(parameters.to).split(';')
      to_corp = _.find(other_corps, (c) => _.toLower(@sandbox.sandbox_data.corporation.tycoonById[c.tycoonId].name) == _.toLower(_.trim(name)))
      if to_corp?
        to_corps.push to_corp
      else
        undeliverable.push name

    for to_corp in to_corps
      @add_mail(to_corp, Utils.uuid(), {
        read: false
        sentAt: DateTime.now().toISO()
        planetSentAt: @sandbox.sandbox_data.planet_id_dates[sender_corp.planetId].toISODate()
        from: {
          id: sender_corp.tycoonId,
          name: @sandbox.sandbox_data.corporation.tycoonById[sender_corp.tycoonId].name
        }
        to: _.map(to_corps, (c) => {
          id: c.tycoonId,
          name: @sandbox.sandbox_data.corporation.tycoonById[c.tycoonId].name
        })
        subject: _.trim(parameters.subject)
        body: _.trim(parameters.body)
      })

    if undeliverable.length
      @add_mail(sender_corp, Utils.uuid(), {
        read: false
        sentAt: DateTime.now().toISO()
        planetSentAt: @sandbox.sandbox_data.planet_id_dates[sender_corp.planetId].toISODate()
        from: {
          id: "ifel",
          name: "IFEL"
        }
        to: [{
          id: sender_corp.tycoonId,
          name: @sandbox.sandbox_data.corporation.tycoonById[sender_corp.tycoonId].name
        }]
        subject: "Undeliverable: #{_.trim(parameters.subject)}"
        body: "Unable to deliver mail to #{undeliverable.join(', ')}"
      })

    _.cloneDeep({})

  mark_read: (corporation_id, mail_id) ->
    if @sandbox.sandbox_data.corporation.mailByCorporationId[corporation_id]?[mail_id]?
      @sandbox.sandbox_data.corporation.mailByCorporationId[corporation_id][mail_id].read = true
      return true
    false

  delete: (corporation_id, mail_id) ->
    if @sandbox.sandbox_data.corporation.mailByCorporationId[corporation_id]?[mail_id]?
      delete @sandbox.sandbox_data.corporation.mailByCorporationId[corporation_id][mail_id]
      return true
    false
