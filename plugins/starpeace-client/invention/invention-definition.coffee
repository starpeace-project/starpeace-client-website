
import Translation from '~/plugins/starpeace-client/language/translation.coffee'

export default class InventionDefinition
  constructor: (@id) ->

  @from_json: (json) ->
    metadata = new InventionDefinition(json.id)
    metadata.industry_category_id = json.industryCategoryId
    metadata.industry_type_id = json.industryTypeId
    metadata.name = Translation.from_json(json.name)
    metadata.description = Translation.from_json(json.description)
    metadata.properties = json.properties || {}
    metadata.depends_on = json.dependsOnIds || []
    metadata
