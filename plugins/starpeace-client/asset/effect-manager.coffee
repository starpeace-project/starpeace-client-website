
import MetadataEffect from '~/plugins/starpeace-client/asset/metadata-effect.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'


export default class EffectManager
  constructor: (@asset_manager, @ajax_state, @client_state) ->

  queue_asset_load: () ->
    return if @client_state.core.effect_library.has_assets() || @ajax_state.is_locked('assets.effects_metadata', 'ALL')

    @ajax_state.lock('assets.effects_metadata', 'ALL')
    @asset_manager.queue('metadata.effect', './effect.metadata.json', (resource) =>
      effect_metadata = []
      for key,json of (resource.data?.effects || {})
        # FIXME: TODO: add ID to json, change from map to array
        json.id = key
        effect_metadata.push MetadataEffect.from_json(json)

      @client_state.core.effect_library.load_effect_metadata(effect_metadata)
      @client_state.core.effect_library.load_required_atlases(resource.data?.atlas)

      @asset_manager.queue_and_load_atlases((resource.data?.atlas || []), (atlas_path, atlas) => @client_state.core.effect_library.load_atlas(atlas_path, atlas))
      @ajax_state.unlock('assets.effects_metadata', 'ALL')
    )
