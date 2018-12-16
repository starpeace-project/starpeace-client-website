
import MetadataTycoon from '~/plugins/starpeace-client/tycoon/metadata-tycoon.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class TycoonManager
  constructor: (@api, @ajax_state, @client_state) ->

  load_metadata: () ->
    tycoon_id = @client_state.session.tycoon_id
    return if !@client_state.session.session_token? || !@client_state.identity.identity.is_tycoon() || !tycoon_id? || @ajax_state.is_locked('tycoon_metadata', tycoon_id)

    @ajax_state.lock('tycoon_metadata', tycoon_id)
    @api.tycoon_metadata(@client_state.session.session_token, tycoon_id)
      .then (tycoon_json) =>
        tycoon_metadata = MetadataTycoon.from_json(tycoon_json)

        @client_state.core.tycoon_cache.set_tycoon_metadata(tycoon_metadata)
        @client_state.core.corporation_cache.load_corporation_metadata(tycoon_metadata.corporations_metadata)
        @client_state.core.company_cache.load_companies_metadata(metadata.companies_metadata) for metadata in tycoon_metadata.corporations_metadata

        @ajax_state.unlock('tycoon_metadata', tycoon_id)

      .catch (err) =>
        # FIXME: TODO: add error handling (failed to get tycoon metadata)
        @ajax_state.unlock('tycoon_metadata', tycoon_id)
