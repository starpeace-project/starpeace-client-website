
import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class BuildingCache
  constructor: () ->
    @reset_state()

  reset_state: () ->
    @building_metadata_by_id = {}

  load_metadata: (building_metadata) ->
    if Array.isArray(building_metadata)
      @building_metadata_by_id[metadata.id] = metadata for metadata in building_metadata
    else
      @building_metadata_by_id[building_metadata.id] = building_metadata

  building_metadata_for_id: (building_id) -> @building_metadata_by_id[building_id]
