import moment from 'moment'

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
          @game_state.current_date = details.date
          @game_state.current_season = details.season
          @game_state.session_state.finish_planet_details_request()
          @event_listener.notify_planet_details_listeners()
          done()

        .catch (err) =>
          # FIXME: TODO: add error handling (failed to get planets metadata)
          @game_state.session_state.finish_planet_details_request()
          console.log err
          error()

  load_events: (planet_id) ->
    return unless @game_state.session_state.session_token?.length
    return if @game_state.session_state.planet_events_request

    last_update = @game_state.session_state.planet_events_as_of || @game_state.session_state.planet_details_as_of
    return unless last_update?

    new Promise (done, error) =>
      @game_state.session_state.start_planet_events_request()
      @api.planet_events(@game_state.session_state.session_token, planet_id, last_update)
        .then (planet_event) =>
          @game_state.current_date = planet_event.date
          @game_state.current_season = planet_event.season
          @game_state.session_state.planet_events_as_of = moment()
          @game_state.session_state.finish_planet_events_request()
          done()

        .catch (err) =>
          # FIXME: TODO: add error handling (failed to get planets metadata)
          @game_state.session_state.finish_planet_events_request()
          console.log err
          error()
