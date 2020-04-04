
import moment from 'moment'
import axios from 'axios'
import SandboxConfiguration from '~/plugins/starpeace-client/api/sandbox/sandbox-configuration.coffee'

export default class APIClient
  constructor: (@client_state) ->
    new SandboxConfiguration(axios)
    axios.defaults.withCredentials = true
    @client = axios.create()

  galaxy_url: (galaxy_id=null) ->
    galaxy_id = @client_state.identity.galaxy_id unless galaxy_id?
    galaxy_config = if galaxy_id?.length then @client_state.core.galaxy_cache.galaxy_configuration(galaxy_id) else null
    throw "no configuration for galaxy #{galaxy_id}" unless galaxy_config?.api_protocol? && galaxy_config?.api_url? && galaxy_config?.api_port?
    "#{galaxy_config.api_protocol}://#{galaxy_config.api_url}:#{galaxy_config.api_port}"

  handle_request: (request_promise, handle_result) ->
    new Promise (done, error) =>
      request_promise
          .then (result) -> done(handle_result(result.data))
          .catch (err) =>
            @client_state.handle_authorization_error() if err.response?.status == 401
            error(err)
  delete: (path, parameters, handle_result) ->
    @handle_request(@client.delete("#{@galaxy_url()}/#{path}", parameters), handle_result)
  get: (path, query, handle_result) ->
    @handle_request(@client.get("#{@galaxy_url()}/#{path}", { params: (query || {}) }), handle_result)
  post: (path, parameters, handle_result) ->
    @handle_request(@client.post("#{@galaxy_url()}/#{path}", parameters), handle_result)
  put: (path, parameters, handle_result) ->
    @handle_request(@client.put("#{@galaxy_url()}/#{path}", parameters), handle_result)


  galaxy_metadata: (galaxy_id) ->
    new Promise (done, error) =>
      @client.get("#{@galaxy_url(galaxy_id)}/galaxy/metadata")
        .then (result) -> done(result.data)
        .catch error

  galaxy_login: (galaxy_id, username, password, remember_me) ->
    new Promise (done, error) =>
      @client.post("#{@galaxy_url(galaxy_id)}/galaxy/login", {
          username: username
          password: password
          remember_me: remember_me
        })
        .then (result) -> done(result.data)
        .catch (err) -> error(err.response)
  galaxy_logout: (galaxy_id) ->
    new Promise (done, error) =>
      @client.post("#{@galaxy_url(galaxy_id)}/galaxy/logout", {})
        .then (result) -> done(result.data)
        .catch (err) -> error(err.response)

  register_visa: (galaxy_id, planet_id, visa_type) ->
    new Promise (done, error) =>
      @client.post("#{@galaxy_url(galaxy_id)}/planets/#{planet_id}/visa", {
        identityType: visa_type
      })
      .then (result) -> done(result.data)
      .catch(error)


  buildings_for_planet: (planet_id, chunk_x, chunk_y) ->
    @get("planets/#{planet_id}/buildings", {
      chunkX: chunk_x
      chunkY: chunk_y
    }, (result) -> result || [])
  building_for_id: (planet_id, building_id) ->
    @get("planets/#{planet_id}/buildings/#{building_id}", {}, (result) -> result)
  construct_building: (planet_id, company_id, definition_id, name, map_x, map_y) ->
    @post("planets/#{planet_id}/buildings", {
      companyId: company_id
      definitionId: definition_id
      name: name
      mapX: map_x
      mapY: map_y
    }, (result) -> result)

  events_for_planet: (planet_id, last_update) ->
    @get("planets/#{planet_id}/events", {
      lastUpdate: last_update.format()
    }, (result) -> result || {})

  building_metadata_for_planet: (planet_id) ->
    @get("planets/#{planet_id}/metadata/buildings", {}, (result) -> result || {})
  core_metadata_for_planet: (planet_id) ->
    @get("planets/#{planet_id}/metadata/core", {}, (result) -> result || {})
  invention_metadata_for_planet: (planet_id) ->
    @get("planets/#{planet_id}/metadata/inventions", {}, (result) -> result || {})

  online_corporations_for_planet: (planet_id) ->
    @get("planets/#{planet_id}/online", {}, (result) -> result.corporations)
  towns_for_planet: (planet_id) ->
    @get("planets/#{planet_id}/towns", {}, (result) -> result)


  tycoon_for_id: (tycoon_id) ->
    @get("tycoons/#{tycoon_id}", {}, (result) -> result)


  corporation_for_id: (corporation_id) ->
    @get("corporations/#{corporation_id}", {}, (result) -> result)

  bookmarks_for_corporation: (corporation_id) ->
    @get("corporations/#{corporation_id}/bookmarks", {}, (result) -> result || [])
  create_corporation_bookmark: (corporation_id, type, parent_id, name, extra_params={}) ->
    @post("corporations/#{corporation_id}/bookmarks", _.merge({
      type: type
      parentId: parent_id
      name: name
    }, extra_params), (result) -> result)
  update_corporation_bookmarks: (corporation_id, bookmark_deltas) ->
    @patch("corporations/#{corporation_id}/bookmarks", _.merge({
      deltas: bookmark_deltas
    }, extra_params), (result) -> result)

  cashflow_for_corporation: (corporation_id) ->
    @get("corporations/#{corporation_id}/cashflow", {}, (result) -> result)

  mail_for_corporation: (corporation_id) ->
    @get("corporations/#{corporation_id}/mail", {}, (result) -> result || [])


  buildings_for_company: (company_id) ->
    @get("companies/#{company_id}/buildings", {}, (result) -> result || [])

  inventions_for_company: (company_id) ->
    @get("companies/#{company_id}/inventions", {}, (result) -> result || [])
  queue_company_invention: (company_id, invention_id) ->
    @put("companies/#{company_id}/inventions/#{invention_id}", {}, (result) -> result)
  sell_company_invention: (company_id, invention_id) ->
    @delete("companies/#{company_id}/inventions/#{invention_id}", {}, (result) -> result)
