
import Translation from '~/plugins/starpeace-client/language/translation.coffee'

export default class CityZone
  constructor: (@id) ->

  matches: (other_id) ->
    return true if @id == other_id
    return true if @included_city_zone_ids.indexOf(other_id) >= 0
    false

  @from_json: (json) ->
    zone = new CityZone(json.id)
    zone.label = Translation.from_json(json.label)
    zone.value = json.value
    zone.color = json.color || 0
    zone.mini_map_color = json.miniMapColor || json.color || 0
    zone.included_city_zone_ids = json.includedCityZoneIds || []
    zone
