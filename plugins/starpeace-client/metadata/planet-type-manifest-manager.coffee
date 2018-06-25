
import PlanetTypeManifest from '~/plugins/starpeace-client/metadata/planet-type-manifest.coffee'

class PlanetTypeManifestManager
  constructor: (@client) ->
    @planet_type_manifest = {}

  set_definitions: (planet_type, ground_definitions, tree_definitions) ->
    @planet_type_manifest[planet_type] = new PlanetTypeManifest(planet_type, ground_definitions, tree_definitions)

export default PlanetTypeManifestManager
