
import Translation from '~/plugins/starpeace-client/language/translation.coffee'

export default class ResourceUnit
  constructor: (@id) ->

  @from_json: (json) ->
    unit = new ResourceUnit(json.id)
    unit.label_plural = Translation.from_json(json.labelPlural)
    unit
