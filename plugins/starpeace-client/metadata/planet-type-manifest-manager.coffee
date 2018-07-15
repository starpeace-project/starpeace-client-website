
import PlanetTypeManifest from '~/plugins/starpeace-client/metadata/planet-type-manifest.coffee'

export default class PlanetTypeManifestManager
  constructor: () ->
    @planet_type_manifest = {}

  set_definitions: (planet_type, ground_definitions, tree_definitions) ->
    @planet_type_manifest[planet_type] = new PlanetTypeManifest(planet_type, ground_definitions, tree_definitions)
