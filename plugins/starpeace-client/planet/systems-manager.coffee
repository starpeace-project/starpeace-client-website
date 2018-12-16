
import MetadataSystem from '~/plugins/starpeace-client/planet/metadata-system.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'


export default class SystemsManager
  constructor: (@api, @ajax_state, @client_state) ->

  load_metadata: () ->
    new Promise (done, error) =>
      if !@client_state.session.session_token? || @ajax_state.is_locked('systems_metadata', 'ALL')
        done()
      else
        @ajax_state.lock('systems_metadata', 'ALL')
        @api.systems_metadata(@client_state.session.session_token)
          .then (systems_json) =>
            systems_metadata = _.map(systems_json, MetadataSystem.from_json)

            @client_state.core.systems_cache.set_systems_metadata(systems_metadata)
            @client_state.core.planets_cache.set_planets_metadata(_.flatMap(systems_metadata, (system) -> system.planets_metadata))

            @ajax_state.unlock('systems_metadata', 'ALL')
            done()

          .catch (err) =>
            console.log err
            @ajax_state.unlock('systems_metadata', 'ALL') # FIXME: TODO add error handling
            error()
