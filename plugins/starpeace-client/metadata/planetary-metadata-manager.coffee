
import Vue from 'vue'

import PlanetarySystem from '~/plugins/starpeace-client/planet/planetary-system.coffee'

class PlanetaryMetadataManager
  constructor: (@client) ->
    @systems_metadata = []
    @systems_metadata_by_id = {}
    @planets_metadata_by_id = {}


    PlanetarySystem.load(@client.identity)
      .then (systems) =>

        systems_by_id = {}
        planets_by_id = {}
        for system in systems
          @systems_metadata.push system
          systems_by_id[system.id] = system
          for planet in system.planets
            planets_by_id[planet.id] = planet

        Vue.set(@systems_metadata_by_id, key, value) for key,value of systems_by_id
        Vue.set(@planets_metadata_by_id, key, value) for key,value of planets_by_id

      .catch (error) ->
        # FIXME: TODO: handle error
        console.log error

  has_planetary_metadata: (planet_id) ->
    if planet_id? then @planets_metadata_by_id?[planet_id]? else Object.keys(@planets_metadata_by_id || {}).length

  planetary_system_for_id: (id) ->
    @systems_metadata_by_id[id]

  planet_for_id: (id) ->
    @planets_metadata_by_id[id]

export default PlanetaryMetadataManager
