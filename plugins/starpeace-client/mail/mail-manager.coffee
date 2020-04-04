
import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class MailManager
  constructor: (@api, @ajax_state, @client_state) ->

  load_by_corporation: (corporation_id) ->
    new Promise (done, error) =>
      if !@client_state.has_session() || !corporation_id? || @ajax_state.is_locked('mail_metadata', corporation_id)
        done()
      else
        @ajax_state.lock('mail_metadata', corporation_id)
        @api.mail_for_corporation(corporation_id)
          .then (metadata) =>
            items = []
            # FIXME: TODO: convert json to object
            @client_state.player.set_mail_metadata(metadata)

            @ajax_state.unlock('mail_metadata', corporation_id)
            done()

          .catch (err) =>
            @ajax_state.unlock('mail_metadata', corporation_id) # FIXME: TODO add error handling
            error()
