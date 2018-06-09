

window.starpeace ||= {}
window.starpeace.metadata ||= {}
window.starpeace.metadata.PlanetTypeManifestManager = class PlanetTypeManifestManager

  constructor: (@client) ->
    @planet_type_manifest = {}

  set_definitions: (planet_type, ground_definitions, tree_definitions) ->
    @planet_type_manifest[planet_type] = new starpeace.metadata.PlanetTypeManifest(planet_type, ground_definitions, tree_definitions)

