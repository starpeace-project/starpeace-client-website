
import Logger from '~/plugins/starpeace-client/logger.coffee'
import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

export default class BuildingManager
  constructor: (@api, @asset_manager, @translation_manager, @ajax_state, @client_state) ->
    @chunk_promises = {}

    @requested_building_metadata = false
    @building_metadata = null
    @loaded_atlases = {}
    @building_textures = {}


  load_chunk: (chunk_x, chunk_y, width, height) ->
    key = "#{chunk_x}x#{chunk_y}"
    return if @chunk_promises[key]?

    return unless @client_state.session.session_token? && @client_state.player.planet_id?

    @ajax_state.start_ajax()
    @chunk_promises[key] = new Promise (done) =>
      @api.map_buildings_data(@client_state.session.session_token, @client_state.player.planet_id, chunk_x, chunk_y)
        .then (building_data) =>
          @client_state.core.building_cache.load_metadata(building_data)
          Logger.debug("loaded building chunk at #{chunk_x}x#{chunk_y}")
          delete @chunk_promises[key]
          @ajax_state.finish_ajax()
          done(_.map(building_data, 'id'))

        .catch (err) =>
          # FIXME: TODO: add error handling
          Logger.debug "failed to retrieve building map chunk"
          @ajax_state.finish_ajax()



  queue_asset_load: () ->
    return if @client_state.core.building_library.has_metadata() || @ajax_state.is_locked('assets.building_metadata', 'ALL')

    @ajax_state.lock('assets.building_metadata', 'ALL')
    @asset_manager.queue('metadata.building', './building.metadata.json', (resource) =>
      # FIXME: TODO: convert json to object
      @client_state.core.building_library.load_buildings(_.values(resource.data.buildings))
      @client_state.core.building_library.load_required_atlases(resource.data.atlas)

      @asset_manager.queue_and_load_atlases((resource.data?.atlas || []), (atlas_path, atlas) => @client_state.core.building_library.load_atlas(atlas_path, atlas))

      @ajax_state.unlock('assets.building_metadata', 'ALL')
    )


  load_metadata: (company_id) ->
    new Promise (done, error) =>
      if !@client_state.session.session_token? || !company_id? || @ajax_state.is_locked('building_metadata', company_id)
        done()
      else
        @ajax_state.lock('building_metadata', company_id)
        @api.buildings_metadata(@client_state.session.session_token, company_id)
          .then (metadata) =>
            @client_state.core.building_cache.load_metadata(metadata)
            @client_state.corporation.set_company_building_ids(company_id, _.map(metadata, 'id'))

            @ajax_state.unlock('building_metadata', company_id)
            done()

          .catch (err) =>
            @ajax_state.unlock('building_metadata', company_id) # FIXME: TODO add error handling
            error()
