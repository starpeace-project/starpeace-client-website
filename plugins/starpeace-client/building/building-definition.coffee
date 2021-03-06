
import Translation from '~/plugins/starpeace-client/language/translation.coffee'

export default class BuildingDefinition
  constructor: (@id) ->

  @from_json: (json) ->
    metadata = new BuildingDefinition(json.id)
    metadata.image_id = json.imageId
    metadata.sign_id = json.signId
    metadata.construction_image_id = json.constructionImageId
    metadata.name = Translation.from_json(json.name)
    metadata.city_zone_id = json.zoneId
    metadata.industry_category_id = json.industryCategoryId
    metadata.industry_type_id = json.industryTypeId
    metadata.seal_id = json.sealId
    metadata.foundation = json.foundation || false
    metadata.restricted = json.restricted || false || !json.zoneId?
    metadata.required_invention_ids = json.requiredInventionIds || []
    metadata.allowed_invention_ids = json.allowedInventionIds || []
    metadata
