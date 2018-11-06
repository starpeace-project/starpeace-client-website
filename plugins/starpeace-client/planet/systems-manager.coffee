
export default class SystemsManager
  constructor: (@api, @game_state) ->

  load_metadata: () ->
    new Promise (done, error) =>
      @game_state.common_metadata.start_systems_metadata_request()
      @api.systems_metadata(@game_state.session_state.session_token)
        .then (systems) =>
          @game_state.common_metadata.set_systems_metadata(systems) if systems? && Array.isArray(systems)
          @game_state.common_metadata.finish_systems_metadata_request()
          done()

        .catch (err) =>
          # FIXME: TODO: add error handling (failed to get systems metadata)
          @game_state.common_metadata.finish_systems_metadata_request()
          error()
