
import moment from 'moment'
import _ from 'lodash'

import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

export default class SandboxMail
  constructor: (@sandbox) ->

  add_mail: (corporation, id, mail) ->
    mail.id = id
    if @sandbox.sandbox_data.corporation_id_cashflow[corporation.id]?
      @sandbox.sandbox_data.corporation_id_cashflow[corporation.id].lastMailAt = moment(mail.sentAt)
    @sandbox.sandbox_data.mail_by_corporation_id[corporation.id] = {} unless @sandbox.sandbox_data.mail_by_corporation_id[corporation.id]?
    @sandbox.sandbox_data.mail_by_corporation_id[corporation.id][id] = mail


  get: (corporation_id) ->
    _.cloneDeep(_.orderBy(_.values(@sandbox.sandbox_data.mail_by_corporation_id[corporation_id]), 'sentAt'))

  create: (corporation_id, parameters) ->
    throw new Error(400) unless _.trim(parameters.to).length
    throw new Error(400) unless _.trim(parameters.subject).length
    throw new Error(400) unless _.trim(parameters.body).length

    sender_corp = @sandbox.sandbox_data.corporation_by_id[corporation_id]
    throw new Error(404) unless sender_corp?

    other_corps = _.filter(_.values(@sandbox.sandbox_data.corporation_by_id), (c) -> c.planetId == sender_corp.planetId)

    to_corps = []
    undeliverable = []
    for name in _.trim(parameters.to).split(';')
      to_corp = _.find(other_corps, (c) => _.toLower(@sandbox.sandbox_data.tycoon_by_id[c.tycoonId].name) == _.toLower(_.trim(name)))
      if to_corp?
        to_corps.push to_corp
      else
        undeliverable.push name

    for to_corp in to_corps
      @add_mail(to_corp, Utils.uuid(), {
        read: false
        sentAt: moment().format()
        planetSentAt: @sandbox.sandbox_data.planet_id_dates[sender_corp.planetId].format('YYYY-MM-DD')
        from: {
          id: sender_corp.tycoonId,
          name: @sandbox.sandbox_data.tycoon_by_id[sender_corp.tycoonId].name
        }
        to: _.map(to_corps, (c) => {
          id: c.tycoonId,
          name: @sandbox.sandbox_data.tycoon_by_id[c.tycoonId].name
        })
        subject: _.trim(parameters.subject)
        body: _.trim(parameters.body)
      })

    if undeliverable.length
      @add_mail(sender_corp, Utils.uuid(), {
        read: false
        sentAt: moment().format()
        planetSentAt: @sandbox.sandbox_data.planet_id_dates[sender_corp.planetId].format('YYYY-MM-DD')
        from: {
          id: "ifel",
          name: "IFEL"
        }
        to: [{
          id: sender_corp.tycoonId,
          name: @sandbox.sandbox_data.tycoon_by_id[sender_corp.tycoonId].name
        }]
        subject: "Undeliverable: #{_.trim(parameters.subject)}"
        body: "Unable to deliver mail to #{undeliverable.join(', ')}"
      })

    _.cloneDeep({})

  mark_read: (corporation_id, mail_id) ->
    if @sandbox.sandbox_data.mail_by_corporation_id[corporation_id]?[mail_id]?
      @sandbox.sandbox_data.mail_by_corporation_id[corporation_id][mail_id].read = true
      return true
    false

  delete: (corporation_id, mail_id) ->
    if @sandbox.sandbox_data.mail_by_corporation_id[corporation_id]?[mail_id]?
      delete @sandbox.sandbox_data.mail_by_corporation_id[corporation_id][mail_id]
      return true
    false
