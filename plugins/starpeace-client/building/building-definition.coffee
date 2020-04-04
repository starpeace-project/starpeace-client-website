
import Translation from '~/plugins/starpeace-client/language/translation.coffee'

export default class BuildingDefinition
  constructor: (@id) ->

  @from_json: (json) ->
    metadata = new BuildingDefinition(json.id)
    metadata.image_id = json.imageId
    metadata.construction_image_id = json.constructionImageId
    metadata.concrete_foundation = json.concreteFoundation || false
    metadata.name = Translation.from_json(json.name)
    metadata.industry_category_id = json.industryCategoryId
    metadata.industry_type_id = json.industryTypeId
    metadata.seal_id = json.sealId
    metadata.restricted = json.restricted || false || !json.cityZoneId?
    metadata.city_zone_id = json.cityZoneId
    metadata.required_invention_ids = json.requiredInventionIds || []
    metadata
