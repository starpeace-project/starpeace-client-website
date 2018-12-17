
import moment from 'moment'

import DetailsPlanet from '~/plugins/starpeace-client/planet/details-planet.coffee'

export default class PlanetsManager
  constructor: (@api, @ajax_state, @client_state) ->

  load_details: (planet_id) ->
    new Promise (done, error) =>
      if !@client_state.has_session() || !planet_id? || @ajax_state.is_locked('planet_details', planet_id)
        done()
      else
        @ajax_state.lock('planet_details', planet_id)
        @api.planet_details(@client_state.session.session_token, planet_id)
          .then (json) =>
            details = DetailsPlanet.from_json(json)
            @client_state.planet.load_planet_details(details)
            @client_state.planet.tycoons_online = json.tycoons_online
            @client_state.planet.current_date = json.date
            @client_state.planet.current_season = json.season

            @ajax_state.unlock('planet_details', planet_id)
            done()

          .catch (err) =>
            @ajax_state.unlock('planet_details', planet_id) # FIXME: TODO add error handling
            error()

  load_events: () ->
    new Promise (done, error) =>
      planet_id = @client_state.player.planet_id
      last_update = @client_state.planet.events_as_of || @client_state.planet.details_as_of

      if !@client_state.has_session() || !planet_id? || !last_update? || @ajax_state.is_locked('planet_events', planet_id)
        done()
      else
        @ajax_state.lock('planet_events', planet_id)
        @api.planet_events(@client_state.session.session_token, planet_id, last_update)
          .then (planet_event) =>
            # FIXME: TODO: convert json to object
            @client_state.planet.current_date = planet_event.date
            @client_state.planet.current_season = planet_event.season
            @client_state.planet.events_as_of = moment()

            @ajax_state.unlock('planet_events', planet_id)
            done()

          .catch (err) =>
            @ajax_state.unlock('planet_events', planet_id) # FIXME: TODO add error handling
            error()
