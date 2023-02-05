
import Corporation from '~/plugins/starpeace-client/corporation/corporation.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class CorporationManager
  constructor: (@api, @ajax_state, @client_state) ->

  load_by_corporation: (corporation_id) ->
    corporation = @client_state.core.corporation_cache.metadata_for_id(corporation_id)
    return corporation if corporation?

    throw Error() if !@client_state.has_session() || !corporation_id?
    await @ajax_state.locked('corporation_metadata', corporation_id, =>
      corporation_json = await @api.corporation_for_id(corporation_id)
      corporation = Corporation.from_json(corporation_json)
      @client_state.core.corporation_cache.load_corporation(corporation)
      @client_state.core.company_cache.load_companies_metadata(corporation.companies)
      corporation
    )

  create: (corporation_name) ->
    throw Error() if !@client_state.has_session() || !corporation_name?
    await @ajax_state.locked('corporation_create', 'ALL', =>
      corporation = Corporation.from_json(await @api.create_corporation(corporation_name))
      @client_state.core.corporation_cache.load_corporation(corporation)
      @client_state.core.company_cache.load_companies_metadata(corporation.companies)
      corporation
    )
