import Tycoon from '~/plugins/starpeace-client/tycoon/tycoon'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class TycoonManager
  constructor: (@api, @ajax_state, @client_state) ->

  load_metadata: () ->
    tycoon_id = @client_state.player.tycoon_id
    return if !@client_state.has_session() || !@client_state.is_galaxy_tycoon() || !tycoon_id? || @ajax_state.is_locked('tycoon_metadata', tycoon_id)

    @ajax_state.lock('tycoon_metadata', tycoon_id)
    @api.tycoon_for_id(tycoon_id)
      .then (tycoon_json) =>
        tycoon_metadata = Tycoon.from_json(tycoon_json)

        @client_state.core.tycoon_cache.set_tycoon_metadata(tycoon_metadata)
        @client_state.core.corporation_cache.load_tycoon_corporations(tycoon_metadata.id, tycoon_metadata.corporations)
        @client_state.core.company_cache.load_companies_metadata(corporation.companies) for corporation in tycoon_metadata.corporations

        @ajax_state.unlock('tycoon_metadata', tycoon_id)

      .catch (err) =>
        # FIXME: TODO: add error handling (failed to get tycoon metadata)
        @ajax_state.unlock('tycoon_metadata', tycoon_id)
