
export default class MetadataRoad
  constructor: (@id) ->

  @from_json: (json) ->
    metadata = new MetadataRoad(json.id)
    metadata.atlas_key = json.atlas
    metadata.frames = json.frames
    metadata
