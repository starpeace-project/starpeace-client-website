
import Translation from '~/plugins/starpeace-client/language/translation.coffee'

export default class IndustryType
  constructor: (@id) ->

  @from_json: (json) ->
    type = new IndustryType(json.id)
    type.label = Translation.from_json(json.label)
    type
