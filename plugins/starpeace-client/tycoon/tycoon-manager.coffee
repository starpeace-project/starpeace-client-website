
import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class TycoonManager
  constructor: (@api, @game_state) ->

  load_metadata: () ->
    new Promise (done, error) =>

      if @game_state.session_state.identity.is_visitor()
        done()
      else if @game_state.session_state.identity.is_tycoon() && @game_state.session_state.tycoon_id?
        @game_state.session_state.start_tycoon_metadata_request()
        @api.tycoon_metadata(@game_state.session_state.session_token, @game_state.session_state.tycoon_id)
          .then (tycoon_metadata) =>
            @game_state.session_state.set_tycoon_metadata(tycoon_metadata)
            @game_state.session_state.finish_tycoon_metadata_request()
            done()

          .catch (err) ->
            @game_state.session_state.finish_tycoon_metadata_request()
            # FIXME: TODO: add error handling (failed to get tycoon metadata)
            error()
      else
        Logger.debug "identity in bad state, not able to retrieve tycoon metadata"
        done()
