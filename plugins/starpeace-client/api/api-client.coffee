import _ from 'lodash'
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

  galaxy_auth: (options, galaxy_id=null) ->
    galaxy_id = @client_state.identity.galaxy_id unless galaxy_id?

    headers = { }
    headers.Authorization = "JWT #{@client_state.options.galaxy_jwt}" if @client_state.options.galaxy_id == galaxy_id && @client_state.options.galaxy_jwt?.length
    headers.VisaId = @client_state.player.planet_visa_id if @client_state.player.planet_visa_id?.length

    _.assign(options, { headers: headers })

  handle_request: (request_promise, handle_result) ->
    new Promise (done, error) =>
      request_promise
          .then (result) -> done(handle_result(result.data))
          .catch (err) =>
            @client_state.handle_connection_error() unless err.status?
            @client_state.handle_authorization_error() if err.response?.status == 401 || err.response?.status == 403
            error(err)
  delete: (path, parameters, handle_result) ->
    @handle_request(@client.delete("#{@galaxy_url()}/#{path}", @galaxy_auth(parameters)), handle_result)
  get: (path, query, handle_result) ->
    @handle_request(@client.get("#{@galaxy_url()}/#{path}", @galaxy_auth({ params: (query || {}) })), handle_result)
  get_binary: (path, query, handle_result) ->
    @handle_request(@client.get("#{@galaxy_url()}/#{path}", @galaxy_auth({ responseType: 'arraybuffer', params: (query || {}) })), handle_result)
  post: (path, parameters, handle_result) ->
    @handle_request(@client.post("#{@galaxy_url()}/#{path}", parameters, @galaxy_auth({})), handle_result)
  put: (path, parameters, handle_result) ->
    @handle_request(@client.put("#{@galaxy_url()}/#{path}", parameters, @galaxy_auth({})), handle_result)
  patch: (path, parameters, handle_result) ->
    @handle_request(@client.patch("#{@galaxy_url()}/#{path}", parameters, @galaxy_auth({})), handle_result)

  galaxy_metadata: (galaxy_id) ->
    new Promise (done, error) =>
      @client.get("#{@galaxy_url(galaxy_id)}/galaxy/metadata", @galaxy_auth({}, galaxy_id))
        .then (result) -> done(result.data)
        .catch error

  galaxy_create: (galaxy_id, username, password, remember_me) ->
    new Promise (done, error) =>
      @client.post("#{@galaxy_url(galaxy_id)}/galaxy/create", {
          username: username
          password: password
          rememberMe: remember_me
        })
        .then (result) -> done(result.data)
        .catch (err) -> error(err.response)
  galaxy_login: (galaxy_id, username, password, remember_me) ->
    new Promise (done, error) =>
      @client.post("#{@galaxy_url(galaxy_id)}/galaxy/login", {
          username: username
          password: password
          rememberMe: remember_me
        })
        .then (result) -> done(result.data)
        .catch (err) -> error(err.response)
  galaxy_logout: (galaxy_id) ->
    new Promise (done, error) =>
      @client.post("#{@galaxy_url(galaxy_id)}/galaxy/logout", {}, @galaxy_auth({}, galaxy_id))
        .then (result) -> done(result.data)
        .catch (err) -> error(err.response)

  register_visa: (galaxy_id, planet_id, visa_type) ->
    new Promise (done, error) =>
      @client.post("#{@galaxy_url(galaxy_id)}/planets/#{planet_id}/visa", {
        identityType: visa_type
      }, @galaxy_auth({}, galaxy_id))
      .then (result) -> done(result.data)
      .catch(error)


  buildings_for_planet: (planet_id, chunk_x, chunk_y) ->
    @get("planets/#{planet_id}/buildings", {
      chunkX: chunk_x
      chunkY: chunk_y
    }, (result) -> result || [])
  building_for_id: (building_id) ->
    @get("buildings/#{building_id}", {}, (result) -> result)
  building_details_for_id: (building_id) ->
    @get("buildings/#{building_id}/details", {}, (result) -> result)
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

  details_for_planet: (planet_id) ->
    @get("planets/#{planet_id}/details", {}, (result) -> result || [])
  online_tycoons_for_planet: (planet_id) ->
    @get("planets/#{planet_id}/online", {}, (result) -> result || [])
  rankings_for_planet: (planet_id, ranking_type_id) ->
    @get("planets/#{planet_id}/rankings/#{ranking_type_id}", {}, (result) -> result || [])
  search_corporations_for_planet: (planet_id, query, startsWithQuery) ->
    @get("planets/#{planet_id}/search/corporations", { query, startsWithQuery }, (result) -> result || [])
  search_tycoons_for_planet: (planet_id, query, startsWithQuery) ->
    @get("planets/#{planet_id}/search/tycoons", { query, startsWithQuery }, (result) -> result || [])
  towns_for_planet: (planet_id) ->
    @get("planets/#{planet_id}/towns", {}, (result) -> result)
  buildings_for_town: (planet_id, town_id, industryCategoryId, industryTypeId) ->
    @get("planets/#{planet_id}/towns/#{town_id}/buildings", { industryCategoryId, industryTypeId }, (result) -> result || [])
  companies_for_town: (planet_id, town_id) ->
    @get("planets/#{planet_id}/towns/#{town_id}/companies", {}, (result) -> result || [])
  details_for_town: (planet_id, town_id) ->
    @get("planets/#{planet_id}/towns/#{town_id}/details", {}, (result) -> result || [])

  overlay_data_for_planet: (planet_id, type, chunk_x, chunk_y) ->
    @get_binary("planets/#{planet_id}/overlay/#{type}", {
      chunkX: chunk_x
      chunkY: chunk_y
    }, (result) -> if result? then new Uint8Array(result) else null)

  road_data_for_planet: (planet_id, chunk_x, chunk_y) ->
    @get_binary("planets/#{planet_id}/roads", {
      chunkX: chunk_x
      chunkY: chunk_y
    }, (result) -> if result? then new Uint8Array(result) else null)

  tycoon_for_id: (tycoon_id) ->
    @get("tycoons/#{tycoon_id}", {}, (result) -> result)

  create_corporation: (planet_id, corporation_name) ->
    @post("planets/#{planet_id}/corporations", { name: corporation_name }, (result) -> result)
  corporation_for_id: (corporation_id) ->
    @get("corporations/#{corporation_id}", {}, (result) -> result)

  bookmarks_for_corporation: (corporation_id) ->
    @get("corporations/#{corporation_id}/bookmarks", {}, (result) -> result || [])
  create_corporation_bookmark: (corporation_id, type, parent_id, order, name, extra_params={}) ->
    @post("corporations/#{corporation_id}/bookmarks", _.merge({
      type: type
      parentId: parent_id
      order: order
      name: name
    }, extra_params), (result) -> result)
  update_corporation_bookmarks: (corporation_id, bookmark_deltas) ->
    @patch("corporations/#{corporation_id}/bookmarks", {
      deltas: bookmark_deltas
    }, (result) -> result)

  cashflow_for_corporation: (corporation_id) ->
    @get("corporations/#{corporation_id}/cashflow", {}, (result) -> result)

  mail_for_corporation: (corporation_id) ->
    @get("corporations/#{corporation_id}/mail", {}, (result) -> result || [])
  send_mail: (corporation_id, to, subject, body) ->
    @post("corporations/#{corporation_id}/mail", {
      to: to
      subject: subject
      body: body
    }, (result) -> result)
  mark_mail_read: (corporation_id, mail_id) ->
    @put("corporations/#{corporation_id}/mail/#{mail_id}/mark-read", {}, (result) -> result)
  delete_mail: (corporation_id, mail_id) ->
    @delete("corporations/#{corporation_id}/mail/#{mail_id}", {}, (result) -> result)


  create_company: (planet_id, company_name, seal_id) ->
    @post("planets/#{planet_id}/companies", { name: company_name, sealId: seal_id }, (result) -> result)

  buildings_for_company: (company_id) ->
    @get("companies/#{company_id}/buildings", {}, (result) -> result || [])

  inventions_for_company: (company_id) ->
    @get("companies/#{company_id}/inventions", {}, (result) -> result || [])
  queue_company_invention: (company_id, invention_id) ->
    @put("companies/#{company_id}/inventions/#{invention_id}", {}, (result) -> result)
  sell_company_invention: (company_id, invention_id) ->
    @delete("companies/#{company_id}/inventions/#{invention_id}", {}, (result) -> result)
