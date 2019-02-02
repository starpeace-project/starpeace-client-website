
import MetadataBuilding from '~/plugins/starpeace-client/building/metadata-building.coffee'

import ResourceType from '~/plugins/starpeace-client/industry/resource-type.coffee'
import ChunkMap from '~/plugins/starpeace-client/map/chunk/chunk-map.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'
import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

export default class BuildingManager
  constructor: (@api, @asset_manager, @bookmark_manager, @translation_manager, @ajax_state, @client_state) ->
    @chunk_promises = {}

  initialize: () ->
    @client_state.core.building_library.initialize()

  text_for_resource: (item) -> if ResourceType.TYPES[item.resource]? then @translation_manager.text(ResourceType.TYPES[item.resource].text_key) else item.resource
  description_for_building: (building_definition) ->
    text_separator = @translation_manager.text('misc.and')

    if building_definition.industry?
      template_description = _.template(@translation_manager.text('ui.menu.construction.description.industry.label'))
      template_output = _.template(@translation_manager.text('ui.menu.construction.description.industry.output.label'))
      template_input = _.template(@translation_manager.text('ui.menu.construction.description.industry.input.label'))

      description_parts = []

      output_label_parts = _.map(building_definition.industry.outputs, (output) =>
        unit_for_resource = if ResourceType.TYPES[output.resource]? then @translation_manager.text(ResourceType.TYPES[output.resource].unit.text_key) else output.resource
        template_output({amount: output.max, unit: unit_for_resource, duration: @translation_manager.text('duration.day'), resource: @text_for_resource(output)})
      )
      description_parts.push template_description({output: Utils.join_with_oxford_comma(output_label_parts, text_separator)})

      input_resources = _.filter(building_definition.industry.required_inputs, (input) -> input.resource != "WORK_FORCE_HI" && input.resource != "WORK_FORCE_MID" && input.resource != "WORK_FORCE_LO")
      inputs = _.map(input_resources, (input) => @text_for_resource(input))
      description_parts.push template_input({input: Utils.join_with_oxford_comma(inputs, text_separator)}) if inputs.length

      return description_parts.join(' ')

    if building_definition.warehouse?
      template_description = _.template(@translation_manager.text('ui.menu.construction.description.warehouse.label'))
      template_output = _.template(@translation_manager.text('ui.menu.construction.description.warehouse.output.label'))

      storage_parts = _.map(building_definition.warehouse.storage, (storage) =>
        unit_for_resource = if ResourceType.TYPES[storage.resource]? then @translation_manager.text(ResourceType.TYPES[storage.resource].unit.text_key) else storage.resource
        template_output({amount: storage.max, unit: unit_for_resource, resource: @text_for_resource(storage)})
      )

      return template_description({storage: Utils.join_with_oxford_comma(storage_parts, text_separator)})

    ''


  load_chunk: (chunk_x, chunk_y, width, height) ->
    key = "#{chunk_x}x#{chunk_y}"
    return if @chunk_promises[key]?

    return unless @client_state.has_session() && @client_state.player.planet_id?

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
      definitions = _.map(resource.data.definitions, (json) -> MetadataBuilding.from_json(json))
      @client_state.core.building_library.load_buildings(definitions, resource.data.images)
      @client_state.core.building_library.load_required_atlases(resource.data.atlas)

      @asset_manager.queue_and_load_atlases((resource.data?.atlas || []), (atlas_path, atlas) => @client_state.core.building_library.load_atlas(atlas_path, atlas))

      @ajax_state.unlock('assets.building_metadata', 'ALL')
    )


  load_metadata: (company_id) ->
    new Promise (done, error) =>
      if !@client_state.has_session() || !company_id? || @ajax_state.is_locked('building_metadata', company_id)
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
  load_building_metadata: (building_id) ->
    new Promise (done, error) =>
      if !@client_state.has_session() || !building_id? || @ajax_state.is_locked('building_metadata', building_id)
        done()
      else
        @ajax_state.lock('building_metadata', building_id)
        @api.building_metadata(@client_state.session.session_token, building_id)
          .then (metadata) =>
            @client_state.core.building_cache.load_metadata(metadata)
            # FIXME: TODO: notify change if different?

            @ajax_state.unlock('building_metadata', building_id)
            done()

          .catch (err) =>
            @ajax_state.unlock('building_metadata', building_id) # FIXME: TODO add error handling
            error()

  construct_building: () ->
    building_metadata = @client_state.core.building_library.metadata_by_id[@client_state.interface.construction_building_id]

    new Promise (done, error) =>
      if !@client_state.has_session() || !building_metadata? || @ajax_state.is_locked('building_construction', 'ALL')
        done()
      else
        temporary_building = {
          id: Utils.uuid()
          name: "#{@translation_manager.text(building_metadata.name_key)} ##{@client_state.building_count_for_company(building_metadata.id) + 1}"
          tycoon_id: @client_state.session.tycoon_id
          corporation_id: @client_state.player.corporation_id
          company_id: @client_state.player.company_id
          key: building_metadata.id
          x: @client_state.interface.construction_building_map_x
          y: @client_state.interface.construction_building_map_y
          is_temporary: true
          stage: -1
        }

        @client_state.core.building_cache.load_metadata(temporary_building)
        @client_state.planet.game_map.building_map.add_building(temporary_building.id)
        @client_state.planet.notify_map_data_listeners({ type: 'building', info: {chunk_x: temporary_building.x / ChunkMap.CHUNK_WIDTH, chunk_y: temporary_building.y / ChunkMap.CHUNK_HEIGHT} })

        @ajax_state.lock('building_construction', 'ALL')
        @api.construct_building(@client_state.session.session_token, temporary_building.company_id, temporary_building.key, temporary_building.name, temporary_building.x, temporary_building.y)
          .then (building_info) =>
            @client_state.core.building_cache.load_metadata(building_info)
            @client_state.planet.game_map.building_map.remove_building(temporary_building.id)
            @client_state.planet.game_map.building_map.add_building(building_info.id)
            @client_state.corporation.add_company_building_id(building_info.company_id, building_info.id)
            @client_state.core.building_cache.remove_metadata(temporary_building)
            @client_state.planet.notify_map_data_listeners({ type: 'building', info: {chunk_x: building_info.y / ChunkMap.CHUNK_HEIGHT, chunk_y: building_info.y / ChunkMap.CHUNK_HEIGHT} })

            @bookmark_manager.add_building_bookmark(building_info.id, true)

            # FIXME: TODO: add corp bookmark
            @client_state.interface.selected_building_id = building_info.id

            @ajax_state.unlock('building_construction', 'ALL')
            done()

          .catch (err) =>
            # FIXME: TODO add error handling (remove temporary, add sys message)
            @ajax_state.unlock('building_construction', 'ALL')
            error()
