

window.starpeace ||= {}
window.starpeace.metadata ||= {}
window.starpeace.metadata.LandMetadataManager = class LandMetadataManager

  constructor: (@client) ->
    @planet_type_metadata_by_id = {}
    @planet_type_metadata_by_color = {}

  has_land_metadata: (planet_type) ->
    @planet_type_metadata_by_id?[planet_type]?

  set_land_metadata: (planet_type, metadata) ->
    @planet_type_metadata_by_id[planet_type] = metadata

    @planet_type_metadata_by_color[planet_type] = {}
    @planet_type_metadata_by_color[planet_type][tile_data.map_color] = tile_data for tile_key,tile_data of metadata
