

window.starpeace ||= {}
window.starpeace.metadata ||= {}
window.starpeace.metadata.MetadataManager = class MetadataManager

  constructor: (@client) ->
    @systems_metadata = null
    @systems_metadata_by_id = null
    @planets_metadata_by_id = null

    starpeace.planet.PlanetarySystem.load(@client.identity)
      .then (systems) =>

        systems_by_id = {}
        planets_by_id = {}
        for system in systems
          systems_by_id[system.id] = system
          for planet in system.planets
            planets_by_id[planet.id] = planet

        @systems_metadata = systems
        @systems_metadata_by_id = systems_by_id
        @planets_metadata_by_id = planets_by_id

      .catch (error) ->
        # FIXME: TODO: handle error
        console.log error

  has_planetary_metadata: () ->
    if @client.planet? then @planets_metadata_by_id?[@client.planet.id]? else Object.keys(@planets_metadata_by_id || {}).length

  planetary_systems: () ->
    @systems_metadata || []

  planetary_system_for_id: (id) ->
    @systems_metadata_by_id[id]

  planet_for_id: (id) ->
    @planets_metadata_by_id[id]
