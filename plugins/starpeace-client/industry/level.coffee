
import Translation from '~/plugins/starpeace-client/language/translation.coffee'

export default class Level
  constructor: (@id) ->

  @from_json: (json) ->
    zone = new Level(json.id)
    zone.label = Translation.from_json(json.label)
    zone.level = json.level || 0
    zone.color = json.color || 0
    zone.mini_map_color = json.miniMapColor || json.color || 0
    zone.included_city_zone_ids = json.includedCityZoneIds || []
    zone
