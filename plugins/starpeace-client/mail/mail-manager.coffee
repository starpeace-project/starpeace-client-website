
import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class MailManager
  constructor: (@api, @event_listener, @game_state) ->

  load_metadata: (corporation_id) ->
    new Promise (done, error) =>
      @game_state.session_state.start_mail_metadata_request()
      @api.mail_metadata(@game_state.session_state.session_token, corporation_id)
        .then (metadata) =>
          @game_state.session_state.set_mail_metadata(metadata)
          @game_state.session_state.finish_mail_metadata_request()
          @event_listener.notify_mail_metadata_listeners()
          done()

        .catch (err) =>
          @game_state.session_state.finish_mail_metadata_request()
          # FIXME: TODO: add error handling (failed to get tycoon metadata)
          error()
