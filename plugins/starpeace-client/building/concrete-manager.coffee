
import MetadataConcrete from '~/plugins/starpeace-client/building/metadata-concrete.coffee'

export default class ConcreteManager
  constructor: (@asset_manager, @ajax_state, @client_state) ->

  queue_asset_load: () ->
    return if @client_state.core.concrete_library.has_assets() || @ajax_state.is_locked('assets.concrete_metadata', 'ALL')

    @ajax_state.lock('assets.concrete_metadata', 'ALL')
    @asset_manager.queue('metadata.concrete', './concrete.metadata.json', (resource) =>
      concrete_metadata = []
      for key,json of (resource.data?.concrete || {})
        # FIXME: TODO: add ID to json, change from map to array
        json.id = key
        concrete_metadata.push MetadataConcrete.from_json(json)

      @client_state.core.concrete_library.load_concrete_metadata(concrete_metadata)
      @client_state.core.concrete_library.load_required_atlases(resource.data?.atlas)

      @asset_manager.queue_and_load_atlases((resource.data?.atlas || []), (atlas_path, atlas) => @client_state.core.concrete_library.load_atlas(atlas_path, atlas))
      @ajax_state.unlock('assets.concrete_metadata', 'ALL')
    )
