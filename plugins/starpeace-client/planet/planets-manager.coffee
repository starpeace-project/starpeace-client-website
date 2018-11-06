
export default class PlanetsManager
  constructor: (@api, @event_listener, @game_state) ->

  load_metadata: (system_id=null) ->
    new Promise (done, error) =>
      @game_state.common_metadata.start_planets_metadata_request()
      @api.planets_metadata(@game_state.session_state.session_token, system_id || @game_state.session_state.system_id)
        .then (planets) =>
          @game_state.common_metadata.set_planets_metadata_for_system(planets) if planets? && Array.isArray(planets)
          @game_state.common_metadata.finish_planets_metadata_request()
          done()

        .catch (err) =>
          # FIXME: TODO: add error handling (failed to get planets metadata)
          @game_state.common_metadata.finish_planets_metadata_request()
          error()

  load_details: (planet_id) ->
    new Promise (done, error) =>
      @game_state.session_state.start_planet_details_request()
      @api.planet_details(@game_state.session_state.session_token, planet_id)
        .then (details) =>
          @game_state.session_state.set_planet_details(details)
          @game_state.session_state.finish_planet_details_request()
          @event_listener.notify_planet_details_listeners()
          done()

        .catch (err) =>
          # FIXME: TODO: add error handling (failed to get planets metadata)
          @game_state.session_state.finish_planet_details_request()
          console.log err
          error()
