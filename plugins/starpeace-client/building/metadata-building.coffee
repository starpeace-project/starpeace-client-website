
import BuildingZone from '~/plugins/starpeace-client/overlay/building-zone.coffee'

import MetadataBuildingIndustry from '~/plugins/starpeace-client/building/metadata-building-industry.coffee'
import MetadataBuildingWarehouse from '~/plugins/starpeace-client/building/metadata-building-warehouse.coffee'

export default class MetadataBuilding
  constructor: (@id) ->

  cost: () ->
    return @industry.cost if @industry?
    return @warehouse.cost if @warehouse?
    0

  @from_json: (json) ->
    metadata = new MetadataBuilding(json.id)
    metadata.name_key = json.name_key
    metadata.image_id = json.image_id
    metadata.construction_image_id = json.construction_image_id
    metadata.seal_ids = json.seal_ids || []

    metadata.category = json.category
    metadata.industry_type = json.industry_type
    metadata.zone = BuildingZone.from_string(json.zone)
    metadata.restricted = true if json.restricted

    metadata.required_invention_ids = json.required_invention_ids || []

    metadata.industry = MetadataBuildingIndustry.from_json(json.industry) if json.industry?
    metadata.warehouse = MetadataBuildingWarehouse.from_json(json.warehouse) if json.warehouse?

    metadata
