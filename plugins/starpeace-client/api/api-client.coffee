
import request from 'superagent'
import configuration from '~/plugins/starpeace-client/api/mock-api-configuration.coffee'

import superagentMock from 'superagent-mock'

superagentMock(request, configuration)

export default class APIClient
  constructor: () ->
    @root_url = 'https://api.starpeace.io'

  register_session: (identity) ->
    new Promise (done, error) =>
      request
        .post("#{@root_url}/session/register")
        .send({ type: identity.type, auth_token: identity.authentication_token })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            error(request_error)
          else
            done(result)
        )

  systems_metadata: (session_token) ->
    new Promise (done, error) =>
      request
        .get("#{@root_url}/systems/metadata")
        .query({ session_token: session_token })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            error(request_error)
          else
            done(result.systems || [])
        )

  planets_metadata: (session_token, system_id) ->
    new Promise (done, error) =>
      request
        .get("#{@root_url}/planets/metadata")
        .query({ session_token: session_token, system_id: system_id })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            error(request_error)
          else
            done(result.planets || [])
        )
  planet_details: (session_token, planet_id) ->
    new Promise (done, error) =>
      request
        .get("#{@root_url}/planets/details")
        .query({ session_token: session_token, planet_id: planet_id })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            error(request_error)
          else
            done(result.planet)
        )
  planet_events: (session_token, planet_id, last_update) ->
    new Promise (done, error) =>
      request
        .get("#{@root_url}/planets/events")
        .query({ session_token: session_token, planet_id: planet_id, last_update: last_update.format() })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            error(request_error)
          else
            done(result.planet)
        )

  tycoon_metadata: (session_token, tycoon_id) ->
    new Promise (done, error) =>
      request
        .get("#{@root_url}/tycoons/metadata")
        .query({ session_token: session_token, tycoon_id: tycoon_id })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            error(request_error)
          else
            done(result.tycoon)
        )

  corporation_metadata: (session_token, corporation_id) ->
    new Promise (done, error) =>
      request
        .get("#{@root_url}/corporation/metadata")
        .query({ session_token: session_token, corporation_id: corporation_id })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            error(request_error)
          else
            done(result.corporation)
        )
  corporation_events: (session_token, corporation_id, last_update) ->
    new Promise (done, error) =>
      request
        .get("#{@root_url}/corporation/events")
        .query({ session_token: session_token, corporation_id: corporation_id, last_update: last_update.format() })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            error(request_error)
          else
            done(result.corporation)
        )

  bookmarks_metadata: (session_token, corporation_id) ->
    new Promise (done, error) =>
      request
        .get("#{@root_url}/bookmarks/metadata")
        .query({ session_token: session_token, corporation_id: corporation_id })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            error(request_error)
          else
            done(result.bookmarks)
        )
  update_bookmarks_metadata: (session_token, corporation_id, bookmark_deltas) ->
    new Promise (done, error) =>
      request
        .post("#{@root_url}/bookmarks/update")
        .send({ session_token: session_token, corporation_id: corporation_id, deltas: bookmark_deltas })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            error(request_error)
          else
            done(result.bookmarks)
        )

  add_bookmark_folder: (session_token, corporation_id, parent_id, folder_name) ->
    new Promise (done, error) =>
      request
        .post("#{@root_url}/bookmarks/new")
        .send({ session_token: session_token, corporation_id: corporation_id, type: 'FOLDER', parent_id: parent_id, name: folder_name })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            error(request_error)
          else
            done(result.bookmark)
        )


  mail_metadata: (session_token, corporation_id) ->
    new Promise (done, error) =>
      request
        .get("#{@root_url}/mail/metadata")
        .query({ session_token: session_token, corporation_id: corporation_id })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            error(request_error)
          else
            done(result.mail)
        )

  buildings_metadata: (session_token, company_id) ->
    new Promise (done, error) =>
      request
        .get("#{@root_url}/buildings/metadata")
        .query({ session_token: session_token, company_id: company_id })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            error(request_error)
          else
            done(result.buildings)
        )

  inventions_metadata: (session_token, company_id) ->
    new Promise (done, error) =>
      request
        .get("#{@root_url}/inventions/metadata")
        .query({ session_token: session_token, company_id: company_id })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            error(request_error)
          else
            done(result.inventions)
        )

  map_buildings_data: (session_token, planet_id, chunk_x, chunk_y) ->
    new Promise (done, error) =>
      request
        .get("#{@root_url}/map/buildings")
        .query({ session_token: session_token, planet_id: planet_id, chunk_x: chunk_x, chunk_y: chunk_y })
        .set('accept', 'json')
        .end((request_error, result) =>
          if request_error
            error(request_error)
          else
            done(result.buildings)
        )
