
import Galaxy from '~/plugins/starpeace-client/galaxy/galaxy.coffee'
import Tycoon from '~/plugins/starpeace-client/tycoon/tycoon.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'


export default class GalaxyManager
  constructor: (@api, @ajax_state, @client_state) ->

  load_metadata: (galaxy_id) ->
    new Promise (done, error) =>
      if @ajax_state.is_locked('galaxy_metadata', galaxy_id)
        done()
      else
        @ajax_state.lock('galaxy_metadata', galaxy_id)
        @api.galaxy_metadata(galaxy_id)
          .then (galaxy_json) =>
            galaxy_metadata = Galaxy.from_json(galaxy_json)
            unless galaxy_metadata.id == galaxy_id
              @client_state.core.galaxy_cache.change_galaxy_id(galaxy_id, galaxy_metadata.id)
              @client_state.options.change_galaxy_id(galaxy_id, galaxy_metadata.id)
            @client_state.core.galaxy_cache.load_galaxy_metadata(galaxy_metadata.id, galaxy_metadata)
            @ajax_state.unlock('galaxy_metadata', galaxy_id)
            done()

          .catch (err) =>
            console.log err
            @ajax_state.unlock('galaxy_metadata', galaxy_id) # FIXME: TODO add error handling
            error()

  login: (galaxy_id, username, password, remember_me) ->
    new Promise (done, error) =>
      if @ajax_state.is_locked('login', galaxy_id)
        done()
      else
        @ajax_state.lock('login', galaxy_id)
        @api.galaxy_login(galaxy_id, username, password, remember_me)
          .then (tycoon_json) =>
            tycoon = Tycoon.from_json(tycoon_json)
            @ajax_state.unlock('login', galaxy_id)
            done(tycoon)

          .catch (error_response) =>
            @ajax_state.unlock('login', galaxy_id)
            error(error_response?.data?.message)

  logout: (galaxy_id) ->
    new Promise (done, error) =>
      if @ajax_state.is_locked('logout', galaxy_id)
        done()
      else
        @ajax_state.lock('logout', galaxy_id)
        @api.galaxy_logout(galaxy_id)
          .then () =>
            @ajax_state.unlock('logout', galaxy_id)
            done()

          .catch (error_response) =>
            @ajax_state.unlock('logout', galaxy_id)
            error(error_response?.data?.message)
