
import Building from '~/plugins/starpeace-client/building/building.coffee'
import BuildingDetails from '~/plugins/starpeace-client/building/building-details.coffee'

import ChunkMap from '~/plugins/starpeace-client/map/chunk/chunk-map.coffee'

import Logger from '~/plugins/starpeace-client/logger.coffee'
import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

export default class BuildingManager
  constructor: (@api, @asset_manager, @bookmark_manager, @translation_manager, @ajax_state, @client_state) ->
    @chunk_promises = {}

  initialize: () ->
    @client_state.core.building_library.initialize(@client_state.core.planet_library)

  queue_asset_load: () ->
    return if @client_state.core.building_library.has_assets() || @ajax_state.is_locked('assets.building_metadata', 'ALL')

    @ajax_state.lock('assets.building_metadata', 'ALL')
    @asset_manager.queue('metadata.building', './building.metadata.json', (resource) =>
      unless resource?.error?
        # FIXME: TODO: convert json to object
        @client_state.core.building_library.load_images(resource.data.images)
        @client_state.core.building_library.load_required_atlases(resource.data.atlas)
        @asset_manager.queue_and_load_atlases((resource.data?.atlas || []), (atlas_path, atlas) => @client_state.core.building_library.load_atlas(atlas_path, atlas))
      @ajax_state.unlock('assets.building_metadata', 'ALL')
    )

  cost_for_resource_type: (resource_id) ->
    type = @client_state.core.planet_library.resource_type_for_id(resource_id)
    type?.price || 0
  cost_for_building_definition_id: (definition_id) ->
    simulation_definition = @client_state.core.building_library.simulation_definition_for_id(definition_id)
    _.reduce(simulation_definition?.construction_inputs, ((sum, input) => sum + (@cost_for_resource_type(input.resource_id) * input.quantity)), 0)

  load_chunk: (chunk_x, chunk_y) ->
    planet_id = @client_state.player.planet_id
    throw Error() if !@client_state.has_session() || !planet_id? || !chunk_x? || !chunk_y?
    await @ajax_state.locked('building_load_chunk', "#{planet_id}x#{chunk_x}x#{chunk_y}", =>
      buildings = _.map(await @api.buildings_for_planet(planet_id, chunk_x, chunk_y), (json) -> Building.from_json(json))
      @client_state.core.building_cache.load_buildings(buildings)
      Logger.debug("loaded building chunk at #{chunk_x}x#{chunk_y}")
      _.map(buildings, 'id')
    )

  load_by_company: (company_id) ->
    new Promise (done, error) =>
      if !@client_state.has_session() || !company_id? || @ajax_state.is_locked('building_metadata', company_id)
        error()
      else
        @ajax_state.lock('building_metadata', company_id)
        @api.buildings_for_company(company_id)
          .then (buildings_json) =>
            buildings = _.map(buildings_json, (json) -> Building.from_json(json))
            @client_state.core.building_cache.load_buildings(buildings)
            @client_state.corporation.set_company_building_ids(company_id, _.map(buildings_json, 'id'))
            @ajax_state.unlock('building_metadata', company_id)
            done(buildings)

          .catch (err) =>
            @ajax_state.unlock('building_metadata', company_id) # FIXME: TODO add error handling
            error()

  load_building_metadata: (building_id) ->
    throw Error() if !@client_state.has_session() || !building_id?
    await @ajax_state.locked('building_metadata', building_id, =>
      building = Building.from_json(await @api.building_for_id(building_id))
      @client_state.core.building_cache.load_building(building)
      building
    )

  load_building_details: (building_id) ->
    details = @client_state.core.building_cache.building_details(building_id)
    return details if details?
    throw Error() if !@client_state.has_session() || !building_id?
    await @ajax_state.locked('building_details', building_id, =>
      details = BuildingDetails.from_json(await @api.building_details_for_id(building_id))
      @client_state.core.building_cache.load_building_details(details)
      details
    )


  construct_building: () ->
    building_metadata = @client_state.core.building_library.metadata_by_id[@client_state.interface.construction_building_id]

    new Promise (done, error) =>
      if !@client_state.has_session() || !building_metadata? || @ajax_state.is_locked('building_construction', 'ALL')
        done()
      else
        temporary_building = Building.from_json({
          id: Utils.uuid()
          tycoonId: @client_state.player.tycoon_id
          corporationId: @client_state.player.corporation_id
          companyId: @client_state.player.company_id
          definitionId: building_metadata.id
          name: "#{@translation_manager.text(building_metadata.name)} ##{@client_state.building_count_for_company(building_metadata.id) + 1}"
          mapX: @client_state.interface.construction_building_map_x
          mapY: @client_state.interface.construction_building_map_y
          stage: -1
        })

        @client_state.core.building_cache.load_building(temporary_building)
        @client_state.planet.game_map.building_map.add_building(temporary_building.id)
        @client_state.planet.notify_map_data_listeners({ type: 'building', info: {chunk_x: temporary_building.map_x / ChunkMap.CHUNK_WIDTH, chunk_y: temporary_building.map_y / ChunkMap.CHUNK_HEIGHT} })

        @ajax_state.lock('building_construction', 'ALL')
        @api.construct_building(@client_state.player.planet_id, temporary_building.company_id, temporary_building.definition_id, temporary_building.name, temporary_building.map_x, temporary_building.map_y)
          .then (building_info) =>
            constructed_building = Building.from_json(building_info)
            @client_state.core.building_cache.load_building(constructed_building)
            @client_state.planet.game_map.building_map.remove_building(temporary_building.id)
            @client_state.planet.game_map.building_map.add_building(constructed_building.id)
            @client_state.corporation.add_company_building_id(constructed_building.company_id, constructed_building.id)
            @client_state.core.building_cache.remove_building(temporary_building)
            @client_state.planet.notify_map_data_listeners({ type: 'building', info: {chunk_x: constructed_building.map_y / ChunkMap.CHUNK_HEIGHT, chunk_y: constructed_building.map_y / ChunkMap.CHUNK_HEIGHT} })

            @bookmark_manager.add_building_bookmark(constructed_building.id, true)
            @client_state.interface.selected_building_id = constructed_building.id

            @ajax_state.unlock('building_construction', 'ALL')
            done()

          .catch (err) =>
            # FIXME: TODO add error handling (remove temporary, add sys message)
            @ajax_state.unlock('building_construction', 'ALL')
            error()
