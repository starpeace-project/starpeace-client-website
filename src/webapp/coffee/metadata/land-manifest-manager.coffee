

window.starpeace ||= {}
window.starpeace.metadata ||= {}
window.starpeace.metadata.LandManifestManager = class LandManifestManager

  constructor: (@client) ->
    @planet_type_manifest = {}

  has_land_metadata: (planet_type) ->
    @planet_type_manifest[planet_type]?

  set_land_metadata: (planet_type, metadata) ->
    @planet_type_manifest[planet_type] = new starpeace.metadata.LandManifest(planet_type, metadata)

