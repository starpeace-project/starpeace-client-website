import moment from 'moment'

import Mail from '~/plugins/starpeace-client/mail/mail.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class MailManager
  constructor: (@api, @ajax_state, @client_state) ->

  load_by_corporation: (corporation_id) ->
    mail_at = moment()
    throw Error() if !@client_state.has_session() || !corporation_id?
    await @ajax_state.locked('mail_metadata', corporation_id, =>
      mails = _.map(await @api.mail_for_corporation(corporation_id), Mail.from_json)
      @client_state.player.set_mail(mails)
      @client_state.player.last_mail_at = mail_at
      mails
    )


  mark_read: (corporation_id, mail_id) ->
    throw Error() if !@client_state.has_session() || !corporation_id? || !mail_id?
    await @ajax_state.locked('mail_mark_read', mail_id, =>
      @client_state.player.mail_by_id[mail_id].read = true if @client_state.player.mail_by_id[mail_id]?
      await @api.mark_mail_read(corporation_id, mail_id)
    )

  delete: (corporation_id, mail_id) ->
    throw Error() if !@client_state.has_session() || !corporation_id? || !mail_id?
    await @ajax_state.locked('mail_delete', mail_id, =>
      await @api.delete_mail(corporation_id, mail_id)
      @client_state.player.remove_mail(mail_id)
    )

  send_mail: (corporation_id, to, subject, body) ->
    throw Error() if !@client_state.has_session() || !corporation_id? || !to? || !subject? || !body?
    await @ajax_state.locked('mail_send', corporation_id, =>
      await @api.send_mail(corporation_id, to, subject, body)
    )
