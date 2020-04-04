
import Translation from '~/plugins/starpeace-client/language/translation.coffee'

export default class ResourceType
  constructor: (@id) ->

  @from_json: (json) ->
    type = new ResourceType(json.id)
    type.label_plural = Translation.from_json(json.labelPlural)
    type.unit_id = json.unitId
    type.price = json.price
    type
