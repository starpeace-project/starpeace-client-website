

window.starpeace ||= {}
window.starpeace.planet ||= {}
window.starpeace.planet.Planet = class Planet

  constructor: (@id, @name) ->
    @as_of = new Date()

  to_string: () -> @toString()
  toString: () -> "#{@id}:#{@name}"

  @from_json: (json) ->
    planet = new Planet(json.id, json.name)

    planet.map_id = json.map_id
    planet.planet_type = json.planet_type || 'earth'
    planet.width = json.width || 1000
    planet.height = json.height || 1000
    planet.temperature_baseline = json.temperature_baseline || 50
    planet.moisture_baseline = json.moisture_baseline || 50
    planet
