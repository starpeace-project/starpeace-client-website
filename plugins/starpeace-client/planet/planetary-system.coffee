
import Planet from '~/plugins/starpeace-client/planet/planet.coffee'

class PlanetarySystem
  constructor: (@id, @name, @enabled, @planets) ->
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
          new PlanetarySystem('system-1', 'Alpha Stella', true, [
            Planet.from_json({
              id: 'planet-1'
              name: 'Mercury'
              map_id: 'aries'
              planet_type: 'earth'
              width: 1000
              height: 1000
              temperature_baseline: 50
              moisture_baseline: 25
            }),
            Planet.from_json({
              id: 'planet-2'
              name: 'Venus'
              map_id: 'ancoeus'
              planet_type: 'earth'
              width: 1000
              height: 1000
              temperature_baseline: 75
              moisture_baseline: 50
            }),
            Planet.from_json({
              id: 'planet-3'
              name: 'Earth'
              map_id: 'mondronia'
              planet_type: 'earth'
              width: 1000
              height: 1000
              temperature_baseline: 50
              moisture_baseline: 50
            })
          ]),
          new PlanetarySystem('system-2', 'Stellae Beta', false, [
            Planet.from_json({
              id: 'planet-4'
              name: 'Mars'
              map_id: 'darkadia'
              planet_type: 'earth'
              width: 1000
              height: 1000
              temperature_baseline: 50
              moisture_baseline: 50
            }),
            Planet.from_json({
              id: 'planet-5'
              name: 'Jupiter'
              map_id: 'cymoril'
              planet_type: 'earth'
              width: 1000
              height: 1000
              temperature_baseline: 50
              moisture_baseline: 50
            })
          ])
        ])
      , 1500)

export default PlanetarySystem
