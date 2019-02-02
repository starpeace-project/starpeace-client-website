
import moment from 'moment'
import request from 'superagent'
import configuration from '~/plugins/starpeace-client/api/mock-api-configuration.coffee'
import superagentMock from 'superagent-mock'

superagentMock(request, configuration)

export default class APIClient
  constructor: (@client_state) ->

  galaxy_url: (galaxy_id=null) ->
    galaxy_id = @client_state.identity.galaxy_id unless galaxy_id?
    galaxy_config = if galaxy_id?.length then @client_state.core.galaxy_cache.galaxy_configuration(galaxy_id) else null
    throw "no configuration for galaxy" unless galaxy_config?.api_protocol? && galaxy_config?.api_url? && galaxy_config?.api_port?
    "#{galaxy_config.api_protocol}://#{galaxy_config.api_url}:#{galaxy_config.api_port}"


  galaxy_metadata: (galaxy_id=null) ->
    request
      .get("#{@galaxy_url(galaxy_id)}/galaxy/metadata")
      .set('accept', 'json')

  register_session: (identity) ->
    new Promise (done, error) =>
      request
        .post("#{@galaxy_url()}/session/register")
        .send({ type: identity.type, auth_token: identity.authentication_token })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            error(request_error)
          else
            done(result)
        )

  planet_details: (session_token, planet_id) ->
    new Promise (done, error) =>
      request
        .get("#{@galaxy_url()}/planet/details")
        .query({ session_token: session_token, planet_id: planet_id })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            @client_state.handle_authorization_error() if result.status == 401
            error(request_error)
          else
            done(result.planet)
        )
  planet_events: (session_token, planet_id, last_update) ->
    new Promise (done, error) =>
      request
        .get("#{@galaxy_url()}/planet/events")
        .query({ session_token: session_token, planet_id: planet_id, last_update: last_update.format() })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            @client_state.handle_authorization_error() if result.status == 401
            error(request_error)
          else
            done(result.planet)
        )

  tycoon_metadata: (session_token, tycoon_id) ->
    new Promise (done, error) =>
      request
        .get("#{@galaxy_url()}/tycoon/metadata")
        .query({ session_token: session_token, tycoon_id: tycoon_id })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            @client_state.handle_authorization_error() if result.status == 401
            error(request_error)
          else
            done(result.tycoon)
        )

  corporation_metadata: (session_token, corporation_id) ->
    new Promise (done, error) =>
      request
        .get("#{@galaxy_url()}/corporation/metadata")
        .query({ session_token: session_token, corporation_id: corporation_id })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            @client_state.handle_authorization_error() if result.status == 401
            error(request_error)
          else
            done(result.corporation)
        )
  corporation_events: (session_token, corporation_id, last_update) ->
    new Promise (done, error) =>
      request
        .get("#{@galaxy_url()}/corporation/events")
        .query({ session_token: session_token, corporation_id: corporation_id, last_update: last_update.format() })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            @client_state.handle_authorization_error() if result.status == 401
            error(request_error)
          else
            done(result.corporation)
        )

  bookmarks_metadata: (session_token, corporation_id) ->
    new Promise (done, error) =>
      request
        .get("#{@galaxy_url()}/bookmarks/metadata")
        .query({ session_token: session_token, corporation_id: corporation_id })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            @client_state.handle_authorization_error() if result.status == 401
            error(request_error)
          else
            done(result.bookmarks)
        )
  update_bookmarks_metadata: (session_token, corporation_id, bookmark_deltas) ->
    new Promise (done, error) =>
      request
        .post("#{@galaxy_url()}/bookmarks/update")
        .send({ session_token: session_token, corporation_id: corporation_id, deltas: bookmark_deltas })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            @client_state.handle_authorization_error() if result.status == 401
            error(request_error)
          else
            done(result.bookmarks)
        )

  add_bookmark: (session_token, corporation_id, type, parent_id, name, extra_params={}) ->
    new Promise (done, error) =>
      params = _.merge({ session_token: session_token, corporation_id: corporation_id, type: type, parent_id: parent_id, name: name }, extra_params)
      request
        .post("#{@galaxy_url()}/bookmarks/new")
        .send(params)
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            @client_state.handle_authorization_error() if result.status == 401
            error(request_error)
          else
            done(result.bookmark)
        )
  add_bookmark_folder: (session_token, corporation_id, parent_id, folder_name) ->
    @add_bookmark(session_token, corporation_id, 'FOLDER', parent_id, folder_name)
  add_bookmark_location_item: (session_token, corporation_id, parent_id, folder_name, map_x, map_y) ->
    @add_bookmark(session_token, corporation_id, 'LOCATION', parent_id, folder_name, { map_x, map_y })
  add_bookmark_building_item: (session_token, corporation_id, parent_id, folder_name, map_x, map_y, building_id) ->
    @add_bookmark(session_token, corporation_id, 'BUILDING', parent_id, folder_name, { map_x, map_y, building_id })

  mail_metadata: (session_token, corporation_id) ->
    new Promise (done, error) =>
      request
        .get("#{@galaxy_url()}/mail/metadata")
        .query({ session_token: session_token, corporation_id: corporation_id })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            @client_state.handle_authorization_error() if result.status == 401
            error(request_error)
          else
            done(result.mail)
        )

  buildings_metadata: (session_token, company_id) ->
    new Promise (done, error) =>
      request
        .get("#{@galaxy_url()}/buildings/metadata")
        .query({ session_token: session_token, company_id: company_id })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            @client_state.handle_authorization_error() if result.status == 401
            error(request_error)
          else
            done(result.buildings)
        )
  building_metadata: (session_token, building_id) ->
    new Promise (done, error) =>
      request
        .get("#{@galaxy_url()}/buildings/metadata")
        .query({ session_token: session_token, building_id: building_id })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            @client_state.handle_authorization_error() if result.status == 401
            error(request_error)
          else
            done(if result.buildings.length then result.buildings[0] else null)
        )
  construct_building: (session_token, company_id, definition_id, name, map_x, map_y) ->
    new Promise (done, error) =>
      request
        .post("#{@galaxy_url()}/buildings/construct")
        .send({
          session_token: session_token
          company_id: company_id
          definition_id: definition_id
          name: name
          map_x: map_x
          map_y: map_y
        })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            @client_state.handle_authorization_error() if result.status == 401
            error(request_error)
          else
            done(result.building)
        )


  inventions_metadata: (session_token, company_id) ->
    new Promise (done, error) =>
      request
        .get("#{@galaxy_url()}/inventions/metadata")
        .query({ session_token: session_token, company_id: company_id })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            @client_state.handle_authorization_error() if result.status == 401
            error(request_error)
          else
            done(result.inventions)
        )

  inventions_sell: (session_token, company_id, invention_id) ->
    new Promise (done, error) =>
      request
        .post("#{@galaxy_url()}/inventions/sell")
        .send({ session_token: session_token, company_id: company_id, invention_id: invention_id })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            @client_state.handle_authorization_error() if result.status == 401
            error(request_error)
          else
            done(result.inventions)
        )
  inventions_queue: (session_token, company_id, invention_id) ->
    new Promise (done, error) =>
      request
        .post("#{@galaxy_url()}/inventions/queue")
        .send({ session_token: session_token, company_id: company_id, invention_id: invention_id })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            @client_state.handle_authorization_error() if result.status == 401
            error(request_error)
          else
            done(result.inventions)
        )

  map_buildings_data: (session_token, planet_id, chunk_x, chunk_y) ->
    new Promise (done, error) =>
      request
        .get("#{@galaxy_url()}/map/buildings")
        .query({ session_token: session_token, planet_id: planet_id, chunk_x: chunk_x, chunk_y: chunk_y })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            @client_state.handle_authorization_error() if result.status == 401
            error(request_error)
          else
            done(result.buildings)
        )
