
import Galaxy from '~/plugins/starpeace-client/galaxy/galaxy.coffee'
import Tycoon from '~/plugins/starpeace-client/tycoon/tycoon'

import Logger from '~/plugins/starpeace-client/logger.coffee'


export default class GalaxyManager
  constructor: (@api, @ajax_state, @client_state) ->

  load_metadata: (galaxy_id) ->
    throw Error() if !galaxy_id?
    await @ajax_state.locked('galaxy_metadata', galaxy_id, =>
      galaxy_metadata = Galaxy.from_json(await @api.galaxy_metadata(galaxy_id))
      @client_state.core.galaxy_cache.load_galaxy_metadata(galaxy_metadata.id, galaxy_metadata)
      galaxy_metadata
    )

  create: (galaxy_id, username, password, remember_me) ->
    throw Error() if !galaxy_id?
    await @ajax_state.locked('create', galaxy_id, =>
      tycoon_json = await @api.galaxy_create(galaxy_id, username, password, remember_me)
      throw Error('NO_AUTH_TOKEN') unless tycoon_json.accessToken?
      tycoon = Tycoon.from_json(tycoon_json)
      @client_state.options.set_authorization_state(galaxy_id, tycoon_json.accessToken, tycoon_json.refreshToken)
      tycoon
    )

  login: (galaxy_id, username, password, remember_me) ->
    throw Error() if !galaxy_id? || !username? || !password?
    await @ajax_state.locked('login', galaxy_id, =>
      tycoon_json = await @api.galaxy_login(galaxy_id, username, password, remember_me)
      throw Error('NO_AUTH_TOKEN') unless tycoon_json.accessToken?
      tycoon = Tycoon.from_json(tycoon_json)
      @client_state.options.set_authorization_state(galaxy_id, tycoon_json.accessToken, tycoon_json.refreshToken)
      tycoon
    )

  logout: (galaxy_id) ->
    throw Error() if !galaxy_id?
    await @ajax_state.locked('logout', galaxy_id, =>
      await @api.galaxy_logout(galaxy_id)
      @client_state.options.clear_authorization_state()
      # TODO: better handle errors; error_response?.data?.message
    )
