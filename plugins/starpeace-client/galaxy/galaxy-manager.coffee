
import MetadataGalaxy from '~/plugins/starpeace-client/galaxy/metadata-galaxy.coffee'

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
            galaxy_metadata = MetadataGalaxy.from_json(galaxy_json)

            unless galaxy_metadata.id == galaxy_id
              @client_state.core.galaxy_cache.change_galaxy_id(galaxy_id, galaxy_metadata.id)
              @client_state.options.change_galaxy_id(galaxy_id, galaxy_metadata.id)

            @client_state.core.galaxy_cache.load_galaxy_metadata(galaxy_metadata.id, galaxy_metadata)
            @client_state.core.planets_cache.set_planets_metadata(galaxy_metadata.planets_metadata)

            @ajax_state.unlock('galaxy_metadata', galaxy_id)
            done()

          .catch (err) =>
            @ajax_state.unlock('galaxy_metadata', galaxy_id) # FIXME: TODO add error handling
            error()
