
import Translation from '~/plugins/starpeace-client/language/translation.coffee'

export default class IndustryCategory
  constructor: (@id) ->

  @from_json: (json) ->
    zone = new IndustryCategory(json.id)
    zone.label = Translation.from_json(json.label)
    zone
