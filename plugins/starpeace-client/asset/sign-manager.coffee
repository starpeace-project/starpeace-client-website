
import SignDefinition from '~/plugins/starpeace-client/asset/sign-definition.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'


export default class SignManager
  constructor: (@asset_manager, @ajax_state, @client_state) ->

  queue_asset_load: () ->
    return if @client_state.core.effect_library.has_assets() || @ajax_state.is_locked('assets.signs_metadata', 'ALL')

    @ajax_state.lock('assets.signs_metadata', 'ALL')
    @asset_manager.queue('metadata.sign', './sign.metadata.json', (resource) =>
      definitions = []
      for key,json of (resource.data?.signs || {})
        # FIXME: TODO: add ID to json, change from map to array
        json.id = key
        definitions.push SignDefinition.from_json(json)

      @client_state.core.sign_library.load_sign_metadata(definitions)
      @client_state.core.sign_library.load_required_atlases(resource.data?.atlas)

      @asset_manager.queue_and_load_atlases((resource.data?.atlas || []), (atlas_path, atlas) => @client_state.core.sign_library.load_atlas(atlas_path, atlas))
      @ajax_state.unlock('assets.signs_metadata', 'ALL')
    )
