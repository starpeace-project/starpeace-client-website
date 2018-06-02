

window.starpeace ||= {}
window.starpeace.planet ||= {}
window.starpeace.planet.PlanetarySystem = class PlanetarySystem

  constructor: (@id, @name, @planets) ->
    @as_of = new Date()

  planets: () ->
    @planets

  to_string: () -> @toString()
  toString: () -> "#{@id}:#{@name}"

  @load: (identity) ->
    new Promise (resolve, reject) ->
      # FIXME: TODO: replace with API lookup

      setTimeout(->
        resolve([
          new PlanetarySystem('1', 'Alpha Stella', [
            starpeace.planet.Planet.from_json({
              id: '1'
              name: 'Mercury'
              map_id: 'aries'
              land_id: 'earth'
              width: 1000
              height: 1000
              temperature_baseline: 50
              moisture_baseline: 25
            }),
            starpeace.planet.Planet.from_json({
              id: '2'
              name: 'Venus'
              map_id: 'ancoeus'
              land_id: 'earth'
              width: 1000
              height: 1000
              temperature_baseline: 75
              moisture_baseline: 50
            }),
            starpeace.planet.Planet.from_json({
              id: '3'
              name: 'Earth'
              map_id: 'mondronia'
              land_id: 'earth'
              width: 1000
              height: 1000
              temperature_baseline: 50
              moisture_baseline: 50
            })
          ]),
          new PlanetarySystem('2', 'Stellae Beta', [
            starpeace.planet.Planet.from_json({
              id: '4'
              name: 'Mars'
              map_id: 'darkadia'
              land_id: 'earth'
              width: 1000
              height: 1000
              temperature_baseline: 50
              moisture_baseline: 50
            }),
            starpeace.planet.Planet.from_json({
              id: '5'
              name: 'Jupiter'
              map_id: 'cymoril'
              land_id: 'earth'
              width: 1000
              height: 1000
              temperature_baseline: 50
              moisture_baseline: 50
            })
          ])
        ])
      , 1500)

